// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';

import './BannyBaseUtil.sol';

contract BannyAuctionMachineUtil is BannyBaseUtil {
  function getImageStack(string calldata _ipfsGateway, string calldata _ipfsRoot, uint256 traits)
    public
    pure
    returns (string memory image)
  {
    string[10] memory stack;
    uint64 contentId = uint64(uint8(traits) & 15);
    stack[0] = __imageTag(_ipfsGateway, _ipfsRoot, contentId); // bodyContent

    contentId = uint64(uint8(traits >> 4) & 15);
    if (contentId > 1) {
      stack[1] = __imageTag(_ipfsGateway, _ipfsRoot, contentId << 4); // handsContent
    }

    contentId = uint64(uint8(traits >> 8) & 15);
    if (contentId > 1) {
      stack[2] = __imageTag(_ipfsGateway, _ipfsRoot, contentId << 8); // chokerContent
    }

    contentId = uint64(uint8(traits >> 12)) << 12;
    stack[3] = __imageTag(_ipfsGateway, _ipfsRoot, contentId); // faceContent

    contentId = uint64(uint8(traits >> 20));
    if (contentId > 1) {
      stack[4] = __imageTag(_ipfsGateway, _ipfsRoot, contentId << 20); // headgearContent
    }

    contentId = uint64(uint8(traits >> 28));
    if (contentId > 1) {
      stack[5] = __imageTag(_ipfsGateway, _ipfsRoot, contentId << 28); // leftHandContent
    }

    contentId = uint64(uint8(traits >> 36) & 15) << 36;
    stack[6] = __imageTag(_ipfsGateway, _ipfsRoot, contentId); // lowerContent

    contentId = uint64(uint8(traits >> 40) & 15);
    if (contentId > 1) {
      stack[7] = __imageTag(_ipfsGateway, _ipfsRoot, contentId << 40); // oralContent
    }

    contentId = uint64(uint8(traits >> 44));
    if (contentId > 1) {
      stack[8] = __imageTag(_ipfsGateway, _ipfsRoot, contentId << 44); // outfitContent
    }

    contentId = uint64(uint8(traits >> 52));
    if (contentId > 1) {
      stack[9] = __imageTag(_ipfsGateway, _ipfsRoot, contentId << 52); // rightHandContent
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
    @notice Constructs and svg image tag by appending the parameters.

    @param _ipfsGateway HTTP IPFS gateway. The url must contain the trailing slash.
    @param _ipfsRoot IPFS path, must contain tailing slash.
    @param _imageIndex Image index that will be converted to string and used as a filename.
    */
  function __imageTag(string calldata _ipfsGateway, string calldata _ipfsRoot, uint256 _imageIndex) private pure returns (string memory tag) {
    tag = string(
      abi.encodePacked(
        '<image x="50%" y="50%" width="1000" href="',
        _ipfsGateway,
        _ipfsRoot,
        Strings.toString(_imageIndex),
        '" style="transform: translate(-500px, -500px)" />'
      )
    );
  }
}
