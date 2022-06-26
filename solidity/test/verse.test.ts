/* eslint-disable dot-notation */
/* eslint-disable prettier/prettier */
/* eslint-disable node/no-missing-import */
import { expect } from 'chai';
import fs from 'fs';
import * as path from 'path';
import { ethers } from 'hardhat';
import { BigNumber } from 'ethers';

import { loadLayers, traitsShiftOffset } from './banny';
import { AssetDataType } from './types';

describe("BannyVerse E2E", () => {
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
        token = await tokenFactory.connect(deployer).deploy(storage.address, 'Banana', 'NANA');
        await token.deployed();
    });

    it('Asset Storage Tests', async () => {
        const traits = [
            `0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Lower_Accessory'] / 4)}`,
            `0x${(17).toString(16)}${('0').repeat(traitsShiftOffset['Outfit'] / 4)}`,
            `0x${(2).toString(16)}${('0').repeat(traitsShiftOffset['Right_Hand'] / 4)}`
        ];

        for (const trait of traits) {
            const result = await token.getAssetBase64(storage.address, trait, AssetDataType.IMAGE_PNG);
            fs.writeFileSync(
                path.resolve('test-output', `${trait}.png`),
                Buffer.from(result.slice(('data:image/png;base64,').length), 'base64'));
        }
    });

    it('Basic Mint Tests', async () => {
        const traits: any[] = [
            BigNumber.from(`0x1`) // Body, 0001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Both_Hands'] / 4)}`) // 0001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Choker'] / 4)}`) // 0001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Face'] / 4)}`) // 00000001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Headgear'] / 4)}`) // 00000001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Left_Hand'] / 4)}`) // 00000001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Lower_Accessory'] / 4)}`) // 0001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Oral_Fixation'] / 4)}`) // 0001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Outfit'] / 4)}`) // 00000001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Right_Hand'] / 4)}`), // 1

            BigNumber.from(`0x2`)
            .add(`0x${(2).toString(16)}${('0').repeat(traitsShiftOffset['Both_Hands'] / 4)}`)
            .add(`0x${(2).toString(16)}${('0').repeat(traitsShiftOffset['Choker'] / 4)}`)
            .add(`0x${(3).toString(16)}${('0').repeat(traitsShiftOffset['Face'] / 4)}`)
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Headgear'] / 4)}`)
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Left_Hand'] / 4)}`)
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Lower_Accessory'] / 4)}`)
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Oral_Fixation'] / 4)}`)
            .add(`0x${(6).toString(16)}${('0').repeat(traitsShiftOffset['Outfit'] / 4)}`)
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Right_Hand'] / 4)}`),

            BigNumber.from(`0x5`)
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Both_Hands'] / 4)}`)
            .add(`0x${(3).toString(16)}${('0').repeat(traitsShiftOffset['Choker'] / 4)}`)
            .add(`0x${(8).toString(16)}${('0').repeat(traitsShiftOffset['Face'] / 4)}`)
            .add(`0x${(11).toString(16)}${('0').repeat(traitsShiftOffset['Headgear'] / 4)}`)
            .add(`0x${(5).toString(16)}${('0').repeat(traitsShiftOffset['Left_Hand'] / 4)}`)
            .add(`0x${(2).toString(16)}${('0').repeat(traitsShiftOffset['Lower_Accessory'] / 4)}`)
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Oral_Fixation'] / 4)}`)
            .add(`0x${(18).toString(16)}${('0').repeat(traitsShiftOffset['Outfit'] / 4)}`)
            .add(`0x${(2).toString(16)}${('0').repeat(traitsShiftOffset['Right_Hand'] / 4)}`),

            BigNumber.from(`0x3`)
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Both_Hands'] / 4)}`)
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Choker'] / 4)}`)
            .add(`0x${(4).toString(16)}${('0').repeat(traitsShiftOffset['Face'] / 4)}`)
            .add(`0x${(7).toString(16)}${('0').repeat(traitsShiftOffset['Headgear'] / 4)}`)
            .add(`0x${(2).toString(16)}${('0').repeat(traitsShiftOffset['Left_Hand'] / 4)}`)
            .add(`0x${(4).toString(16)}${('0').repeat(traitsShiftOffset['Lower_Accessory'] / 4)}`)
            .add(`0x${(3).toString(16)}${('0').repeat(traitsShiftOffset['Oral_Fixation'] / 4)}`)
            .add(`0x${(8).toString(16)}${('0').repeat(traitsShiftOffset['Outfit'] / 4)}`)
            .add(`0x${(3).toString(16)}${('0').repeat(traitsShiftOffset['Right_Hand'] / 4)}`),
        ];

        await token.connect(deployer).addMinter(deployer.address);

        let tokenId = 1;
        for (const tokenTraits of traits) {
            const tokenTraits = traits[0];
            await expect(token.connect(deployer)
                .mint(accounts[0].address, tokenTraits))
                .to.emit(token, 'Transfer').withArgs(ethers.constants.AddressZero, accounts[0].address, tokenId);

            expect(await token.tokenTraits(tokenId)).to.equal(tokenTraits);

            expect(await token.ownerOf(tokenId)).to.equal(accounts[0].address);

            const dataUri = await token.dataUri(tokenId);
            fs.writeFileSync(path.resolve('test-output', `${tokenId}-data.raw`), dataUri);

            const decoded = Buffer.from(dataUri.slice(('data:application/json;base64,').length), 'base64').toString();
            fs.writeFileSync(path.resolve('test-output', `${tokenId}-2.json`), decoded);

            const decodedJson = JSON.parse(decoded.toString());
            const imageData = Buffer.from(decodedJson['image'].slice(decodedJson['image'].indexOf(',') + 1), 'base64').toString();
            fs.writeFileSync(path.resolve('test-output', `${tokenId}-3.svg`), imageData);

            tokenId++;
        }
    });
});