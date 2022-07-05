import { ethers } from 'hardhat';

async function main() {
  const [admin] = await ethers.getSigners();

  const merkleRoot = '0x0000000000000000000000000000000000000000000000000000000000000000';
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
