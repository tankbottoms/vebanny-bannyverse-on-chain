import { expect } from 'chai';
import fs from 'fs';
import * as path from 'path';
import { ethers } from 'hardhat';

import { loadLayers, processCharacters } from './banny';

describe("veBanny E2E", () => {
    let storage: any;
    let token: any;
    let deployer: any;
    let accounts: any[];

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

        await loadLayers(storage, deployer);

        const tokenFactory = await ethers.getContractFactory('Token');
        token = await tokenFactory.connect(deployer).deploy(storage.address, 'Escrow Banana', 'veNANA');
        await token.deployed();
    });

    it('Character mint', async () => {
        const characters = processCharacters();

        const testCharacters: string[] = [];
        while (testCharacters.length < 10) {
            testCharacters.push(Math.floor(Math.random() * 75 + 1).toString());
        }

        await token.connect(deployer).addMinter(deployer.address);

        let tokenId = 1;
        for (const c of testCharacters) {
            console.log(`minting ${c}:${characters[c]['metadata']['name']}, ${characters[c].layers}`);
            await expect(token.connect(deployer)
                .mint(accounts[0].address, characters[c].layers))
                .to.emit(token, 'Transfer').withArgs(ethers.constants.AddressZero, accounts[0].address, tokenId);

            expect(await token.tokenTraits(tokenId)).to.equal(characters[c].layers);

            tokenId++;
        }

        tokenId = 1;
        for (const c of testCharacters) {
            console.log(`dumping ${c}:${characters[c]['metadata']['name']}, ${characters[c].layers}`);
            const dataUri = await token.dataUri(tokenId);
            const decoded = Buffer.from(dataUri.slice(('data:application/json;base64,').length), 'base64').toString();
            const json = JSON.parse(decoded.toString());
            const imageData = Buffer.from(json['image'].slice(json['image'].indexOf(',') + 1), 'base64').toString();
            fs.writeFileSync(path.resolve('test-output', `${c}-${characters[c].layers}.svg`), imageData);
            tokenId++;
        }
    });
});
