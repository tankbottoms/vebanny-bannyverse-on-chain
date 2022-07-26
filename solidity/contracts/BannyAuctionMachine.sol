// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '@jbx-protocol/contracts-v2/contracts/interfaces/IJBPaymentTerminal.sol';
import '@jbx-protocol/contracts-v2/contracts/libraries/JBTokens.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@rari-capital/solmate/src/tokens/ERC721.sol';
import '@rari-capital/solmate/src/utils/ReentrancyGuard.sol';
import '@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol';

import './BannyAuctionMachineUtil.sol';

/**
  @notice An NFT contract with a built-in periodic auction mechanism that pays proceeds to a Juicebox project.

  Tokens are not minted directly but are instead auctioned off on a specific period starting at some base price. Winning bidder is then sent the NFT when the new auction starts.

  @dev Loosely based on https://github.com/austintgriffith/banana-auction/blob/v3/packages/hardhat/contracts/NFTAuctionMachine.sol
 */
contract BannyAuctionMachine is ERC721, Ownable, ReentrancyGuard {
  using Strings for uint256;

  error INVALID_DURATION();
  error INVALID_PRICE();
  error INVALID_BID();
  error SUPPLY_EXHAUSTED();
  error AUCTION_ACTIVE();

  address public constant WETH9 = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  address public constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  IQuoter public constant uniswapQuoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);

  /** @notice Duration of auctions in seconds. */
  uint256 public auctionDuration;

  /** @notice Juicebox project id that will receive auction proceeds */
  uint256 public jbxProjectId;

  /** @notice Juicebox terminal for send proceeds to */
  IJBPaymentTerminal public jbxTerminal;

  /** @notice Util contract with banny trait management features. */
  BannyAuctionMachineUtil public bannyUtil;

  string public ipfsGateway;
  string public ipfsRoot;

  /** @notice Token supply cap. */
  uint256 public maxSupply;

  uint256 public totalSupply;

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
    @param _jbTerminal JB Terminal for proceeds deposit.
    @param _maxSupply Maximum supply of NFTs, value of 0 means "unlimited".
    @param _duration Duration of the auction.
    @param _basePrice Auction starting price.
     */
  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _projectId,
    IJBPaymentTerminal _jbTerminal,
    BannyAuctionMachineUtil _bannyUtil,
    string memory _ipfsGateway,
    string memory _ipfsRoot,
    uint256 _maxSupply,
    uint256 _duration,
    uint256 _basePrice,
    string memory _contractMetadataURI
  ) ERC721(_name, _symbol) {
    if (_duration == 0) {
      revert INVALID_DURATION();
    }

    if (_basePrice == 0) {
      revert INVALID_PRICE();
    }

    auctionDuration = _duration;
    jbxProjectId = _projectId;
    jbxTerminal = _jbTerminal;
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

  function bid() external payable {
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

      uint256 tokenId = totalSupply + 1;
      emit Bid(msg.sender, msg.value, tokenId);
    }
  }

  function settle() external {
    if (auctionExpiration > block.timestamp) {
      revert AUCTION_ACTIVE();
    }

    if (currentBidder != address(0)) {
      // auction concluded with bids, settle

      jbxTerminal.pay(jbxProjectId, currentBid, JBTokens.ETH, currentBidder, 0, false, string(abi.encodePacked('')), ''); // TODO: send relevant memo to terminal

      unchecked {
        ++totalSupply;
      }
      _mint(msg.sender, totalSupply);

      emit AuctionEnded(currentBidder, currentBid, totalSupply);
    } else {
      // auction concluded without bids

      unchecked {
        ++totalSupply;
      }
      _mint(msg.sender, totalSupply);
    }

    if (maxSupply == 0 || totalSupply + 1 <= maxSupply) {
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
    return ERC721.supportsInterface(interfaceId);
  }

  /** @notice Returns an image for a given set of traits, unattached to a token id. */
  function previewTraits(uint256 _traits) public view returns (string memory) {
    return dataUri(_traits);
  }

  //*********************************************************************//
  // ---------------------- Privileged Operations ---------------------- //
  //*********************************************************************//

  function setPaymentTerminal(IJBPaymentTerminal _jbTerminal) external onlyOwner {
    jbxTerminal = _jbTerminal;
  }

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
      WETH9,
      DAI,
      3000, // fee
      1 ether,
      0 // sqrtPriceLimitX96
    );

    seed = uint256(keccak256(abi.encodePacked(_account, _blockNumber, ethPrice)));
  }

  function startNewAuction() internal {
    if (maxSupply != 0 && totalSupply == maxSupply) {
      revert SUPPLY_EXHAUSTED();
    }

    uint256 traits = bannyUtil.generateTraits(generateSeed(msg.sender, block.number));
    uint256 tokenId = totalSupply + 1;

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
