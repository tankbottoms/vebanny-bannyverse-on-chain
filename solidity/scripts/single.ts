import { ethers } from 'hardhat';
import fs from "fs";

import * as MerkleHelper from '../test/components/MerkleHelper';

function generateMerkleRoot() {
    const addressList = fs.readFileSync('scripts/accountList.csv').toString().split('\n').map(a => a.trim());
    const merkleSnapshot = MerkleHelper.makeSampleSnapshot(addressList, 5);
    const merkleData = MerkleHelper.buildMerkleTree(merkleSnapshot);
    return merkleData.merkleRoot;
}

async function main() {
  const [admin] = await ethers.getSigners();

  const merkleRoot = generateMerkleRoot();
  const tokenName = 'Banana';
  const tokenSymbol = 'NANA';

  const deployerFactory = await ethers.getContractFactory('Deployer');
  const deployer = await deployerFactory
    .connect(admin)
    .deploy(merkleRoot, tokenName, tokenSymbol, admin.address);
  await deployer.deployed();

  console.log(`deployer: ${deployer.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat run scripts/single.ts --network rinkeby
