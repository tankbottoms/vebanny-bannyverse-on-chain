// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

import './libraries/Base64.sol';
import './libraries/ERC721Enumerable.sol';
import './interfaces/IToken.sol';
import './interfaces/IStorage.sol';
import './enums/AssetDataType.sol';

error ARGUMENT_EMPTY(string);

contract Token is IToken, ERC721Enumerable, ReentrancyGuard, AccessControl {
  bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

  IStorage public assets;

  /**
    @notice Maps token id to packed traits definition.
    */
  mapping(uint256 => uint256) public tokenTraits;

  string public contractMetadataURI;

  constructor(IStorage _assets, string memory _name, string memory _symbol) ERC721Enumerable(_name, _symbol) {
    assets = _assets;

    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  function contractURI() public view override returns (string memory) {
    return contractMetadataURI;
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    return dataUri(_tokenId);
  }

  function supportsInterface(bytes4 _interfaceId)
    public
    view
    override(AccessControl, ERC721Enumerable)
    returns (bool)
  {
    return super.supportsInterface(_interfaceId);
  }

  // transfer
  // transferFrom
  // approve

  // view to validate traits value

  //*********************************************************************//
  // ----------------------- Storage Management ------------------------ //
  //*********************************************************************//

  /**
    @notice 

    @param _owner Address of the owner.
    @param _traits Packed NFT traits.
    */
  function mint(address _owner, uint256 _traits)
    public
    override
    onlyRole(MINTER_ROLE)
    returns (uint256 tokenId)
  {
    tokenId = totalSupply() + 1;

    tokenTraits[tokenId] = _traits;

    _beforeTokenTransfer(address(0), _owner, tokenId);

    _mint(_owner, tokenId);
  }

  function addMinter(address _account) public override onlyRole(DEFAULT_ADMIN_ROLE) {
    _grantRole(MINTER_ROLE, _account);
  }

  function removeMinter(address _account) public override onlyRole(DEFAULT_ADMIN_ROLE) {
    _revokeRole(MINTER_ROLE, _account);
  }

  function setContractURI(string calldata _uri) public override onlyRole(DEFAULT_ADMIN_ROLE) {
    if (bytes(_uri).length == 0) {
      revert ARGUMENT_EMPTY('_uri');
    }

    contractMetadataURI = _uri;
  }

  function withdrawEther() public override onlyRole(DEFAULT_ADMIN_ROLE) {
    require(payable(msg.sender).send(address(this).balance), 'Token: Withdraw all failed.');
  }

  //*********************************************************************//
  // ----------------------- Storage Management ------------------------ //
  //*********************************************************************//

  function getAssetBase64(uint64 _assetId, AssetDataType _assetType)
    public
    view
    override
    returns (string memory)
  {
    string memory prefix = '';

    if (_assetType == AssetDataType.AUDIO_MP3) {
      prefix = 'data:audio/mp3;base64,';
    } else if (_assetType == AssetDataType.IMAGE_SVG) {
      prefix = 'data:image/svg+xml;base64,';
    } else if (_assetType == AssetDataType.IMAGE_PNG) {
      prefix = 'data:image/png;base64,';
    }

    return string(abi.encodePacked(prefix, Base64.encode(assets.getAssetContentForId(_assetId))));
  }

  function getAudioContent() public view override returns (string memory) {
    return
      string(
        abi.encodePacked('data:audio/mp3;base64,', Base64.encode(assets.getAssetContentForId(0)))
      );
  }

  function dataUri(uint256 _tokenId) public view override returns (string memory) {
    string memory json = Base64.encode(
      abi.encodePacked(
        '{"name": "Token No.',
        Strings.toString(_tokenId),
        '", "description": "Fully on-chain NFT", "audio": "',
        getAssetBase64(uint64(0), AssetDataType.AUDIO_MP3),
        '", "image": "',
        getAssetBase64(uint64(1), AssetDataType.IMAGE_SVG),
        '", "animation_url": "',
        _getImageStack(_tokenId),
        '#',
        getAssetBase64(uint64(0), AssetDataType.AUDIO_MP3),
        '#", "attributes":[{"trait_type":"TRAIT","value":"yes"}]}'
      )
    );

    return string(abi.encodePacked('data:application/json;base64,', json));
  }

  function _getImageStack(uint256 _tokenId) internal view returns (string memory) {
    // BODY_TRAIT_OFFSET = 0; // uint4
    // HANDS_TRAIT_OFFSET = 4; // uint4
    // CHOKER_TRAIT_OFFSET = 8; // uint4
    // FACE_TRAIT_OFFSET = 12; // uint8, 6 needed
    // HEADGEAR_TRAIT_OFFSET = 20; // uint8, 7 needed
    // LEFTHAND_TRAIT_OFFSET = 28; // uint8, 5 needed
    // LOWER_TRAIT_OFFSET = 36; // uint4, 3 needed
    // ORAL_TRAIT_OFFSET = 40; // uint4, 2 needed
    // OUTFIT_TRAIT_OFFSET = 44; // uint8, 7 needed
    // RIGHTHAND_TRAIT_OFFSET = 52; // uint8, 6 needed
    // uint4Mask = 15;

    uint256 traits = tokenTraits[_tokenId];

    string memory bodyContent = getAssetBase64(uint64(uint8(traits) & 15), AssetDataType.IMAGE_PNG);

    string memory handsContent = '';
    uint64 contentId = uint64(uint8(traits >> 4) & 15);
    if (contentId > 0) {
        handsContent = getAssetBase64(contentId, AssetDataType.IMAGE_PNG);
    }

    string memory chokerContent = getAssetBase64(uint64(uint8(traits >> 8) & 15), AssetDataType.IMAGE_PNG);
    string memory faceContent = getAssetBase64(uint64(uint8(traits >> 12)), AssetDataType.IMAGE_PNG);
    string memory headgearContent = getAssetBase64(uint64(uint8(traits >> 20)), AssetDataType.IMAGE_PNG);

    string memory leftHandContent = '';
    contentId = uint64(uint8(traits >> 28));
    if (contentId > 0) {
        leftHandContent = getAssetBase64(contentId, AssetDataType.IMAGE_PNG);
    }

    string memory lowerContent = getAssetBase64(uint64(uint8(traits >> 36) & 15), AssetDataType.IMAGE_PNG);

    string memory oralContent = '';
    contentId = uint64(uint8(traits >> 40) & 15);
    if (contentId > 0) {
        oralContent = getAssetBase64(contentId, AssetDataType.IMAGE_PNG);
    }

    string memory outfitContent = getAssetBase64(uint64(uint8(traits >> 44)), AssetDataType.IMAGE_PNG);

    string memory rightHandContent = '';
    contentId = uint64(uint8(traits >> 52));
    if (contentId > 0) {
        rightHandContent = getAssetBase64(contentId, AssetDataType.IMAGE_PNG);
    }

    return ''; // stack layers
  }

  function _getTokenTraits(uint256 _tokenId) internal view returns (string memory) {

  }
}
