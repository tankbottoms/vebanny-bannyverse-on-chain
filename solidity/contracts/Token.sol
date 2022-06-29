// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

import './libraries/Base64.sol';
import './libraries/ERC721Enumerable.sol';
import './interfaces/IToken.sol';
import './interfaces/IStorage.sol';
import './BannyCommonUtil.sol';

error ARGUMENT_EMPTY(string);

contract Token is IToken, ERC721Enumerable, ReentrancyGuard, AccessControl, BannyCommonUtil {
  bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

  IStorage public assets;

  /**
    @notice Maps token id to packed traits definition.
    */
  mapping(uint256 => uint256) public tokenTraits;

  string public contractMetadataURI;

  constructor(
    IStorage _assets,
    string memory _name,
    string memory _symbol
  ) ERC721Enumerable(_name, _symbol) {
    assets = _assets;

    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(MINTER_ROLE, msg.sender);
  }

  //*********************************************************************//
  // ------------------------ Token Operations ------------------------- //
  //*********************************************************************//

  function contractURI() public view override returns (string memory) {
    return contractMetadataURI;
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    return dataUri(_tokenId);
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

  function dataUri(uint256 _tokenId) internal view returns (string memory) {
    uint256 traits = tokenTraits[_tokenId];

    // special case Rick
    // traits == 5666264788816401
    // else 
    string memory json = Base64.encode(      
      abi.encodePacked(
        '{"name": "',
        name,
        ' No.',
        Strings.toString(_tokenId),
        '", "description": "Fully on-chain NFT", "image": "data:image/svg+xml;base64,',
        _getFramedImage(traits),
        '", "attributes":',
        _getTokenTraits(traits),
        '}'
      ));
    return string(abi.encodePacked('data:application/json;base64,', json));
  }

  /**
    @notice ERC165
    */
  function supportsInterface(bytes4 _interfaceId)
    public
    view
    override(AccessControl, ERC721Enumerable)
    returns (bool)
  {
    return super.supportsInterface(_interfaceId);
  }

//   function validateTraits(uint256 _traits) public pure override returns (bool valid) {
//     if (_traits == 0) {
//       return false;
//     }

//     valid = true;
//   }

  //*********************************************************************//
  // ---------------------- Privileged Operations ---------------------- //
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
    require(payable(msg.sender).send(address(this).balance), 'withdrawEther failed');
  }

  function _getFramedImage(uint256 _traits) internal view returns (string memory image) {
    image = Base64.encode(
      abi.encodePacked(
        '<svg id="token" width="300" height="300" viewBox="0 0 1080 1080" fill="none" xmlns="http://www.w3.org/2000/svg"> <defs><radialGradient id="paint0_radial_772_22716" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(540.094 539.992) rotate(90) scale(539.413)"><stop stop-color="#B4B4B4" /><stop offset="1" /></radialGradient></defs><circle cx="540.094" cy="539.992" r="539.413" fill="url(#paint0_radial_772_22716)"/><g id="bannyPlaceholder">',
        _getImageStack(assets, _traits),
        '</g></svg>'
      )
    );
  }
}
