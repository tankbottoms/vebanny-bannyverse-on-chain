import * as hre from 'hardhat';
import { ethers } from "hardhat";

import { loadLayers } from '../test/banny';

async function main() {
    const [deployer] = await ethers.getSigners();

    const storageFactory = await ethers.getContractFactory('Storage');
    const storage = await storageFactory.connect(deployer).deploy(deployer.address);
    await storage.deployed();

    const bannyCommonUtilFactory = await ethers.getContractFactory('BannyCommonUtil', deployer);
    const bannyCommonUtilLibrary = await bannyCommonUtilFactory.connect(deployer).deploy();
    await bannyCommonUtilLibrary.deployed();

    const merkleRoot = '0x0000000000000000000000000000000000000000000000000000000000000000';
    const tokenName = 'Banana';
    const tokenSymbol = 'NANA';

    const tokenFactory = await ethers.getContractFactory('Token');
    const token = await tokenFactory.connect(deployer).deploy(storage.address, bannyCommonUtilLibrary.address, deployer.address, merkleRoot, tokenName, tokenSymbol);
    await token.deployed();

    console.log(`storage: ${storage.address}`);
    console.log(`banny lib ${bannyCommonUtilLibrary.address}`);
    console.log(`token: ${token.address}`);

    await hre.run("verify:verify", { address: storage.address, constructorArguments: [deployer.address] });
    await hre.run("verify:verify", { address: bannyCommonUtilLibrary.address, constructorArguments: [] });
    await hre.run("verify:verify", { address: token.address, constructorArguments: [storage.address, bannyCommonUtilLibrary.address, deployer.address, merkleRoot, tokenName, tokenSymbol] });

    await loadLayers(storage, deployer);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat run scripts/deploy.ts --network rinkeby
