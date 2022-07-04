import * as hre from 'hardhat';
import { ethers } from "hardhat";

import { loadLayers } from '../test/banny';

async function main() {
    const [admin] = await ethers.getSigners();

    const merkleRoot = '0x0000000000000000000000000000000000000000000000000000000000000000';
    const tokenName = 'Banana';
    const tokenSymbol = 'NANA';

    const storageAddress = '0x200241cafc63d3135672031440c4f98f4ea5d766';
    const utilAddress = '0x94ff2d2d2cd7b2680453ee8bafc785bae6523c48';
    const tokenAddress = '0x4c38203f03a4c058338094a42dbc35f53dc87bc9';

    const storageFactory = await ethers.getContractFactory('Storage');
    const storage = await storageFactory.attach(storageAddress);

    try { await hre.run("verify:verify", { address: storageAddress, constructorArguments: [admin.address] }); } catch { }
    try { await hre.run("verify:verify", { address: utilAddress, constructorArguments: [] }); } catch { }
    try { await hre.run("verify:verify", { address: tokenAddress, constructorArguments: [storageAddress, utilAddress, admin.address, merkleRoot, tokenName, tokenSymbol] }); } catch { }

    await loadLayers(storage, admin);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat run scripts/loadsingle.ts --network rinkeby
