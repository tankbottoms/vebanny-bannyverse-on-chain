# Solidity API

## BannyCommonUtil

### validateTraits

```solidity
function validateTraits(uint256 _traits) public pure returns (bool)
```

### getIndexedTokenTraits

```solidity
function getIndexedTokenTraits(uint256 _index) public pure returns (uint256)
```

### getAssetBase64

```solidity
function getAssetBase64(contract IStorage assets, uint64 _assetId, enum AssetDataType _assetType) public view returns (string)
```

### getImageStack

```solidity
function getImageStack(contract IStorage assets, uint256 traits) public view returns (string image)
```

### getTokenTraits

```solidity
function getTokenTraits(uint256 traits) public pure returns (bytes json)
```

_Returns packed traits JSON for a given trait uint._

### __imageTag

```solidity
function __imageTag(string _content) private pure returns (string tag)
```

_incoming parameter is wrapped blindly without checking content._

### bodyTraits

```solidity
function bodyTraits(uint256 _index) public pure returns (string)
```

### handsTraits

```solidity
function handsTraits(uint256 _index) public pure returns (string)
```

### chokerTraits

```solidity
function chokerTraits(uint256 _index) public pure returns (string)
```

### faceTraits

```solidity
function faceTraits(uint256 _index) public pure returns (string)
```

### headgearTraits

```solidity
function headgearTraits(uint256 _index) public pure returns (string)
```

### leftHandTraits

```solidity
function leftHandTraits(uint256 _index) public pure returns (string)
```

### lowerTraits

```solidity
function lowerTraits(uint256 _index) public pure returns (string)
```

### oralTraits

```solidity
function oralTraits(uint256 _index) public pure returns (string)
```

### outfitTraits

```solidity
function outfitTraits(uint256 _index) public pure returns (string)
```

### rightHandTraits

```solidity
function rightHandTraits(uint256 _index) public pure returns (string)
```

## Deployer

### constructor

```solidity
constructor(bytes32 _merkleRoot, string _name, string _symbol, address _admin) public
```

## JBVeTokenUriResolver

@dev https://github.com/tankbottoms/jbx-staking/blob/master/contracts/JBVeTokenUriResolver.sol

### contractURI

```solidity
string contractURI
```

@notice
    provides the metadata for the storefront

### assets

```solidity
contract IStorage assets
```

### bannyUtil

```solidity
contract IBannyCommonUtil bannyUtil
```

### name

```solidity
string name
```

### constructor

```solidity
constructor(contract IStorage _assets, contract IBannyCommonUtil _bannyUtil, address _admin, string _name, string _contractURI) public
```

### setcontractURI

```solidity
function setcontractURI(string _contractURI) public
```

Sets the baseUri for the JBVeToken on IPFS.

    @param _contractURI The baseUri for the JBVeToken on IPFS.

### tokenURI

```solidity
function tokenURI(uint256 _tokenId, uint256 _amount, uint256 _duration, uint256, uint256[] _lockDurationOptions) public view returns (string)
```

Returns a fully qualified URI containing encoded token image data and metadata.

### _getFramedImage

```solidity
function _getFramedImage(uint256 _traits, uint256 _duration) internal view returns (string image)
```

### _getTokenRange

```solidity
function _getTokenRange(uint256 _amount) private pure returns (uint256)
```

### _getTokenStakeMultiplier

```solidity
function _getTokenStakeMultiplier(uint256 _duration, uint256[] _lockDurationOptions) private pure returns (uint256)
```

## ERR_CHUNK_SIZE_LIMIT

```solidity
error ERR_CHUNK_SIZE_LIMIT()
```

## ERR_ASSET_EXISTS

```solidity
error ERR_ASSET_EXISTS()
```

## ERR_ASSET_MISSING

```solidity
error ERR_ASSET_MISSING()
```

## ERR_INFLATE_FAILED

```solidity
error ERR_INFLATE_FAILED()
```

## Storage

### CHUNK_SIZE

```solidity
uint32 CHUNK_SIZE
```

### onlyOwner

```solidity
modifier onlyOwner()
```

### Asset

