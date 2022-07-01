import fs from 'fs';
import { ethers } from 'hardhat';
import { BigNumber } from 'ethers';

import { loadFile, loadLayers } from './banny';

describe('Banny Asset Storage Tests', () => {
    let storage: any;
    let deployer: any;
    let accounts: any[];
    let cumulativeGas = BigNumber.from(0);

    before(() => {
        if (!fs.existsSync('test-output')) {
            fs.mkdirSync('test-output');
        }
    })

    before(async () => {
        [deployer, ...accounts] = await ethers.getSigners();

        const storageFactory = await ethers.getContractFactory('Storage');
        storage = await storageFactory.connect(deployer).deploy();
        await storage.deployed();
    });

    it('Load PNG assets', async () => {
        const gas = await loadLayers(storage, deployer);
        console.log(`total gas: ${gas.toString()}`);
        cumulativeGas = cumulativeGas.add(gas);
    });

    it('Load font assets', async () => {
        const gas = await loadFile(storage, deployer, ['..', '..', 'fonts', 'Pixel Font-7-on-chain.woff'], '9223372036854775809');
        console.log(`total gas: ${gas.toString()}`);
        cumulativeGas = cumulativeGas.add(gas);
    });

    it('Cumulative Gas', async () => {
        console.log(`cumulative gas ${cumulativeGas.toString()}`)
    });
})