// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import './libraries/Base64.sol';
import './interfaces/IBannyCommonUtil.sol';
import './interfaces/IStorage.sol';
import './enums/AssetDataType.sol';
import './BannyBaseUtil.sol';

contract BannyCommonUtil is BannyBaseUtil {
  function getAssetBase64(
    IStorage assets,
    uint64 _assetId,
    AssetDataType _assetType
  ) public view returns (string memory) {
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

  function getImageStack(IStorage assets, uint256 traits)
    public
    view
    returns (string memory image)
  {
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
    
    string[10] memory stack;
    uint64 contentId = uint64(uint8(traits) & 15);
    stack[0] = __imageTag(getAssetBase64(assets, contentId, AssetDataType.IMAGE_PNG)); // bodyContent

    contentId = uint64(uint8(traits >> 4) & 15);
    if (contentId > 1) {
      stack[1] = __imageTag(getAssetBase64(assets, contentId << 4, AssetDataType.IMAGE_PNG)); // handsContent
    }

    contentId = uint64(uint8(traits >> 8) & 15);
    if (contentId > 1) {
      stack[2] = __imageTag(getAssetBase64(assets, contentId << 8, AssetDataType.IMAGE_PNG)); // chokerContent
    }

    contentId = uint64(uint8(traits >> 12)) << 12;
    stack[3] = __imageTag(getAssetBase64(assets, contentId, AssetDataType.IMAGE_PNG)); // faceContent

    contentId = uint64(uint8(traits >> 20));
    if (contentId > 1) {
      stack[4] = __imageTag(getAssetBase64(assets, contentId << 20, AssetDataType.IMAGE_PNG)); // headgearContent
    }

    contentId = uint64(uint8(traits >> 28));
    if (contentId > 1) {
      stack[5] = __imageTag(getAssetBase64(assets, contentId << 28, AssetDataType.IMAGE_PNG)); // leftHandContent
    }

    contentId = uint64(uint8(traits >> 36) & 15) << 36;
    stack[6] = __imageTag(getAssetBase64(assets, contentId, AssetDataType.IMAGE_PNG)); // lowerContent

    contentId = uint64(uint8(traits >> 40) & 15);
    if (contentId > 1) {
      stack[7] = __imageTag(getAssetBase64(assets, contentId << 40, AssetDataType.IMAGE_PNG)); // oralContent
    }

    contentId = uint64(uint8(traits >> 44));
    if (contentId > 1) {
      stack[8] = __imageTag(getAssetBase64(assets, contentId << 44, AssetDataType.IMAGE_PNG)); // outfitContent
    }

    contentId = uint64(uint8(traits >> 52));
    if (contentId > 1) {
      stack[9] = __imageTag(getAssetBase64(assets, contentId << 52, AssetDataType.IMAGE_PNG)); // rightHandContent
    }

    image = string(
      abi.encodePacked(
        stack[0], // bodyContent
        stack[3], // faceContent
        stack[2], // chokerContent
        stack[6], // lowerContent
        stack[8], // outfitContent
        stack[7], // oralContent
        stack[4], // headgearContent
        /* 
        (stack[5] == 'Nothing' && stack[9] == 'Nothing) || stack[1] == 'Nothing' 
        // ensure that left and right are not occupied before allowing hands to be not Nothing
        */
        stack[5], // leftHandContent
        stack[9], // rightHandContent
        stack[1] // handsContent
      )
    );
  }

  /**
    @dev incoming parameter is wrapped blindly without checking content.
    */
  function __imageTag(string memory _content) private pure returns (string memory tag) {
    tag = string(
      abi.encodePacked(
        '<image x="50%" y="50%" width="1000" href="',
        _content,
        '" style="transform: translate(-500px, -500px)" />'
      )
    );
  }
}