```solidity
struct Asset {
  uint64 _assetId;
  bytes32[] _nodes;
  uint64 _byteSize;
  mapping(string &#x3D;&gt; struct IStorage.Attr) _attrs;
}
```

### AssetCreated

```solidity
event AssetCreated(uint64 _assetId)
```

### AssetAttributeSet

```solidity
event AssetAttributeSet(uint64 _assetId, string _attrName)
```

### _owner

```solidity
address _owner
```

### _assetList

```solidity
mapping(uint64 => struct Storage.Asset) _assetList
```

### _assetCount

```solidity
uint64 _assetCount
```

### constructor

```solidity
constructor(address _admin) public
```

### createAsset

```solidity
function createAsset(uint64 _assetId, bytes32 _assetKey, bytes32[] _content, uint64 fileSizeInBytes) public
```

### appendAssetContent

```solidity
function appendAssetContent(uint64 _assetId, bytes32 _assetKey, bytes32[] _content) public
```

### setAssetAttribute

```solidity
function setAssetAttribute(uint64 _assetId, string _attrName, enum AssetAttrType _attrType, bytes32[] _value) public
```

### getAssetContentForId

```solidity
function getAssetContentForId(uint64 _assetId) public view returns (bytes)
```

### getAssetKeysForId

```solidity
function getAssetKeysForId(uint64 _assetId) public view returns (bytes32[])
```

### getContentForKey

```solidity
function getContentForKey(bytes32 _contentKey) public view returns (bytes32[])
```

### getAssetSize

```solidity
function getAssetSize(uint64 _assetId) public view returns (uint64)
```

### getAssetAttribute

```solidity
function getAssetAttribute(uint64 _assetId, string _attrName) public view returns (struct IStorage.Attr _attr)
```

### _bytesToUint

```solidity
function _bytesToUint(bytes b) internal pure returns (uint256)
```

## ARGUMENT_EMPTY

```solidity
error ARGUMENT_EMPTY(string)
```

## INVALID_PROOF

```solidity
error INVALID_PROOF()
```

## CLAIMS_EXHAUSTED

```solidity
error CLAIMS_EXHAUSTED()
```

## Token

### MINTER_ROLE

```solidity
bytes32 MINTER_ROLE
```

### assets

```solidity
contract IStorage assets
```

### bannyUtil

```solidity
contract IBannyCommonUtil bannyUtil
```

### tokenTraits

```solidity
mapping(uint256 => uint256) tokenTraits
```

Maps token id to packed traits definition.

### contractMetadataURI

```solidity
string contractMetadataURI
```

### merkleRoot

```solidity
bytes32 merkleRoot
```

### claimedMerkleAllowance

```solidity
mapping(address => uint256) claimedMerkleAllowance
```

Maps address to number of merkle claims that were executed.

### constructor

```solidity
constructor(contract IStorage _assets, contract IBannyCommonUtil _bannyUtil, address _admin, bytes32 _merkleRoot, string _name, string _symbol) public
```

### contractURI

```solidity
function contractURI() public view returns (string)
```

### tokenURI

```solidity
function tokenURI(uint256 _tokenId) public view returns (string)
```

### transferFrom

```solidity
function transferFrom(address _from, address _to, uint256 _tokenId) public
```

### safeTransferFrom

```solidity
function safeTransferFrom(address _from, address _to, uint256 _tokenId) public
```

### safeTransferFrom

```solidity
function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public
```

### dataUri

```solidity
function dataUri(uint256 _tokenId) internal view returns (string)
```

### merkleMint

```solidity
function merkleMint(uint256 _index, uint256 _allowance, bytes32[] _proof, uint256 _traits) external returns (uint256 tokenId)
```

Allows minting by anyone in the merkle root of the registered price resolver.

### supportsInterface

```solidity
function supportsInterface(bytes4 _interfaceId) public view returns (bool)
```

ERC165

### mint

```solidity
function mint(address _owner, uint256 _traits) public returns (uint256 tokenId)
```

@param _owner Address of the owner.
    @param _traits Packed NFT traits.

### addMinter

```solidity
function addMinter(address _account) public
```

