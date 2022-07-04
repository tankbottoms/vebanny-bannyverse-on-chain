import * as hre from 'hardhat';
import { ethers } from "hardhat";

import { loadLayers } from '../test/banny';

async function main() {
    const [deployer] = await ethers.getSigners();

    const storageFactory = await ethers.getContractFactory('Storage');
    const storage = await storageFactory.connect(deployer).deploy();
    await storage.deployed();

    const bannyCommonUtilFactory = await ethers.getContractFactory('BannyCommonUtil', deployer);
    const bannyCommonUtilLibrary = await bannyCommonUtilFactory.connect(deployer).deploy();
    await bannyCommonUtilLibrary.deployed();

    const merkleRoot = '0x0000000000000000000000000000000000000000000000000000000000000000';
    const tokenFactory = await ethers.getContractFactory('Token', {
        libraries: { BannyCommonUtil: bannyCommonUtilLibrary.address },
        signer: deployer
    });
    const token = await tokenFactory.connect(deployer).deploy(storage.address, merkleRoot, 'Banana', 'NANA');
    await token.deployed();

    console.log(`storage: ${storage.address}`);
    console.log(`banny lib ${bannyCommonUtilLibrary.address}`);
    console.log(`token: ${token.address}`);

    await hre.run("verify:verify", { address: storage.address, constructorArguments: [] });
    await hre.run("verify:verify", { address: bannyCommonUtilLibrary.address, constructorArguments: [] });
    await hre.run("verify:verify", { address: token.address, constructorArguments: [storage.address, merkleRoot, 'Banana', 'NANA'] });

    await loadLayers(storage, deployer);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat run scripts/deploy.ts --network rinkeby
