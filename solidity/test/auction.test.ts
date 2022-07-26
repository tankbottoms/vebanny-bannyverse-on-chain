import { expect } from 'chai';
import fs from 'fs';
import * as path from 'path';
import { ethers } from 'hardhat';
import { BigNumber } from 'ethers';
import { deployMockContract } from '@ethereum-waffle/mock-contract';

import { loadFile, loadLayers, traitsShiftOffset } from './banny';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

describe('Banny Auction Tests', () => {
    let deployer: SignerWithAddress;
    let projectTerminal: SignerWithAddress;
    let accounts: SignerWithAddress[];
    let auction: any;

    const projectId = 99;

    before(async () => {
        [deployer, projectTerminal, ...accounts] = await ethers.getSigners();

        const jbDirectoryABI = JSON.parse(fs.readFileSync('node_modules/@jbx-protocol/contracts-v2/deployments/mainnet/JBDirectory.json').toString())['abi'];

        const mockJbDirectory = await deployMockContract(deployer, jbDirectoryABI);
        await mockJbDirectory.mock.isTerminalOf.withArgs(projectId, projectTerminal.address).returns(true);
        //

        const bannyAuctionUtilFactory = await ethers.getContractFactory('BannyAuctionMachineUtil', deployer);
        const bannyAuctionUtilLibrary = await bannyAuctionUtilFactory.connect(deployer).deploy();
        await bannyAuctionUtilLibrary.deployed();

        const auctionFactory = await ethers.getContractFactory('BannyAuctionMachine');
        auction = await auctionFactory.connect(deployer).deploy(
            'Banny Auction',
            'BAMAMA',
            projectId,
            mockJbDirectory.address,
            bannyAuctionUtilLibrary.address,
            'https://ipfs.io/ipfs/',
            'bafybeia7kqlqrwue7v7vqtfr7ljgwm76yvt2aifv4sfp42sqlbp4qvlwsi/',
            10,
            300,
            ethers.utils.parseEther('0.0001'),
            'ipfs://metadata'
            );
        await auction.deployed();
    });

    it('Misc Tests', async () => {
        const traitList = [
            '5666264788816401'
            // '4522360314044945', '5507522789118481', '82086308641509905', '5542707163304465', '5560299290629137', '5577891476714001', '86642684769387025', '5577891476718097', '90090753293816337'
        ];
        
        for (const traits of traitList) {
            let imageData = await auction.previewTraits(traits);
            fs.writeFileSync(path.resolve('test-output', `auction-${traits}.svg`), imageData);
        }
    });
});