### removeMinter

```solidity
function removeMinter(address _account) public
```

### setContractURI

```solidity
function setContractURI(string _uri) public
```

### withdrawEther

```solidity
function withdrawEther() public
```

### _getFramedImage

```solidity
function _getFramedImage(uint256 _traits) internal view returns (string image)
```

## AssetAttrType

```solidity
enum AssetAttrType {
  STRING_VALUE,
  BOOLEAN_VALUE,
  UINT_VALUE,
  INT_VALUE,
  TIMESTAMP_VALUE
}
```

## AssetDataType

```solidity
enum AssetDataType {
  AUDIO_MP3,
  IMAGE_SVG,
  IMAGE_PNG,
  RAW_DATA
}
```

## IBannyCommonUtil

### validateTraits

```solidity
function validateTraits(uint256) external pure returns (bool)
```

### getIndexedTokenTraits

```solidity
function getIndexedTokenTraits(uint256) external pure returns (uint256)
```

### getAssetBase64

```solidity
function getAssetBase64(contract IStorage, uint64, enum AssetDataType) external view returns (string)
```

### getImageStack

```solidity
function getImageStack(contract IStorage, uint256) external view returns (string)
```

### getTokenTraits

```solidity
function getTokenTraits(uint256) external pure returns (bytes)
```

### bodyTraits

```solidity
function bodyTraits(uint256) external pure returns (string)
```

### handsTraits

```solidity
function handsTraits(uint256) external pure returns (string)
```

### chokerTraits

```solidity
function chokerTraits(uint256) external pure returns (string)
```

### faceTraits

```solidity
function faceTraits(uint256) external pure returns (string)
```

### headgearTraits

```solidity
function headgearTraits(uint256) external pure returns (string)
```

### leftHandTraits

```solidity
function leftHandTraits(uint256) external pure returns (string)
```

### lowerTraits

```solidity
function lowerTraits(uint256) external pure returns (string)
```

### oralTraits

```solidity
function oralTraits(uint256) external pure returns (string)
```

### outfitTraits

```solidity
function outfitTraits(uint256) external pure returns (string)
```

### rightHandTraits

```solidity
function rightHandTraits(uint256) external pure returns (string)
```

## IJBVeTokenUriResolver

### INVALID_LOCK_DURATION

```solidity
error INVALID_LOCK_DURATION(uint256)
```

### contractURI

```solidity
function contractURI() external view returns (string)
```

@notice
    provides the metadata for the storefront

### tokenURI

```solidity
function tokenURI(uint256 _tokenId, uint256 _amount, uint256 _duration, uint256 _lockedUntil, uint256[] _lockDurationOptions) external view returns (string)
```

Computes the metadata url.
    @param _tokenId TokenId of the Banny
    @param _amount Lock Amount.
    @param _duration Lock time in seconds.
    @param _lockedUntil Total lock-in period.
    @param _lockDurationOptions The options that the duration can be.

    @return The metadata url.

## IStorage

### Attr

```solidity
struct Attr {
  enum AssetAttrType _type;
  bytes32[] _value;
}
```

### createAsset

```solidity
function createAsset(uint64 _assetId, bytes32 _assetKey, bytes32[] _content, uint64 fileSizeInBytes) external
```

### appendAssetContent

```solidity
function appendAssetContent(uint64 _assetId, bytes32 _assetKey, bytes32[] _content) external
```

### setAssetAttribute

```solidity
function setAssetAttribute(uint64 _assetId, string _attrName, enum AssetAttrType _attrType, bytes32[] _value) external
```

### getAssetContentForId

```solidity
function getAssetContentForId(uint64 _assetId) external view returns (bytes _content)
```

### getAssetKeysForId

```solidity
function getAssetKeysForId(uint64 _assetId) external view returns (bytes32[])
```

### getContentForKey

```solidity
function getContentForKey(bytes32 _contentKey) external view returns (bytes32[])
```

### getAssetSize

```solidity
function getAssetSize(uint64 _assetId) external view returns (uint64)
```

### getAssetAttribute

