// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import {ERC721 as ERC721Rari} from '@rari-capital/solmate/src/tokens/ERC721.sol';

import '@jbx-protocol/contracts-v2/contracts/interfaces/IJBDirectory.sol';
import '@jbx-protocol/contracts-v2/contracts/interfaces/IJBFundingCycleDataSource.sol';
import '@jbx-protocol/contracts-v2/contracts/interfaces/IJBPayDelegate.sol';
import '@jbx-protocol/contracts-v2/contracts/interfaces/IJBRedemptionDelegate.sol';

import '@jbx-protocol/contracts-v2/contracts/structs/JBDidPayData.sol';
import '@jbx-protocol/contracts-v2/contracts/structs/JBDidRedeemData.sol';
import '@jbx-protocol/contracts-v2/contracts/structs/JBRedeemParamsData.sol';
import '@jbx-protocol/contracts-v2/contracts/structs/JBTokenAmount.sol';

import './interfaces/IStorage.sol';
import './interfaces/IBannyCommonUtil.sol';
import './libraries/Base64.sol';

/**
  @title Juicebox data source delegate that offers project contributors NFTs.

  @notice This contract allows project creators to reward contributors with NFTs. Intended use is to incentivize initial project support by minting a limited number of NFTs to the first N contributors.

  @notice One use case is enabling the project to mint an NFT for anyone contributing any amount without a mint limit. Set minContribution.value to 0 and maxSupply to uint256.max to do this. To mint NFTs to the first 100 participants contributing 1000 DAI or more, set minContribution.value to 1000000000000000000000 (3 + 18 zeros), minContribution.token to 0x6B175474E89094C44Da98b954EedeAC495271d0F and maxSupply to 100.

  @dev Keep in mind that this PayDelegate and RedeemDelegate implementation will simply pass through the weight and reclaimAmount it is called with.
 */
