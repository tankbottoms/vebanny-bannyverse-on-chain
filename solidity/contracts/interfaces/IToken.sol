// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '../enums/AssetDataType.sol';

interface IToken {
    function contractURI() external view returns (string memory);

    function mint(address, uint256) external returns (uint256);

    function setContractURI(string calldata) external;

    function addMinter(address) external;

    function removeMinter(address) external;

    function dataUri(uint256) external view returns (string memory);

    function withdrawEther() external;
}