```solidity
function getAssetAttribute(uint64 _assetId, string _attr) external view returns (struct IStorage.Attr)
```

## IToken

### contractURI

```solidity
function contractURI() external view returns (string)
```

### mint

```solidity
function mint(address, uint256) external returns (uint256)
```

### merkleMint

```solidity
function merkleMint(uint256, uint256, bytes32[], uint256) external returns (uint256)
```

### setContractURI

```solidity
function setContractURI(string) external
```

### addMinter

```solidity
function addMinter(address) external
```

### removeMinter

```solidity
function removeMinter(address) external
```

### withdrawEther

```solidity
function withdrawEther() external
```

## Base64

_Provides a set of functions to operate with Base64 strings.

_Available since v4.5.__

### _TABLE

```solidity
string _TABLE
```

_Base64 Encoding/Decoding Table_

### encode

```solidity
function encode(bytes data) internal pure returns (string)
```

_Converts a `bytes` to its Bytes64 `string` representation._

## Bytecode

### InvalidCodeAtRange

```solidity
error InvalidCodeAtRange(uint256 _size, uint256 _start, uint256 _end)
```

### creationCodeFor

```solidity
function creationCodeFor(bytes _code) internal pure returns (bytes)
```

Generate a creation code that results on a contract with `_code` as bytecode
    @param _code The returning value of the resulting `creationCode`
    @return creationCode (constructor) for new contract

### codeSize

```solidity
function codeSize(address _addr) internal view returns (uint256 size)
```

Returns the size of the code on a given address
    @param _addr Address that may or may not contain code
    @return size of the code on the given `_addr`

### codeAt

```solidity
function codeAt(address _addr, uint256 _start, uint256 _end) internal view returns (bytes oCode)
```

Returns the code of a given address
    @dev It will fail if `_end < _start`
    @param _addr Address that may or may not contain code
    @param _start number of bytes of code to skip on read
    @param _end index before which to end extraction
    @return oCode read from `_addr` deployed bytecode

    Forked from: https://gist.github.com/KardanovIR/fe98661df9338c842b4a30306d507fbd

## ERC721Enumerable

openzeppelin ERC721Enumerable but using the rari-capital version

### _ownedTokens

```solidity
mapping(address => mapping(uint256 => uint256)) _ownedTokens
```

### _ownedTokensIndex

```solidity
mapping(uint256 => uint256) _ownedTokensIndex
```

### _allTokens

```solidity
uint256[] _allTokens
```

### _allTokensIndex

```solidity
mapping(uint256 => uint256) _allTokensIndex
```

### constructor

```solidity
constructor(string _name, string _symbol) internal
```

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

_See {IERC165-supportsInterface}._

### tokenOfOwnerByIndex

```solidity
function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256)
```

_See {IERC721Enumerable-tokenOfOwnerByIndex}._

### totalSupply

```solidity
function totalSupply() public view virtual returns (uint256)
```

_See {IERC721Enumerable-totalSupply}._

### tokenByIndex

```solidity
function tokenByIndex(uint256 index) public view virtual returns (uint256)
```