contract JBBannyRewardDelegate is
  ERC721Rari,
  Ownable,
  IJBFundingCycleDataSource,
  IJBPayDelegate,
  IJBRedemptionDelegate
{
  using Strings for uint256;

  //*********************************************************************//
  // --------------------------- custom errors ------------------------- //
  //*********************************************************************//
  error INVALID_PAYMENT_EVENT();
  error INCORRECT_OWNER();
  error INVALID_ADDRESS();
  error INVALID_TOKEN();
  error SUPPLY_EXHAUSTED();
  error INVALID_REQUEST(string);
  error INVALID_TIER_PRICE_LIST();
  error INVALID_PRICE_SORT_ORDER(uint256);

  //*********************************************************************//
  // -------------------------- constructor ---------------------------- //
  //*********************************************************************//

  /**
    @notice
    Project id of the project this configuration is associated with.
  */
  uint256 private projectId;

  /**
    @notice
    Parent controller.
  */
  IJBDirectory private directory;

  /**
    @notice
    NFT mint cap as part of this configuration.
  */
  uint256 internal maxSupply;

  /**
    @notice Current supply.

    @dev Also used to check if rewards supply was exhausted and as nextTokenId
  */
  uint256 internal supply;

  /**
    @notice
    Contract opensea-style metadata uri.
  */
  string private contractUri;

  uint64[] public tierTraits = [
      0,
      // escrow
      4522360314008081,
      40551157357089297,
      22783049442791953,
      5015149023859217,
      5156778560983569,
      5261232171913747,
      5314008732176913,
      5331600919237137,
      4610321249473042,
      4645505623659026,
      50015753453179409,
    //   31860617445904913,
    //   4698282184942097,
    //   68294378365391377,
    //   45054757790814737,
    //   4997349366567441,
    //   5349193106330129,
    //   5366785293423121,
    //   5419561854702097,
    //   5120494675169809,
    //   4627913436566033,
    //   5489930602025233,
    //   72991148398874897,
    //   4821427494601233,
    //   4575136875286801,
    //   9061144315564305,
    //   77512340265767441,
    //   4786243120402961,
    //   4592729330815249,
    //   4522360314008083,
    //   4891796779831825,
    //   5032808617612049,
    //   5173271236448529,
    //   63772842953544209,
    //   4539952501101073,
    //   4715874372030993,
    //   5085310300983825,
    //   54642498389152273,
    //   4944572805288465,
    //   5472338414932497,
    //   4680689997844753,
    //   4909388430053905,
    //   13740665813864977,
    //   5067718113890833,
    //   5138088472875537,
    //   59234058951987729,
    //   4522360314028562,
    //   5401969667609105,
    //   36381809260384785,
    //   5208455610663441,
    //   5296416545051153,
    //   5050125926797841,
    //   4962166066123281,
    //   5384379627999761,
    //   27321902163833361,
    //   4663097810752017,
    //   5278826192966164,
    //   18261857628328465,
    //   4874341494821137,
      4926980593054225];

  uint256[] public tierPrices;

  address public contributionToken;

  IStorage public assets;
  IBannyCommonUtil private bannyUtil;

  /**
    @notice Maps token id to packed traits definition.
  */
  mapping(uint256 => uint256) public tokenTraits;

  /**
    @param _projectId JBX project id this reward is associated with.
    @param _directory JBX directory.
    @param _maxSupply Total number of reward tokens to distribute.
    @param _tierPrices List of prices for contribution tiers.
    @param _name The name of the token.
    @param _symbol The symbol that the token should be represented by.
    @param _contractMetadataUri Contract metadata uri.
    @param _admin Set an alternate owner.
  */
  constructor(
    uint256 _projectId,
    IJBDirectory _directory,
    uint256 _maxSupply,
    uint256[] memory _tierPrices,
    address _contributionToken,
    string memory _name,
    string memory _symbol,
    string memory _contractMetadataUri,
    address _admin,
    IStorage _assets,
    IBannyCommonUtil _bannyUtil
  ) ERC721Rari(_name, _symbol) {
    // JBX
    projectId = _projectId;
    directory = _directory;
    maxSupply = _maxSupply;
    contributionToken = _contributionToken;

    // ERC721
    contractUri = _contractMetadataUri;

    if (tierTraits.length > _tierPrices.length) {
      revert INVALID_TIER_PRICE_LIST();
    }

    if (_tierPrices.length > 0) {
      tierPrices.push(_tierPrices[0]);

      for (uint256 i = 1; i < _tierPrices.length; i++) {
        if (_tierPrices[i] < _tierPrices[i - 1]) {
          revert INVALID_PRICE_SORT_ORDER(i);
        }

        tierPrices.push(_tierPrices[i]);
      }

      assets = _assets;
      bannyUtil = _bannyUtil;

      if (_admin != address(0)) {
        _transferOwnership(_admin);
      }
    }
  }

  //*********************************************************************//
  // ------------------- IJBFundingCycleDataSource --------------------- //
  //*********************************************************************//

  function payParams(JBPayParamsData calldata _data)
    external
    view
    override
    returns (
      uint256 weight,
      string memory memo,
      IJBPayDelegate delegate
    )
  {
    return (_data.weight, _data.memo, IJBPayDelegate(address(this)));
  }

  function redeemParams(JBRedeemParamsData calldata _data)
    external
    pure
    override
    returns (
      uint256 reclaimAmount,
      string memory memo,
      IJBRedemptionDelegate delegate
    )
  {
    return (_data.reclaimAmount.value, _data.memo, IJBRedemptionDelegate(address(0)));
  }

  //*********************************************************************//
  // ------------------------ IJBPayDelegate --------------------------- //
  //*********************************************************************//

  /**
    @notice Part of IJBPayDelegate, this function will mint an NFT to the contributor (_data.beneficiary) if conditions are met.

    @dev This function will revert if the terminal calling it does not belong to the registered project id.

    @dev This function will also revert due to ERC721 mint issue, which may interfere with contribution processing. These are unlikely and include beneficiary being the 0 address or the beneficiary already holding the token id being minted. The latter should not happen given that mint is only controlled by this function.

    @param _data Juicebox project contribution data.
   */
  function didPay(JBDidPayData calldata _data) external override {
    if (
      !directory.isTerminalOf(projectId, IJBPaymentTerminal(msg.sender)) ||
      _data.projectId != projectId
    ) {
      revert INVALID_PAYMENT_EVENT();
    }

    if (supply == maxSupply) {
      return;
    }

    if (_data.amount.token != contributionToken) {
      return;
    }

    uint256 tokenId;
    uint256 traits;
    for (uint256 i; i < tierPrices.length; i++) {
      if (
        (tierPrices[i] <= _data.amount.value && i == tierPrices.length - 1) ||
        (tierPrices[i] <= _data.amount.value && tierPrices[i + 1] > _data.amount.value)
      ) {
        tokenId = tokenId = totalSupply() + 1;
        traits = tierTraits[i];
        break;
      }
    }

    if (tokenId != 0) {
        tokenTraits[tokenId] = traits;
        _mint(_data.beneficiary, tokenId);
        supply += 1;
    }
  }

  //*********************************************************************//
  // -------------------- IJBRedemptionDelegate ------------------------ //
  //*********************************************************************//

  /**
  @notice NFT redemption is not supported.
   */
  // solhint-disable-next-line
  function didRedeem(JBDidRedeemData calldata _data) external override {
    // not a supported workflow for NFTs
  }

  //*********************************************************************//
  // ---------------------------- IERC165 ------------------------------ //
  //*********************************************************************//

  function supportsInterface(bytes4 _interfaceId)
    public
    view
    override(ERC721Rari, IERC165)
    returns (bool)
  {
    return
      _interfaceId == type(IJBFundingCycleDataSource).interfaceId ||
      _interfaceId == type(IJBPayDelegate).interfaceId ||
      _interfaceId == type(IJBRedemptionDelegate).interfaceId ||
      super.supportsInterface(_interfaceId); // check with rari-ERC721
  }

  function totalSupply() public view returns (uint256) {
    return supply;
  }

  function tokenSupply(uint256 _tokenId) public view returns (uint256) {
    return _ownerOf[_tokenId] != address(0) ? 1 : 0;
  }

  function totalOwnerBalance(address _account) public view returns (uint256) {
    if (_account == address(0)) {
      revert INVALID_ADDRESS();
    }

    return _balanceOf[_account];
  }

  function ownerTokenBalance(address _account, uint256 _tokenId)
    public
    view
    returns (uint256)
  {
    return _ownerOf[_tokenId] == _account ? 1 : 0;
  }

  //*********************************************************************//
  // ----------------------------- ERC721 ------------------------------ //
  //*********************************************************************//

  /**
    @notice Returns the full URI for the asset.
  */
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    if (_ownerOf[_tokenId] == address(0)) {
      revert INVALID_TOKEN();
    }

    uint256 traits = tokenTraits[_tokenId];

    string memory json = Base64.encode(
      abi.encodePacked(
        '{"name": "',
        name,
        ' No.',
        Strings.toString(_tokenId),
        '", "description": "Fully on-chain NFT", "image": "data:image/svg+xml;base64,',
        _getFramedImage(traits),
        '", ',
        '"attributes":',
        bannyUtil.getTokenTraits(traits),
        '}'
      )
    );

    return string(abi.encodePacked('data:application/json;base64,', json));
  }

  /**
    @notice Returns the contract metadata uri.
  */
  function contractURI() public view returns (string memory) {
    return contractUri;
  }

  /**
    @notice
    Transfer tokens to an account.

    @param _to The destination address.
    @param _id NFT id to transfer.
  */
  function transfer(address _to, uint256 _id) public {
    transferFrom(msg.sender, _to, _id);
  }

  /**
    @notice
    Transfer tokens between accounts.

    @param _from The originating address.
    @param _to The destination address.
    @param _id The amount of the transfer, as a fixed point number with 18 decimals.
  */
  function transferFrom(
    address _from,
    address _to,
    uint256 _id
  ) public override {
    super.transferFrom(_from, _to, _id);
  }

  /**
    @notice
    Confirms that the given address owns the provided token.
   */
  function isOwner(address _account, uint256 _id) public view returns (bool) {
    return _ownerOf[_id] == _account;
  }

  /**
    @notice
    Owner-only function to set a contract metadata uri to contain opensea-style metadata.

    @param _contractMetadataUri New metadata uri.
  */
  function setContractUri(string calldata _contractMetadataUri) external onlyOwner {
    contractUri = _contractMetadataUri;
  }

  function _getFramedImage(uint256 _traits) internal view returns (string memory image) {
    image = Base64.encode(
      abi.encodePacked(
        '<svg id="token" width="300" height="300" viewBox="0 0 1080 1080" fill="none" xmlns="http://www.w3.org/2000/svg"> <defs><radialGradient id="paint0_radial_772_22716" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(540.094 539.992) rotate(90) scale(539.413)"><stop stop-color="#B4B4B4" /><stop offset="1" /></radialGradient></defs><circle cx="540.094" cy="539.992" r="539.413" fill="url(#paint0_radial_772_22716)"/><g id="bannyPlaceholder">',
        bannyUtil.getImageStack(assets, _traits),
        '</g></svg>'
      )
    );
  }
}
