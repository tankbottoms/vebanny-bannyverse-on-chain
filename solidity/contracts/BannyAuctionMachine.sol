// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '@jbx-protocol/contracts-v2/contracts/JBETHERC20ProjectPayer.sol';
import '@jbx-protocol/contracts-v2/contracts/interfaces/IJBDirectory.sol';
import '@jbx-protocol/contracts-v2/contracts/libraries/JBTokens.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@rari-capital/solmate/src/utils/ReentrancyGuard.sol';
import '@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol';

import './libraries/ERC721Enumerable.sol';
import './BannyAuctionMachineUtil.sol';

interface IWETH9 is IERC20 {
  function deposit() external payable;

  function withdraw(uint256) external;
}

/**
  @notice An NFT contract with a built-in periodic auction mechanism that pays proceeds to a Juicebox project.

  Tokens are not minted directly but are instead auctioned off on a specific period starting at some base price. Winning bidder is then sent the NFT when the new auction starts.

  @dev Loosely based on https://github.com/austintgriffith/banana-auction/blob/v3/packages/hardhat/contracts/NFTAuctionMachine.sol
 */
contract BannyAuctionMachine is ERC721Enumerable, Ownable, ReentrancyGuard {
  using Strings for uint256;

  error INVALID_DURATION();
  error INVALID_SUPPLY();
  error INVALID_PRICE();
  error INVALID_BID();
  error PAYMENT_FAILURE();
  error SUPPLY_EXHAUSTED();

  IWETH9 public constant WETH9 = IWETH9(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
  address public constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  IQuoter public constant uniswapQuoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);

  /** @notice Duration of auctions in seconds. */
  uint256 public immutable auctionDuration;

  /** @notice Juicebox project id that will receive auction proceeds */
  uint256 public immutable jbxProjectId;

  /** @notice Juicebox directory for payment terminal lookup */
  IJBDirectory public immutable jbxDirectory;

  /** @notice Util contract with banny trait management features. */
  BannyAuctionMachineUtil public bannyUtil;

  string public ipfsGateway;
  string public ipfsRoot;

  /** @notice Token supply cap. */
  uint256 public maxSupply;

  /** @notice OpenSea-style metadata source. */
  string public contractMetadataURI;

  /** @notice Auction starting price. */
  uint256 public basePrice;

  /** @notice Maps token id to packed traits definition. */
  mapping(uint256 => uint256) public tokenTraits;

  /** @notice Current auction ending time. */
  uint256 public auctionExpiration;

  /** @notice Current highest bid. */
  uint256 public currentBid;

  /** @notice Current highest bidder. */
  address public currentBidder;

  event Bid(address indexed bidder, uint256 amount, uint256 tokenId);
  event AuctionStarted(uint256 expiration, uint256 tokenId);
  event AuctionEnded(address winner, uint256 price, uint256 tokenId);

  /**
    @notice Creates a new instance of BannyAuctionMachine.

    @param _name Name.
    @param _symbol Symbol.
    @param _projectId JB Project ID of a particular project to pay to.
    @param _jbDirectory JB Directory contract address
    @param _maxSupply Maximum supply of NFTs.
    @param _duration Duration of the auction.
    @param _basePrice Auction starting price.
     */
  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _projectId,
    IJBDirectory _jbDirectory,
    BannyAuctionMachineUtil _bannyUtil,
    string memory _ipfsGateway,
    string memory _ipfsRoot,
    uint256 _maxSupply,
    uint256 _duration,
    uint256 _basePrice,
    string memory _contractMetadataURI
  ) ERC721Enumerable(_name, _symbol) {
    if (_duration == 0) {
      revert INVALID_DURATION();
    }

    if (_maxSupply == 0) {
      revert INVALID_SUPPLY();
    }

    if (_basePrice == 0) {
      revert INVALID_PRICE();
    }

    auctionDuration = _duration;
    jbxProjectId = _projectId;
    jbxDirectory = _jbDirectory;
    bannyUtil = _bannyUtil;
    ipfsGateway = _ipfsGateway;
    ipfsRoot = _ipfsRoot;

    maxSupply = _maxSupply;
    contractMetadataURI = _contractMetadataURI;
    basePrice = _basePrice;
  }

  //*********************************************************************//
  // ------------------------ Token Operations ------------------------- //
  //*********************************************************************//

  function contractURI() public view returns (string memory) {
    // TODO: IBannyAuctionMachine
    return contractMetadataURI;
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    uint256 traits = tokenTraits[_tokenId];

    return dataUri(traits);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) public override {
    _beforeTokenTransfer(_from, _to, _tokenId);
    super.transferFrom(_from, _to, _tokenId);
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) public override {
    _beforeTokenTransfer(_from, _to, _tokenId);
    super.safeTransferFrom(_from, _to, _tokenId);
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  ) public override {
    _beforeTokenTransfer(_from, _to, _tokenId);
    super.safeTransferFrom(_from, _to, _tokenId, _data);
  }

  /**
    @notice Manages auction state for token.

    - if no auction, generate token traits, start auction
    - if auction is not over, bid
    - if auction is over, settle, generate token traits, start auction
   */
  function mint() external payable {
    if (msg.value < basePrice) {
      revert INVALID_BID();
    }

    if (currentBidder == address(0) && currentBid == 0) {
      // no auction, create new

      startNewAuction();
    } else if (auctionExpiration > block.timestamp && currentBid < msg.value) {
      // new high bid

      payable(currentBidder).transfer(currentBid); // TODO: check success
      currentBidder = msg.sender;
      currentBid = msg.value;

      uint256 tokenId = totalSupply() + 1;
      emit Bid(msg.sender, msg.value, tokenId);
    } else if (auctionExpiration <= block.timestamp && currentBid >= basePrice && currentBidder != address(0)) {
      // auction concluded with bids, settle, start new auction

      IJBPaymentTerminal terminal = jbxDirectory.primaryTerminalOf(jbxProjectId, JBTokens.ETH);
      if (address(terminal) == address(0)) {
        revert PAYMENT_FAILURE(); // NOTE: this will prevent future auctions from starting
      }

      terminal.pay(jbxProjectId, currentBid, JBTokens.ETH, currentBidder, 0, false, string(abi.encodePacked('')), '');

      uint256 tokenId = totalSupply() + 1;
      _beforeTokenTransfer(address(0), currentBidder, tokenId);
      _mint(msg.sender, tokenId);

      emit AuctionEnded(currentBidder, currentBid, tokenId);

      startNewAuction();
    } else if (auctionExpiration <= block.timestamp && currentBid < basePrice) {
      // auction concluded without bids, new start new auction

      uint256 tokenId = totalSupply() + 1;
      _beforeTokenTransfer(address(0), address(this), tokenId);
      _mint(msg.sender, tokenId);

      startNewAuction();
    }
  }

  //*********************************************************************//
  // --------------------------- Public Views -------------------------- //
  //*********************************************************************//

  /** @notice Time to auction expiration. */
  function timeLeft() public view returns (uint256) {
    if (block.timestamp > auctionExpiration) {
      return 0;
    } else {
      return auctionExpiration - block.timestamp;
    }
  }

  /** @notice ERC165 */
  function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
    return ERC721Enumerable.supportsInterface(interfaceId);
  }

  /** @notice Returns an image for a given set of traits, unattached to a token id. */
  function previewTraits(uint256 _traits) public view returns (string memory) {
    return dataUri(_traits);
  }

  //*********************************************************************//
  // ---------------------- Privileged Operations ---------------------- //
  //*********************************************************************//

  function setIPFSGatewayURI(string calldata _uri) external onlyOwner {
    ipfsGateway = _uri;
  }

  function setIPFSRoot(string calldata _root) external onlyOwner {
    ipfsRoot = _root;
  }

  function setContractURI(string calldata _uri) external onlyOwner {
    contractMetadataURI = _uri;
  }

  // TODO: consider allowing changing addresses for dai, weth, jbx directory, quoter
  // TODO: consider allowing changing baseprice
  // TODO: consider allowing transfer of owned tokens from failed auctions

  //*********************************************************************//
  // ----------------------- Private Operations ------------------------ //
  //*********************************************************************//

  function generateSeed(address _account, uint256 _blockNumber) internal returns (uint256 seed) {
    uint256 ethPrice = uniswapQuoter.quoteExactInputSingle(
      address(WETH9),
      DAI,
      3000, // fee
      1 ether,
      0 // sqrtPriceLimitX96
    );

    seed = uint256(keccak256(abi.encodePacked(_account, _blockNumber, ethPrice)));
  }

  function startNewAuction() internal {
    uint256 traits = bannyUtil.generateTraits(generateSeed(msg.sender, block.number));
    uint256 tokenId = totalSupply() + 1;
    tokenTraits[tokenId] = traits;

    if (msg.value >= basePrice) {
      currentBidder = msg.sender;
      currentBid = msg.value;
    } else {
      currentBidder = address(0);
      currentBid = 0;
    }
    auctionExpiration = block.timestamp + auctionDuration;

    emit AuctionStarted(auctionExpiration, tokenId);
  }

  function dataUri(uint256 _traits) internal view returns (string memory) {
    return
      string(
        abi.encodePacked(
          '<svg id="token" width="300" height="300" viewBox="0 0 1080 1080" fill="none" xmlns="http://www.w3.org/2000/svg"><g id="bannyPlaceholder">',
          bannyUtil.getImageStack(ipfsGateway, ipfsRoot, _traits),
          '</g></svg>'
        )
      );
  }
}
