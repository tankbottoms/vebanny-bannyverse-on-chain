// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import './Storage.sol';
import './BannyCommonUtil.sol';
import './Token.sol';

contract Deployer {
    constructor(bytes32 _merkleRoot, string memory _name, string memory _symbol, address _admin) {
        Storage s = new Storage(_admin);
        BannyCommonUtil b = new BannyCommonUtil();
        Token t = new Token(s, b, _admin, _merkleRoot, _name, _symbol);
    }    
}
