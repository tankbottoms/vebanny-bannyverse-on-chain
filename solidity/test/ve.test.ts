import { expect } from 'chai';
import fs from 'fs';
import * as path from 'path';
import { ethers } from 'hardhat';

import { loadFile, loadLayers, processCharacters } from './banny';
import { formatMills, mark } from './utils';

describe("veBanny URI Resolver Tests", () => {
    let storage: any;
    let uriResolver: any;
    let deployer: any;
    let accounts: any[];

    const durations: number[] = [60 * 60 * 24 * 10, 60 * 60 * 24 * 30, 60 * 60 * 24 * 365]; // TODO: need actual valid durations
    const contributionTiers = [100, 200, 300, 400, 500, 600, 700, 800, 900, 1_000, 2_000, 3_000, 4_000, 5_000, 6_000, 7_000, 8_000, 9_000, 10_000, 12_000, 14_000, 16_000, 18_000, 20_000, 22_000, 24_000, 26_000, 28_000, 30_000, 40_000, 50_000, 60_000, 70_000, 80_000, 90_000, 100_000, 200_000, 300_000, 400_000, 500_000, 600_000, 700_000, 800_000, 900_000, 1_000_000, 2_000_000, 3_000_000, 4_000_000, 5_000_000, 6_000_000, 7_000_000, 8_000_000, 9_000_000, 10_000_000, 20_000_000, 40_000_000, 60_000_000, 100_000_000, 600_000_000]

    before(() => {
        if (!fs.existsSync('test-output')) {
            fs.mkdirSync('test-output');
        }
    })

    before(async () => {
        const start = mark();
        console.log('Initializing contracts');
        [deployer, ...accounts] = await ethers.getSigners();

        const storageFactory = await ethers.getContractFactory('Storage');
        storage = await storageFactory.connect(deployer).deploy();
        await storage.deployed();

        await loadFile(storage, deployer, ['..', '..', 'fonts', 'Pixel Font-7-on-chain.woff'], '9223372036854775809');
        await loadLayers(storage, deployer);

        const uriResolverFactory = await ethers.getContractFactory('JBVeTokenUriResolver');
        uriResolver = await uriResolverFactory.connect(deployer).deploy(storage.address, 'Escrow Banana', 'ipfs://metadata');
        await uriResolver.deployed();

        console.log(`Contracts deployed in ${formatMills(mark(start)[0])}`);
    });

    it('Character Definition Tests', async () => {
        const start = mark();
        console.log('Started character definition tests');
        // const characters = processCharacters();

        // for (let i = 0; i < durations.length; i++) {
            // const tokenId = i + 1;
            // const d = durations[i];

            const tokenId = 1;
            const d = durations[0];

            const tokenUri = await uriResolver.tokenURI(tokenId, 1_000_000, d, 0, durations);
            const decoded = Buffer.from(tokenUri.slice(('data:application/json;base64,').length), 'base64').toString();
            const json = JSON.parse(decoded.toString());
            const imageData = Buffer.from(json['image'].slice(json['image'].indexOf(',') + 1), 'base64').toString();
            fs.writeFileSync(path.resolve('test-output', `ve-${d}.svg`), imageData);

            // TODO: 'expect()' results
        // }

        console.log(`Finished character definition tests in ${formatMills(mark(start)[0])}`);
    });

    it('InvalidLockDuration Test', async () => {
        const invalidDuration = 60 * 60 * 24;
        await expect(uriResolver.tokenURI(1, 1_000_000, invalidDuration, 0, durations)).to.be.reverted;
    });

    it('Contribution Tiers Tests', async () => {
        const start = mark();
        console.log('Started contribution tiers tests');

        await uriResolver.tokenURI(1, contributionTiers[0], durations[0], 0, durations);
        await uriResolver.tokenURI(1, contributionTiers[Math.floor(Math.random() * (contributionTiers.length - 1))], durations[0], 0, durations);
        await uriResolver.tokenURI(1, contributionTiers[contributionTiers.length - 1], durations[0], 0, durations);

        const highContribution = contributionTiers[contributionTiers.length - 1] + 1;
        await uriResolver.tokenURI(1, highContribution, durations[0], 0, durations);

        console.log(`Finished contribution tiers tests in ${formatMills(mark(start)[0])}`);
    });
});
