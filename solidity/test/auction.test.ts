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
    const auctionDuration = 300;
    const basePrice = ethers.utils.parseEther('0.0001');
    const lowPrice = ethers.utils.parseEther('0.00001');

    before(async () => {
        [deployer, projectTerminal, ...accounts] = await ethers.getSigners();

        const jbETHPaymentTerminalABI = JSON.parse(fs.readFileSync('node_modules/@jbx-protocol/contracts-v2/deployments/mainnet/JBETHPaymentTerminal.json').toString())['abi'];

        const mockJbTerminal = await deployMockContract(deployer, jbETHPaymentTerminalABI);
        await mockJbTerminal.mock.pay.returns(1);

        const bannyAuctionUtilFactory = await ethers.getContractFactory('BannyAuctionMachineUtil', deployer);
        const bannyAuctionUtilLibrary = await bannyAuctionUtilFactory.connect(deployer).deploy();
        await bannyAuctionUtilLibrary.deployed();

        const auctionFactory = await ethers.getContractFactory('BannyAuctionMachine');
        auction = await auctionFactory.connect(deployer).deploy(
            'Banny Auction',
            'BAMAMA',
            projectId,
            mockJbTerminal.address,
            bannyAuctionUtilLibrary.address,
            'https://ipfs.io/ipfs/',
            'bafybeia7kqlqrwue7v7vqtfr7ljgwm76yvt2aifv4sfp42sqlbp4qvlwsi/',
            10,
            auctionDuration,
            basePrice,
            'ipfs://metadata'
            );
        await auction.deployed();
    });

    it('Auction Tests: first auction', async () => {
        let tx = auction.connect(accounts[0]).bid({value: basePrice});
        await expect(tx).to.emit(auction, 'AuctionStarted');

        await expect(auction.connect(accounts[0]).bid({value: lowPrice})).to.be.revertedWith('INVALID_BID()');
        await expect(auction.connect(accounts[0]).bid({value: basePrice})).to.be.revertedWith('INVALID_BID()');

        await ethers.provider.send('evm_increaseTime', [auctionDuration / 2]);
        await ethers.provider.send('evm_mine', []);

        let timeLeft = await auction.timeLeft();
        expect(Number(timeLeft)).to.be.lessThanOrEqual(auctionDuration / 2);

        await ethers.provider.send('evm_increaseTime', [Math.ceil(auctionDuration / 2) + 10]);
        await ethers.provider.send('evm_mine', []);

        timeLeft = await auction.timeLeft();
        expect(Number(timeLeft)).to.be.equal(0);
        await expect(auction.connect(accounts[1]).bid({value: basePrice.mul(2)})).to.be.revertedWith('AUCTION_ENDED()');

        await expect(auction.settle()).to.emit(auction, 'AuctionEnded');

        expect(await auction.balanceOf(accounts[0].address)).to.equal(1);

        await ethers.provider.send('evm_mine', []);

        timeLeft = await auction.timeLeft();
        expect(Number(timeLeft)).to.be.greaterThan(auctionDuration - 20);
    });

    it('Auction Tests: second auction', async () => {
        await auction.connect(accounts[0]).bid({value: basePrice});

        let tx = auction.connect(accounts[1]).bid({value: basePrice.mul(2)});
        await expect(tx).to.emit(auction, 'Bid');

        await expect(auction.settle()).to.be.revertedWith('AUCTION_ACTIVE()');

        await ethers.provider.send('evm_increaseTime', [auctionDuration + 10]);
        await ethers.provider.send('evm_mine', []);

        const totalSupply = Number(await auction.totalSupply());
        await expect(auction.settle()).to.emit(auction, 'Transfer').withArgs(ethers.constants.AddressZero, accounts[1].address, totalSupply + 1);

        expect(await auction.balanceOf(accounts[0].address)).to.equal(1);
        expect(await auction.balanceOf(accounts[1].address)).to.equal(1);
    });

    it('Auction Tests: auction without bids', async () => {
        await ethers.provider.send('evm_increaseTime', [auctionDuration + 10]);
        await ethers.provider.send('evm_mine', []);

        await auction.settle();

        expect(await auction.balanceOf(deployer.address)).to.equal(1);

        const totalSupply = Number(await auction.totalSupply());
        await expect(auction.connect(deployer).giftToken(accounts[2].address, totalSupply))
            .to.emit(auction, 'Transfer').withArgs(deployer.address, accounts[2].address, totalSupply);
        expect(await auction.ownerOf(totalSupply)).to.equal(accounts[2].address);
    });

    it('TokenURI', async () => {
        const totalSupply = Number(await auction.totalSupply());
        expect(totalSupply).to.equal(3);

        const hashes: any = {};
        for (let i = 1; i <= totalSupply; i++) {
            const imageData = await auction.tokenURI(i);
            expect(imageData.length).to.be.greaterThanOrEqual(100);

            const hash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(imageData));
            hashes[hash] = hash;
        }

        expect(Object.keys(hashes).length).to.equal(totalSupply);
    });

    // TODO: test payments

    it('Privileged Operation Tests', async () => {
        await expect(auction.connect(accounts[0]).setPaymentTerminal(accounts[0].address))
            .to.be.revertedWith('Ownable: caller is not the owner');

        const currentTerminal = await auction.jbxTerminal();
        await auction.connect(deployer).setPaymentTerminal(accounts[0].address);
        expect(await auction.jbxTerminal()).to.not.equal(currentTerminal);


        await expect(auction.connect(accounts[0]).setIPFSGatewayURI('https://'))
            .to.be.revertedWith('Ownable: caller is not the owner');

        const currentIPFSGateway = await auction.ipfsGateway();
        await auction.setIPFSGatewayURI('https://');
        expect(await auction.ipfsGateway()).to.not.equal(currentIPFSGateway);

        await expect(auction.connect(accounts[0]).setIPFSRoot('../'))
            .to.be.revertedWith('Ownable: caller is not the owner');

        const currentIPFSRoot = await auction.ipfsRoot();
        await auction.setIPFSRoot('../');
        expect(await auction.ipfsRoot()).to.not.equal(currentIPFSRoot);

        await expect(auction.connect(accounts[0]).setIPFSRoot('../'))
            .to.be.revertedWith('Ownable: caller is not the owner');

        const currentContractUri = await auction.contractURI();
        await auction.setContractURI('ipfs://');
        expect(await auction.contractURI()).to.not.equal(currentContractUri);
    });

    it('Trait Tests', async () => {
        const traitList: string[] = [
            '5666264788816401',
            // '4522360314044945',
            // '5507522789118481',
            // '82086308641509905',
            // '5542707163304465',
            // '5560299290629137',
            // '5577891476714001',
            // '86642684769387025',
            // '5577891476718097',
            // '90090753293816337'
        ];

        for (const traits of traitList) {
            let imageData = await auction.previewTraits(traits);
            fs.writeFileSync(path.resolve('test-output', `auction-${traits}.svg`), imageData);
        }
    });
});
