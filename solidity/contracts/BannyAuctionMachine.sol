// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '@jbx-protocol/contracts-v2/contracts/JBETHERC20ProjectPayer.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@rari-capital/solmate/src/tokens/ERC721.sol';
import '@rari-capital/solmate/src/utils/ReentrancyGuard.sol';

interface IWETH9 is IERC20 {
  function deposit() external payable;

  function withdraw(uint256) external;
}

/**
  @notice blah

  @dev Loosely based on https://github.com/austintgriffith/banana-auction/blob/v3/packages/hardhat/contracts/NFTAuctionMachine.sol
 */
contract BannyAuctionMachine is ERC721, Ownable, ReentrancyGuard, JBETHERC20ProjectPayer {
  using Strings for uint256;



  error INVALID_DURATION();
  error INVALID_SUPPLY();
  error INVALID_PRICE();




  error AUCTION_NOT_OVER();
  error AUCTION_OVER();
  error BID_TOO_LOW();
  error ALREADY_HIGHEST_BIDDER();
  error INVALID_TOKEN_ID();
  error METADATA_IS_IMMUTABLE();
  error TOKEN_TRANSFER_FAILURE();
  error MAX_SUPPLY_REACHED();

  IWETH9 public constant WETH9 = IWETH9(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));

  /** @notice Duration of auctions in seconds. */
  uint256 public immutable auctionDuration;

  /** @notice Juicebox project id that will receive auction proceeds */
  uint256 public immutable projectId;

  /** @notice Token supply cap. */
  uint256 public maxSupply;

  /** @notice Current auction ending time. */
  uint256 public auctionExpiration;
  
  /** @notice Current highest bid. */
  uint256 public currentBid;
  
  /** @notice Current highest bidder. */
  address public currentBidder;

  uint256 public totalSupply; // TODO

  event Bid(address indexed bidder, uint256 amount, uint256 tokenId);
  event AuctionStarted(uint256 indexed auctionEndingAt, uint256 tokenId);
  event AuctionEnded(uint256 indexed auctionEndingAt, uint256 tokenId);

  /**
    @notice Creates a new instance of BannyAuctionMachine.

    @param _name Name.
    @param _symbol Symbol.
    @param _projectId JB Project ID of a particular project to pay to.
    @param _jbDirectory JB Directory contract address
    @param _maxSupply Maximum supply of NFTs.
    @param _duration Duration of the auction.
    @param _basePrice blah
     */
  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _projectId,
    IJBDirectory _jbDirectory,
    uint256 _maxSupply,
    uint256 _duration,
    uint256 _basePrice
  )
    ERC721(_name, _symbol)
    JBETHERC20ProjectPayer(
      _projectId,
      payable(msg.sender),
      false,
      string(abi.encodePacked(_name, ' auction proceeds')),
      '',
      false,
      IJBDirectory(_jbDirectory),
      address(this)
    )
  {
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
    projectId = _projectId;
    maxSupply = _maxSupply;
  }

  /**
    @notice Manages auction state for token.

    // if no auction, generate token traits, start auction
    // if auction is not over, bid
    // if auction is over, settle, generate token traits, start auction
   */
  function mint() external payable {
    //
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    if (tokenId > totalSupply) {
      revert INVALID_TOKEN_ID();
    }

    return '';
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(JBETHERC20ProjectPayer, ERC721)
    returns (bool)
  {
    return
      JBETHERC20ProjectPayer.supportsInterface(interfaceId) ||
      ERC721.supportsInterface(interfaceId);
  }



  /**
    @notice Returns time remaining in the auction.
    */
  function timeLeft() public view returns (uint256) {
    if (block.timestamp > auctionExpiration) {
      return 0;
    } else {
      return auctionExpiration - block.timestamp;
    }
  }

  /**
    @dev Allows users to bid & send eth to the contract.
    */
  function bid() public payable nonReentrant {
    if (block.timestamp > auctionExpiration) {
      revert AUCTION_OVER();
    }
    if (msg.value < (currentBid + 0.001 ether)) {
      revert BID_TOO_LOW();
    }
    if (msg.sender == currentBidder) {
      revert ALREADY_HIGHEST_BIDDER();
    }

    uint256 lastAmount = currentBid;
    address lastBidder = currentBidder;

    currentBid = msg.value;
    currentBidder = msg.sender;

    if (lastAmount > 0) {
      (bool sent, ) = lastBidder.call{value: lastAmount, gas: 20000}('');
      if (!sent) {
        WETH9.deposit{value: lastAmount}();
        bool success = WETH9.transfer(lastBidder, lastAmount);
        if (!success) {
          revert TOKEN_TRANSFER_FAILURE();
        }
      }
    }

    emit Bid(msg.sender, msg.value, 0); // TODO
  }

  /**
    @dev Allows anyone to mint the nft to the highest bidder/burn if there were no bids & restart the auction with a new end time.
    */
  function finalize() external {
    if (block.timestamp <= auctionExpiration) {
      revert AUCTION_NOT_OVER();
    }
    if (totalSupply == maxSupply) {
      revert MAX_SUPPLY_REACHED();
    }

    auctionExpiration = block.timestamp + auctionDuration;

    if (currentBidder == address(0)) {
      // If the auction received no bids, emit burn event and iterate totalSupply
      unchecked {
        totalSupply++;
      }
      uint256 tokenId = totalSupply;
      emit Transfer(address(0), address(0), tokenId);
    } else {
      uint256 lastAmount = currentBid;
      address lastBidder = currentBidder;

      currentBid = 0;
      currentBidder = address(0);

      _pay(
        projectId, //uint256 _projectId,
        JBTokens.ETH, // address _token
        lastAmount, //uint256 _amount,
        18, //uint256 _decimals,
        lastBidder, //address _beneficiary,
        0, //uint256 _minReturnedTokens,
        false, //bool _preferClaimedTokens,
        'nft mint', //string calldata _memo, // TODO: Add your own memo here. Links to image å are displayed on the Juicebox project page as images.
        '' //bytes calldata _metadata
      );

      unchecked {
        totalSupply++;
      }
      uint256 tokenId = totalSupply;
      _mint(lastBidder, tokenId);
      emit AuctionStarted(auctionExpiration, tokenId + 1);
    }
  }

}
