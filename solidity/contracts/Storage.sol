// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '@0xsequence/sstore2/contracts/SSTORE2Map.sol';

import './interfaces/IStorage.sol';
import './enums/AssetAttrType.sol';
import './libraries/InflateLib.sol';

error ERR_CHUNK_SIZE_LIMIT();
error ERR_ASSET_EXISTS();
error ERR_ASSET_MISSING();
error ERR_INFLATE_FAILED();

contract Storage is IStorage {
    uint32 private constant CHUNK_SIZE = 24 * 1024;

    modifier onlyOwner() {
        require(_owner == msg.sender, 'msg.sender!=_owner');
        _;
    }

    struct Asset {
        uint64 _assetId;
        bytes32[] _nodes;
        uint64 _byteSize;
        mapping(string => Attr) _attrs;
        // TODO: consider, bool _complete;
    }

    // TODO: consider name -> id map
    // TODO: consider auto-increment on assetid

    event AssetCreated(uint64 _assetId);
    event AssetAttributeSet(uint64 _assetId, string _attrName);

    address private _owner;
    mapping(uint64 => Asset) private _assetList;
    uint64 private _assetCount;

    constructor(address _admin) {
        _owner = _admin;
    }

    function createAsset(
        uint64 _assetId,
        bytes32 _assetKey,
        bytes32[] memory _content,
        uint64 fileSizeInBytes
    ) public override onlyOwner {
        if (_content.length > CHUNK_SIZE / 32) {
            revert ERR_CHUNK_SIZE_LIMIT();
        }
        if (_assetList[_assetId]._assetId != 0) {
            revert ERR_ASSET_EXISTS();
        }

        SSTORE2Map.write(_assetKey, abi.encode(_content));

        _assetList[_assetId]._assetId = _assetId;
        _assetList[_assetId]._nodes.push(_assetKey);
        _assetList[_assetId]._byteSize = uint64(fileSizeInBytes);

        ++_assetCount;
        emit AssetCreated(_assetId);
    }

    function appendAssetContent(
        uint64 _assetId,
        bytes32 _assetKey,
        bytes32[] calldata _content
    ) public override onlyOwner {
        if (_content.length > CHUNK_SIZE / 32) {
            revert ERR_CHUNK_SIZE_LIMIT();
        }
        if (_assetList[_assetId]._assetId == 0 && _assetList[_assetId]._byteSize == 0) {
            revert ERR_ASSET_MISSING();
        }

        SSTORE2Map.write(_assetKey, abi.encode(_content));

        _assetList[_assetId]._nodes.push(_assetKey);
    }

    function setAssetAttribute(
        uint64 _assetId,
        string calldata _attrName,
        AssetAttrType _attrType,
        bytes32[] calldata _value
    ) public override onlyOwner {
        _assetList[_assetId]._attrs[_attrName]._type = _attrType;
        _assetList[_assetId]._attrs[_attrName]._value = _value;

        emit AssetAttributeSet(_assetId, _attrName);
        // reserved:
        // uint32 _type
        // string _name
        // uint64 _timestamp
        // uint64 _inflatedSize
    }

    function getAssetContentForId(uint64 _assetId) public view override returns (bytes memory) {
        uint64 inflatedSize = 0;
        if (_assetList[_assetId]._attrs['_inflatedSize']._value.length > 0) {
            inflatedSize = uint64(_bytesToUint(abi.encode(_assetList[_assetId]._attrs['_inflatedSize']._value)));
        }

        bytes memory _content = new bytes(_assetList[_assetId]._byteSize);
        uint64 partCount = uint64(_assetList[_assetId]._nodes.length);

        uint64 offset = 0;
        for (uint64 i = 0; i < partCount; i++) {
            bytes32[] memory partContent = getContentForKey(_assetList[_assetId]._nodes[i]);

            for (uint16 j = 0; j < partContent.length; j++) {
                bytes32 slice = partContent[j];
                for (uint16 k = 0; (offset + k < _assetList[_assetId]._byteSize) && k < 32; k++) {
                    _content[offset + k] = slice[k];
                }
                offset += 32;
            }
        }

        if (inflatedSize > 0) {
            InflateLib.ErrorCode err;
            bytes memory result;
            (err, result) = InflateLib.puff(_content, inflatedSize);

            if (err != InflateLib.ErrorCode.ERR_NONE) { revert ERR_INFLATE_FAILED(); }

            return result;
        }

        return _content;
    }

    function getAssetKeysForId(uint64 _assetId) public view override returns (bytes32[] memory) {
        return _assetList[_assetId]._nodes;
    }

    function getContentForKey(bytes32 _contentKey) public view override returns (bytes32[] memory) {
        return abi.decode(SSTORE2Map.read(_contentKey), (bytes32[]));
    }

    function getAssetSize(uint64 _assetId) public view override returns (uint64) {
        return _assetList[_assetId]._byteSize;
    }

    function getAssetAttribute(uint64 _assetId, string calldata _attrName) public view override returns (Attr memory _attr) {
        _attr = _assetList[_assetId]._attrs[_attrName];
    }

    function _bytesToUint(bytes memory b) internal pure returns (uint256) {
        uint256 number;

        for (uint i=0; i < b.length; i++) {
            number = number + uint(uint8(b[i]))*(2**(8*(b.length-(i+1))));
        }

        return number;
    }
}
