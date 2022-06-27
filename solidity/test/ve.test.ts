import { expect } from 'chai';
import fs from 'fs';
import * as path from 'path';
import { ethers } from 'hardhat';

import { loadFont, loadLayers, processCharacters } from './banny';

describe("veBanny URI Resolver Tests", () => {
    let storage: any;
    let uriResolver: any;
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

        await loadFont(storage, deployer, 'Pixel Font-7-on-chain.woff', '9223372036854775809');
        await loadLayers(storage, deployer);

        const uriResolverFactory = await ethers.getContractFactory('JBVeTokenUriResolver');
        uriResolver = await uriResolverFactory.connect(deployer).deploy(storage.address, 'Escrow Banana', 'ipfs://metadata');
        await uriResolver.deployed();
    });

    it('Character Definition Tests', async () => {
        // const characters = processCharacters();
        // fs.writeFileSync(path.resolve('test-output', 'processedCharacters.json'), JSON.stringify(characters));

        // let traitsMap: string = '';
        // for (const c of Object.keys(characters)) {
        //     traitsMap += `[${c}] = ${characters[c]['layers']}; `;
        // }
        // fs.writeFileSync(path.resolve('test-output', 'traitsMap.txt'), traitsMap);

        const durations: number[] = [60*60*24*10, 60*60*24*30, 60*60*24*365]; // TODO: need actual valid durations

        for (let i = 0; i < durations.length; i++) {
            const tokenUri = await uriResolver.tokenURI(i, 1_000_000, durations[i], 0, durations);
            const decoded = Buffer.from(tokenUri.slice(('data:application/json;base64,').length), 'base64').toString();
            const json = JSON.parse(decoded.toString());
            const imageData = Buffer.from(json['image'].slice(json['image'].indexOf(',') + 1), 'base64').toString();
            fs.writeFileSync(path.resolve('test-output', `ve-${durations[i]}.svg`), imageData);

            // TODO: 'expect()' results
        }
    });
});
