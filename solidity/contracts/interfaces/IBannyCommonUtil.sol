// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './IStorage.sol';
import '../enums/AssetDataType.sol';

interface IBannyCommonUtil {
  function validateTraits(uint256) external pure returns (bool);

  function getIndexedTokenTraits(uint256) external pure returns (uint256);

  function getAssetBase64(IStorage, uint64, AssetDataType) external view returns (string memory);

  function getImageStack(IStorage, uint256) external view returns (string memory);

  function getTokenTraits(uint256) external pure returns (bytes memory);

  function bodyTraits(uint256) external pure returns (string memory);

  function handsTraits(uint256) external pure returns (string memory);

  function chokerTraits(uint256) external pure returns (string memory);

  function faceTraits(uint256) external pure returns (string memory);

  function headgearTraits(uint256) external pure returns (string memory);

  function leftHandTraits(uint256) external pure returns (string memory);

  function lowerTraits(uint256) external pure returns (string memory);

  function oralTraits(uint256) external pure returns (string memory);

  function outfitTraits(uint256) external pure returns (string memory);

  function rightHandTraits(uint256) external pure returns (string memory);
}
