import { expect } from 'chai';
import fs from 'fs';
import * as path from 'path';
import { ethers } from 'hardhat';
import { BigNumber } from 'ethers';
import { deployMockContract } from '@ethereum-waffle/mock-contract';

import { loadFile, loadLayers, traitsShiftOffset } from './banny';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

describe('BannyVerse Tests', () => {
    let storage: any;
    let delegate: any;
    let deployer: SignerWithAddress;
    let projectTerminal: SignerWithAddress;
    let accounts: SignerWithAddress[];

    const projectId = 99;
    const maxSupply = 10;
    const tierPrices = [ // NOTE: this list must have the same length as JBBannyRewardDelegate.tierTraits
        ethers.utils.parseEther('0.000000000001'),
        ethers.utils.parseEther('0.00000000001'),
        ethers.utils.parseEther('0.0000000001'),
        ethers.utils.parseEther('0.000000001'),
        ethers.utils.parseEther('0.00000001'),
        ethers.utils.parseEther('0.0000001'),
        ethers.utils.parseEther('0.000001'),
        ethers.utils.parseEther('0.00001'),
        ethers.utils.parseEther('0.0001'),
        ethers.utils.parseEther('0.001'),
        ethers.utils.parseEther('0.01'),
        ethers.utils.parseEther('0.1'),
        ethers.utils.parseEther('1'),
    ];
    const contributionToken = '0x000000000000000000000000000000000000EEEe' // JBTokens.ETH
    const name = 'Reward Banana';
    const symbol = 'RANA';
    const metadataUri = 'ipfs://somewhere'

    before(() => {
        if (!fs.existsSync('test-output')) {
            fs.mkdirSync('test-output');
        }
    })

    before(async () => {
        [deployer, projectTerminal, ...accounts] = await ethers.getSigners();

        const storageFactory = await ethers.getContractFactory('Storage');
        storage = await storageFactory.connect(deployer).deploy(deployer.address);
        await storage.deployed();

        const jbDirectoryABI = JSON.parse(fs.readFileSync('node_modules/@jbx-protocol/contracts-v2/deployments/mainnet/JBDirectory.json').toString())['abi'];

        const mockJbDirectory = await deployMockContract(deployer, jbDirectoryABI);
        await mockJbDirectory.mock.isTerminalOf.withArgs(projectId, projectTerminal.address).returns(true);
        await mockJbDirectory.mock.isTerminalOf.withArgs(projectId, deployer.address).returns(false);

        await loadLayers(storage, deployer);

        const bannyCommonUtilFactory = await ethers.getContractFactory('BannyCommonUtil', deployer);
        const bannyCommonUtilLibrary = await bannyCommonUtilFactory.connect(deployer).deploy();
        await bannyCommonUtilLibrary.deployed();

        const delegateFactory = await ethers.getContractFactory('JBBannyRewardDelegate');
        delegate = await delegateFactory.connect(deployer).deploy(
            projectId,
            mockJbDirectory.address,
            maxSupply,
            tierPrices,
            contributionToken,
            name,
            symbol,
            metadataUri,
            deployer.address,
            storage.address,
            bannyCommonUtilLibrary.address);
        await delegate.deployed();
    });

    it('JBBannyRewardDelegate.didPay', async () => {
        const contributor = accounts[0];
        const contribution = {
            payer: contributor.address,
            projectId,
            currentFundingCycleConfiguration: 0,
            amount: { token: contributionToken, value: ethers.utils.parseEther('1'), decimals: 18, currency: 1 },
            projectTokenCount: 0,
            beneficiary: contributor.address,
            preferClaimedTokens: false,
            memo: '',
            metadata: '0x42'
        };

        let tokenId = 1;
        await expect(delegate.connect(projectTerminal)
            .didPay(contribution))
            .to.emit(delegate, 'Transfer').withArgs(ethers.constants.AddressZero, contributor.address, tokenId);

        expect(await delegate.isOwner(contributor.address, tokenId)).to.equal(true);
        expect(await delegate.tokenTraits(tokenId)).to.be.equal('4926980593054225');
        expect(await delegate.tokenSupply(tokenId)).to.equal(1);
        expect(await delegate.totalOwnerBalance(contributor.address)).to.equal(1);
        expect(await delegate.ownerTokenBalance(contributor.address, tokenId)).to.equal(1);
        expect(await delegate.isOwner(contributor.address, tokenId)).to.equal(true);

        contribution.amount.value = ethers.utils.parseEther('0.0000000000001');
        await expect(delegate.connect(projectTerminal)
            .didPay(contribution))
            .to.not.emit(delegate, 'Transfer');

        contribution.amount.value = ethers.utils.parseEther('1');
        contribution.amount.token = ethers.constants.AddressZero;
        await expect(delegate.connect(projectTerminal)
            .didPay(contribution))
            .to.not.emit(delegate, 'Transfer');

        await expect(delegate.connect(deployer)
            .didPay(contribution))
            .to.be.revertedWith('INVALID_PAYMENT_EVENT()');
    });

    it('JBBannyRewardDelegate.tokenURI Tests', async () => {
        const tokenId = 1;
        const dataUri = await delegate.tokenURI(tokenId);
        fs.writeFileSync(path.resolve('test-output', `${tokenId}-data.raw`), dataUri);
    });

    it('JBBannyRewardDelegate.transfer Tests', async () => {
        const contributor = accounts[0];
        const beneficiary = accounts[1];
        const receiver = accounts[2];
        const contribution = {
            payer: contributor.address,
            projectId,
            currentFundingCycleConfiguration: 0,
            amount: { token: contributionToken, value: ethers.utils.parseEther('1'), decimals: 18, currency: 1 },
            projectTokenCount: 0,
            beneficiary: beneficiary.address,
            preferClaimedTokens: false,
            memo: '',
            metadata: '0x42'
        };

        const tokenId = Number(await delegate.totalSupply()) + 1;

        await expect(delegate.connect(projectTerminal)
            .didPay(contribution))
            .to.emit(delegate, 'Transfer').withArgs(ethers.constants.AddressZero, beneficiary.address, tokenId);
        
        await expect(
            delegate.connect(beneficiary).transfer(receiver.address, tokenId)
        ).to.emit(delegate, 'Transfer').withArgs(beneficiary.address, receiver.address, tokenId);

        await expect(
            delegate.connect(accounts[3]).transferFrom(receiver.address, accounts[3].address, tokenId)
        ).to.be.revertedWith('NOT_AUTHORIZED');

        await delegate.connect(receiver).approve(accounts[3].address, tokenId);

        await expect(
            delegate.connect(accounts[3]).transferFrom(receiver.address, accounts[3].address, tokenId)
        ).to.emit(delegate, 'Transfer').withArgs(receiver.address, accounts[3].address, tokenId);
    });

    it('Misc Tests', async () => {
        await delegate.totalSupply();

        await expect(delegate.connect(accounts[0])
            .setContractUri('ipfs://'))
            .to.be.revertedWith('Ownable: caller is not the owner');

        await expect(delegate.connect(deployer)
            .setContractUri('ipfs://'))
            .to.not.be.reverted;

        expect(await delegate.contractURI()).to.equal('ipfs://')
    });
});