_See {IERC721Enumerable-tokenByIndex}._

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual
```

_Hook that is called before any token transfer. This includes minting
and burning.

Calling conditions:

- When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
transferred to `to`.
- When `from` is zero, `tokenId` will be minted for `to`.
- When `to` is zero, ``from``'s `tokenId` will be burned.
- `from` cannot be the zero address.
- `to` cannot be the zero address.

To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks]._

### _addTokenToOwnerEnumeration

```solidity
function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private
```

_Private function to add a token to this extension's ownership-tracking data structures._

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | address representing the new owner of the given token ID |
| tokenId | uint256 | uint256 ID of the token to be added to the tokens list of the given address |

### _addTokenToAllTokensEnumeration

```solidity
function _addTokenToAllTokensEnumeration(uint256 tokenId) private
```

_Private function to add a token to this extension's token tracking data structures._

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | uint256 ID of the token to be added to the tokens list |

### _removeTokenFromOwnerEnumeration

```solidity
function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private
```

_Private function to remove a token from this extension's ownership-tracking data structures. Note that
while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
gas optimizations e.g. when performing a transfer operation (avoiding double writes).
This has O(1) time complexity, but alters the order of the _ownedTokens array._

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | address representing the previous owner of the given token ID |
| tokenId | uint256 | uint256 ID of the token to be removed from the tokens list of the given address |

### _removeTokenFromAllTokensEnumeration

```solidity
function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private
```

_Private function to remove a token from this extension's token tracking data structures.
This has O(1) time complexity, but alters the order of the _allTokens array._

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | uint256 ID of the token to be removed from the tokens list |

## InflateLib

Based on https://github.com/madler/zlib/blob/master/contrib/puff

### MAXBITS

```solidity
uint256 MAXBITS
```

### MAXLCODES

```solidity
uint256 MAXLCODES
```

### MAXDCODES

```solidity
uint256 MAXDCODES
```

### MAXCODES

```solidity
uint256 MAXCODES
```

### FIXLCODES

```solidity
uint256 FIXLCODES
```

### ErrorCode

```solidity
enum ErrorCode {
  ERR_NONE,
  ERR_NOT_TERMINATED,
  ERR_OUTPUT_EXHAUSTED,
  ERR_INVALID_BLOCK_TYPE,
  ERR_STORED_LENGTH_NO_MATCH,
  ERR_TOO_MANY_LENGTH_OR_DISTANCE_CODES,
  ERR_CODE_LENGTHS_CODES_INCOMPLETE,
  ERR_REPEAT_NO_FIRST_LENGTH,
  ERR_REPEAT_MORE,
  ERR_INVALID_LITERAL_LENGTH_CODE_LENGTHS,
  ERR_INVALID_DISTANCE_CODE_LENGTHS,
  ERR_MISSING_END_OF_BLOCK,
  ERR_INVALID_LENGTH_OR_DISTANCE_CODE,
  ERR_DISTANCE_TOO_FAR,
  ERR_CONSTRUCT
}
```

### State

```solidity
struct State {
  bytes output;
  uint256 outcnt;
  bytes input;
  uint256 incnt;
  uint256 bitbuf;
  uint256 bitcnt;
  struct InflateLib.Huffman lencode;
  struct InflateLib.Huffman distcode;
}
```

### Huffman

```solidity
struct Huffman {
  uint256[] counts;
  uint256[] symbols;
}
```

### bits

```solidity
function bits(struct InflateLib.State s, uint256 need) private pure returns (enum InflateLib.ErrorCode, uint256)
```

### _stored

```solidity
function _stored(struct InflateLib.State s) private pure returns (enum InflateLib.ErrorCode)
```

### _decode

```solidity
function _decode(struct InflateLib.State s, struct InflateLib.Huffman h) private pure returns (enum InflateLib.ErrorCode, uint256)
```

### _construct

```solidity
function _construct(struct InflateLib.Huffman h, uint256[] lengths, uint256 n, uint256 start) private pure returns (enum InflateLib.ErrorCode)
```

### _codes

```solidity
function _codes(struct InflateLib.State s, struct InflateLib.Huffman lencode, struct InflateLib.Huffman distcode) private pure returns (enum InflateLib.ErrorCode)
```

### _build_fixed

```solidity
function _build_fixed(struct InflateLib.State s) private pure returns (enum InflateLib.ErrorCode)
```

### _fixed

```solidity
function _fixed(struct InflateLib.State s) private pure returns (enum InflateLib.ErrorCode)
```

### _build_dynamic_lengths

```solidity
function _build_dynamic_lengths(struct InflateLib.State s) private pure returns (enum InflateLib.ErrorCode, uint256[])
```

### _build_dynamic

```solidity
function _build_dynamic(struct InflateLib.State s) private pure returns (enum InflateLib.ErrorCode, struct InflateLib.Huffman, struct InflateLib.Huffman)
```

### _dynamic

```solidity
function _dynamic(struct InflateLib.State s) private pure returns (enum InflateLib.ErrorCode)
```

### puff

```solidity
function puff(bytes source, uint256 destlen) internal pure returns (enum InflateLib.ErrorCode, bytes)
```

