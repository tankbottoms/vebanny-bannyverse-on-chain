// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';

import './enums/AssetDataType.sol';
import './libraries/Base64.sol';
import './libraries/ERC721Enumerable.sol';
import './interfaces/IToken.sol';
import './interfaces/IStorage.sol';
import './interfaces/IBannyCommonUtil.sol';

error ARGUMENT_EMPTY(string);
error INVALID_PROOF();
error CLAIMS_EXHAUSTED();
error INVALID_CLAIM();

contract Token is IToken, ERC721Enumerable, ReentrancyGuard, AccessControl {
  bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

  IStorage public assets;
  IBannyCommonUtil private bannyUtil;

  /**
    @notice Maps token id to packed traits definition.
    */
  mapping(uint256 => uint256) public tokenTraits;

  string public contractMetadataURI;

  bytes32 public immutable merkleRoot;

  /**
    @notice Maps address to number of merkle claims that were executed.
    */
  mapping(address => uint256) public claimedMerkleAllowance;

  mapping(address => bool) public claimedExtras;

  constructor(
    IStorage _assets,
    IBannyCommonUtil _bannyUtil,
    address _admin,
    bytes32 _merkleRoot,
    string memory _name,
    string memory _symbol
  ) ERC721Enumerable(_name, _symbol) {
    assets = _assets;
    bannyUtil = _bannyUtil;
    merkleRoot = _merkleRoot;

    _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    _grantRole(MINTER_ROLE, _admin);
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

    string memory animationUrl;
    if (traits == 5666264788816401) {
        animationUrl = string(abi.encodePacked(
            '"animation_url": "',
            bannyUtil.getAssetBase64(assets, 9223372036854775810, AssetDataType.AUDIO_MP3),
            '", '
        ));
    }

    string memory json = Base64.encode(
      abi.encodePacked(
        '{"name": "',
        name,
        ' No.',
        Strings.toString(_tokenId),
        '", "description": "Fully on-chain NFT", "image": "data:image/svg+xml;base64,',
        _getFramedImage(traits),
        '", ',
        animationUrl,
        '"attributes":',
        bannyUtil.getTokenTraits(traits),
        '}'
      )
    );
    return string(abi.encodePacked('data:application/json;base64,', json));
  }

  /**
    @notice Allows minting by anyone in the merkle root.
    */
  function merkleMint(
    uint256 _index,
    uint256 _allowance,
    bytes32[] calldata _proof,
    uint256 _traits
  ) external override nonReentrant returns (uint256 tokenId) {
    if (_traits == 5666264788816401) {
        revert INVALID_CLAIM();
    }

    bytes32 node = keccak256(abi.encodePacked(_index, msg.sender, _allowance));

    if (!MerkleProof.verify(_proof, merkleRoot, node)) {
      revert INVALID_PROOF();
    }

    if (_allowance - claimedMerkleAllowance[msg.sender] == 0) {
        revert CLAIMS_EXHAUSTED();
    } else {
        ++claimedMerkleAllowance[msg.sender];
    }

    tokenId = totalSupply() + 1;

    tokenTraits[tokenId] = _traits;

    _beforeTokenTransfer(address(0), msg.sender, tokenId);

    _mint(msg.sender, tokenId);
  }

  function claimExtra() external payable nonReentrant returns (uint256 tokenId){
    if (balanceOf(msg.sender) < 5) { revert INVALID_CLAIM(); }

    if (msg.value < 0.1 ether) { revert INVALID_CLAIM(); }

    if (claimedExtras[msg.sender]) { revert INVALID_CLAIM(); }

    claimedExtras[msg.sender] = true;

    tokenId = totalSupply() + 1;

    tokenTraits[tokenId] = 5666264788816401;

    _beforeTokenTransfer(address(0), msg.sender, tokenId);

    _mint(msg.sender, tokenId);
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
        bannyUtil.getImageStack(assets, _traits),
        '</g></svg>'
      )
    );
  }
}
