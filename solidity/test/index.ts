import { expect } from 'chai';
import fs from 'fs';
import * as path from 'path';
import { ethers } from 'hardhat';
import uuid4 from 'uuid4';
import { TransactionResponse } from '@ethersproject/abstract-provider';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { BigNumber } from 'ethers';

import { chunkAsset, chunkDeflate, chunkString, reconstituteString, smallIntToBytes32 } from './utils';

enum AssetDataType {
    AUDIO_MP3,
    IMAGE_SVG,
    IMAGE_PNG
}

enum AssetAttrType {
    STRING_VALUE,
    BOOLEAN_VALUE,
    UINT_VALUE,
    INT_VALUE,
    TIMESTAMP_VALUE
}

const traitsOffsets: { [key: string]: number } = {
    'Body': 0,
    'Both_Hands': 16,
    'Choker': 256,
    'Face': 4096,
    'Headgear': 1048576,
    'Left_Hand': 268435456,
    'Lower_Accessory': 68719476736,
    'Oral_Fixation': 1099511627776,
    'Outfit': 17592186044416,
    'Right_Hand': 4503599627370496
};

const traitsShiftOffset: { [key: string]: number } = {
    'Body': 0,
    'Both_Hands': 4,
    'Choker': 8,
    'Face': 12,
    'Headgear': 20,
    'Left_Hand': 28,
    'Lower_Accessory': 36,
    'Oral_Fixation': 40,
    'Outfit': 44,
    'Right_Hand': 52
};

describe("Bannyverse E2E", () => {
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

    it('Asset test', async () => {
        let trait = `0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Lower_Accessory'] / 4)}`;
        let result = await token.getAssetBase64(trait, AssetDataType.IMAGE_PNG);
        fs.writeFileSync(
            path.resolve('test-output', `${trait}.png`),
            Buffer.from(result.slice(('data:image/png;base64,').length), 'base64'));

        trait = `0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Outfit'] / 4)}`;
        result = await token.getAssetBase64(trait, AssetDataType.IMAGE_PNG);
        fs.writeFileSync(
            path.resolve('test-output', `${trait}.png`),
            Buffer.from(result.slice(('data:image/png;base64,').length), 'base64'));
    });

    it('Basic mint', async () => {
        const traits = BigNumber
            .from(`0x0`) // Body, 0000
            .add(`0x${(0).toString(16)}${('0').repeat(traitsShiftOffset['Both_Hands'] / 4)}`) // 0000
            .add(`0x${(2).toString(16)}${('0').repeat(traitsShiftOffset['Choker'] / 4)}`) // 0010
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Face'] / 4)}`) // 00000001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Headgear'] / 4)}`) // 00000001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Left_Hand'] / 4)}`) // 00000001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Lower_Accessory'] / 4)}`) // 0001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Oral_Fixation'] / 4)}`) // 0001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Outfit'] / 4)}`) // 00000001
            .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Right_Hand'] / 4)}`); // 1

        await token.connect(deployer).addMinter(deployer.address);

        const tokenId = 1;
        await expect(token.connect(deployer)
            .mint(accounts[0].address, traits))
            .to.emit(token, 'Transfer').withArgs(ethers.constants.AddressZero, accounts[0].address, tokenId);

        expect(await token.tokenTraits(tokenId)).to.equal(traits);

        const dataUri = await token.dataUri(tokenId);
        fs.writeFileSync(path.resolve('test-output', `${tokenId}-data.raw`), dataUri);

        let decoded = Buffer.from(dataUri.slice(('data:application/json;base64,').length), 'base64').toString();
        fs.writeFileSync(path.resolve('test-output', `${tokenId}-2.json`), decoded);

        let decodedJson = JSON.parse(decoded.toString());
        decodedJson['image'] = Buffer.from(decodedJson['image'].slice(0, -1), 'base64').toString();
        fs.writeFileSync(path.resolve('test-output', `${tokenId}-3.json`), JSON.stringify(decodedJson));

        // decoded = Buffer.from(dataUri.slice(('data:application/json;base64,').length), 'base64')
        // fs.writeFileSync(path.resolve('test-output', `${tokenId}-2.json`), decoded);

        // const tokenContentJSON = decodeURIComponent(dataUri.slice(('data:application/json;base64,').length).slice(0, -1));
        // fs.writeFileSync(path.resolve('test-output', `${tokenId}-2.json`), tokenContentJSON);

        // let decoded = decodeURIComponent(tokenContentJSON);
        // fs.writeFileSync(path.resolve('test-output', `${tokenId}-3.json`), decoded);
    });
});

async function loadLayers(storage: any, deployer: SignerWithAddress) {
    const layers = JSON.parse(fs.readFileSync('../layerOptions.json').toString());
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

    for (const group of Object.keys(layers)) {
        for (let i = 0; i < layers[group].length; i++) {
            const item = layers[group][i];
            if (item === 'Nothing') { continue; }

            const png = path.resolve(__dirname, '..', '..', 'layers', group, `${item}.png`);
            const id = traitsOffsets[group] + i;
            await loadAsset(storage, deployer, png, id.toString());
        }
    }
}

/**
 * 
 * @param storage Storage contract.
 * @param signer Account with permissions to add assets.
 * @param asset Fully qualified path of the file to load.
 * @param assetId Asset id to store the file as. WARNING: no validation, duplicates will fail, limit 64bit uint.
 */
async function loadAsset(storage: any, signer: SignerWithAddress, asset: string, assetId: string) {
    let assetParts: any;
    let inflatedSize = 0;

    if (asset.endsWith('svg')) {
        assetParts = chunkDeflate(asset);
        inflatedSize = assetParts.inflatedSize;
    } else {
        assetParts = chunkAsset(asset);
        inflatedSize = assetParts.length;
    }

    let sliceKey = '0x' + Buffer.from(uuid4(), 'utf-8').toString('hex').slice(-64);
    let tx: TransactionResponse = await storage.connect(signer).createAsset(assetId, sliceKey, assetParts.parts[0], assetParts.length, { gasLimit: 5_000_000 });
    await tx.wait();

    for (let i = 1; i < assetParts.parts.length; i++) {
        sliceKey = '0x' + Buffer.from(uuid4(), 'utf-8').toString('hex').slice(-64);
        tx = await storage.connect(signer).appendAssetContent(assetId, sliceKey, assetParts.parts[i], { gasLimit: 5_000_000 });
        await tx.wait();
    }

    // if (inflatedSize != assetParts.length) {
    //     tx = await storage.connect(signer).setAssetAttribute(0, '_inflatedSize', AssetAttrType.UINT_VALUE, [smallIntToBytes32(inflatedSize)]);
    //     await tx.wait();
    //     console.log(`added ${asset}, compressed ${assetParts.inflatedSize} to ${assetParts.length} as ${assetId}`);
    // } else {
    //     console.log(`added ${asset}, ${assetParts.length} as ${assetId}`);
    // }
}