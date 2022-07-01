import { expect } from 'chai';
import fs from 'fs';
import * as path from 'path';
import { ethers } from 'hardhat';
import { BigNumber } from 'ethers';

import { loadLayers, traitsShiftOffset } from './banny';
import { AssetDataType } from './types';
import * as MerkleHelper from './components/MerkleHelper';

describe('BannyVerse Tests', () => {
    let storage: any;
    let token: any;
    let deployer: any;
    let accounts: any[];
    let merkleToken: any;
    let merkleSnapshot: { [key: string]: number };
    let merkleData: any;

    const merkleAddressOffset = 2;

    const basicBananaTraits = BigNumber.from(`0x1`) // Body, 0001
        .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Both_Hands'] / 4)}`) // 0001
        .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Choker'] / 4)}`) // 0001
        .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Face'] / 4)}`) // 00000001
        .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Headgear'] / 4)}`) // 00000001
        .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Left_Hand'] / 4)}`) // 00000001
        .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Lower_Accessory'] / 4)}`) // 0001
        .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Oral_Fixation'] / 4)}`) // 0001
        .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Outfit'] / 4)}`) // 00000001
        .add(`0x${(1).toString(16)}${('0').repeat(traitsShiftOffset['Right_Hand'] / 4)}`); // 1

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

        const bannyCommonUtilFactory = await ethers.getContractFactory('BannyCommonUtil', deployer);
        const bannyCommonUtilLibrary = await bannyCommonUtilFactory.connect(deployer).deploy();

        const merkleRoot = '0x0000000000000000000000000000000000000000000000000000000000000000';
        const tokenFactory = await ethers.getContractFactory('Token', {
            libraries: { BannyCommonUtil: bannyCommonUtilLibrary.address },
            signer: deployer
        });
        token = await tokenFactory.connect(deployer).deploy(storage.address, merkleRoot, 'Banana', 'NANA');
        await token.deployed();
    });

    before(async () => {
        merkleSnapshot = MerkleHelper.makeSampleSnapshot(accounts.filter((a, i) => i >= merkleAddressOffset).map(a => a.address));
        merkleData = MerkleHelper.buildMerkleTree(merkleSnapshot);

        const bannyCommonUtilFactory = await ethers.getContractFactory('BannyCommonUtil', deployer);
        const bannyCommonUtilLibrary = await bannyCommonUtilFactory.connect(deployer).deploy();

        const tokenFactory = await ethers.getContractFactory('Token', {
            libraries: { BannyCommonUtil: bannyCommonUtilLibrary.address },
            signer: deployer
        });
        merkleToken = await tokenFactory.connect(deployer).deploy(storage.address, merkleData.merkleRoot, 'Banana', 'NANA');
        await merkleToken.deployed();
    });

    it('Basic Mint Tests', async () => {
        const traits: any[] = [
            basicBananaTraits,

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

        let tokenId = 1;
        // for (const tokenTraits of traits) {
            const tokenTraits = traits[0];
            await expect(token.connect(deployer)
                .mint(accounts[0].address, tokenTraits))
                .to.emit(token, 'Transfer').withArgs(ethers.constants.AddressZero, accounts[0].address, tokenId);

            expect(await token.tokenTraits(tokenId)).to.equal(tokenTraits);

            expect(await token.ownerOf(tokenId)).to.equal(accounts[0].address);

            const dataUri = await token.tokenURI(tokenId);
            fs.writeFileSync(path.resolve('test-output', `${tokenId}-data.raw`), dataUri);

            let decoded = Buffer.from(dataUri.slice(('data:application/json;base64,').length), 'base64').toString();
            fs.writeFileSync(path.resolve('test-output', `${tokenId}-2.json`), decoded);

            let decodedJson = JSON.parse(decoded.toString());
            let imageData = Buffer.from(decodedJson['image'].slice(decodedJson['image'].indexOf(',') + 1), 'base64').toString();
            fs.writeFileSync(path.resolve('test-output', `${tokenId}-3.svg`), imageData);

            tokenId++;
        // }
    });

    it('Permissions Tests', async () => {
        await token.connect(deployer).addMinter(accounts[0].address);
        await token.connect(deployer).removeMinter(accounts[0].address);

        await token.connect(deployer).withdrawEther();
    });

    it('supportsInterface() Test', async () => {
        await token.supportsInterface('0x00000001');
    });

    it('Contract Metadata Tests', async () => {
        await expect(token.connect(deployer).setContractURI('')).to.be.revertedWith('ARGUMENT_EMPTY("_uri")');
        await token.connect(deployer).setContractURI('ipfs://metadata.json');

        expect(await token.contractURI()).to.equal('ipfs://metadata.json');
    });

    it('Transfer Tests', async () => {
        await token.connect(accounts[0]).transferFrom(accounts[0].address, accounts[1].address, 1);

        await token.connect(accounts[1])['safeTransferFrom(address,address,uint256)'](accounts[1].address, accounts[0].address, 1);

        await token.connect(accounts[0])['safeTransferFrom(address,address,uint256,bytes)'](accounts[0].address, accounts[1].address, 1, '0x00');
    });

    it('Merkle Mint Tests', async () => {
        const merkleAccount = accounts[merkleAddressOffset + 1];
        const merkleItem = merkleData.claims[merkleAccount.address];

        for (let i = 0; i < merkleItem.data; i++) {
            const tokenId = Number(await merkleToken.totalSupply()) + 1;

            await expect(merkleToken.connect(merkleAccount)
                .merkleMint(merkleItem.index, merkleItem.data, merkleItem.proof, basicBananaTraits))
                .to.emit(merkleToken, 'Transfer').withArgs(ethers.constants.AddressZero, merkleAccount.address, tokenId);

            expect(await merkleToken.tokenTraits(tokenId)).to.equal(basicBananaTraits);
            expect(await merkleToken.ownerOf(tokenId)).to.equal(merkleAccount.address);
        }

        await expect(merkleToken.connect(merkleAccount)
            .merkleMint(merkleItem.index, merkleItem.data, merkleItem.proof, basicBananaTraits))
            .to.be.revertedWith('CLAIMS_EXHAUSTED()');

        expect(await merkleToken.balanceOf(merkleAccount.address)).to.equal(merkleItem.data);

        await expect(merkleToken.connect(deployer)
            .merkleMint(merkleItem.index, merkleItem.data, merkleItem.proof, basicBananaTraits))
            .to.be.revertedWith('INVALID_PROOF()');

        await expect(merkleToken.connect(accounts[0])
            .merkleMint(merkleItem.index, merkleItem.data, merkleItem.proof, basicBananaTraits))
            .to.be.revertedWith('INVALID_PROOF()');
    }); 
});