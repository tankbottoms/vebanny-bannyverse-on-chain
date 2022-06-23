// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '../enums/AssetAttrType.sol';

interface IStorage {
    struct Attr {
        AssetAttrType _type;
        bytes32[] _value;
    }

    function createAsset(
        uint64 _assetId,
        bytes32 _assetKey,
        bytes32[] memory _content,
        uint64 fileSizeInBytes
    ) external;

    function appendAssetContent(
        uint64 _assetId,
        bytes32 _assetKey,
        bytes32[] calldata _content
    ) external;

    function setAssetAttribute(
        uint64 _assetId,
        string calldata _attrName,
        AssetAttrType _attrType,
        bytes32[] calldata _value
    ) external;

    function getAssetContentForId(uint64 _assetId) external view returns (bytes memory _content);

    function getAssetKeysForId(uint64 _assetId) external view returns (bytes32[] memory);

    function getContentForKey(bytes32 _contentKey) external view returns (bytes32[] memory);

    function getAssetSize(uint64 _assetId) external view returns (uint64);

    function getAssetAttribute(uint64 _assetId, string calldata _attr) external view returns (Attr memory);
}
