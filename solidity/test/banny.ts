/* eslint-disable node/no-extraneous-import */
/* eslint-disable node/no-missing-import */
/* eslint-disable dot-notation */
/* eslint-disable no-unused-vars */
import fs from 'fs';
import * as path from 'path';
import { ethers } from 'hardhat';
import uuid4 from 'uuid4';
import { TransactionResponse } from '@ethersproject/abstract-provider';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { BigNumber } from 'ethers';

import { chunkAsset, chunkDeflate } from './utils';

export const traitDefinition: { [key: string]: string[] } = {
  Body: ['Yellow', 'Green', 'Pink', 'Red', 'Orange'],
  Both_Hands: ['Nothing', 'AK-47', 'Blue_Paint', 'M4', 'Sword_Shield'],
  Choker: ['Nothing', 'Choker', 'Christmas_Lights', 'Hawaiian', 'Blockchain_Necklace'],
  Face: [
    'Eye_Mouth',
    'Baobhan_Sith',
    'Diana_Banana',
    'Dr_Harleen_Quinzel',
    'Harleen_Quinzel',
    'Enlil',
    'Gautama_Buddha',
    'Bunny_Eyes',
    'Princess_Peach_Toadstool_Face',
    'Angry',
    'Sakura',
    'Happy',
    'Rick_Astley',
    'Panda_Eyes',
    'Rose',
    'Smile',
    'Surprised',
  ],
  Headgear: [
    'Nothing',
    'Sunglasses',
    'Feather_Hat',
    'Baker_Helmet',
    'Banhovah',
    'Red_Hair',
    'Bannible_Lector',
    'Banny_Ipkiss',
    'Banny_Potter',
    'Banny_Stark',
    'Baobhan_Sith',
    'Batbanny',
    'Beatrix_Kiddo',
    'Blondie_Hat',
    'Bronson_Hat',
    'Desmond_Miles',
    'Diana_Banana',
    'Dolly_Parton',
    'Dotty_Gale',
    'Dr_Harleen_Quinzel',
    'Dr_Jonathan_Osterman',
    'Edward_Teach',
    'Emmett_Doc_Brown',
    'Farceur',
    'Ivar_the_Boneless',
    'Jango_Fett',
    'Jinx_Hair',
    'John_Row',
    'Headphones',
    'Legolas_Hat',
    'Lestat_The_Undead',
    'Louise_Burns',
    'Mario',
    'Masako_Tanaka',
    'Mick_Mulligan_Glasses',
    'Miyamoto_Musashi_Ribbon',
    'Musa',
    'Naruto',
    'Obiwan_Kenobanana',
    'Pamela_Anderson',
    'Pharaoh_King_Banatut',
    'Piers_Plowman_Hat',
    'Brown_Hair',
    'Princess_Leia',
    'Princess_Peach_Toadstool',
    'Rose_Bertin_Hat',
    'Sakura_Haruno',
    'Green_Cap',
    'Spider_Jerusalem_Glasses',
    'Spock',
    'Tafari_Makonnen',
    'The_Witch_of_Endor',
    'Tinkerbanny',
    'Wade',
    'Blue_Glasses',
    'Firefighter_Helmet',
    'Flash',
    'Kiss_Musician',
    'Hat_and_Beard',
    'Mummy',
    'Panda',
    'Purple-samurai',
    'Rick_Astley',
    'Bruce_Lee_Hair',
    'Discoball',
    'Ironman_Headgear',
    'Mowhawk',
    'Mushroom_Hat',
    'Nerd_Glasses',
    'Queen_Crown',
  ],
  Left_Hand: [
    'Nothing',
    'Holy_Wine',
    'Edward_Teach_Sword',
    'Ivar_the_Boneless_Shield',
    'Shark_v2',
    'Surf_Board',
    'Katana',
    'Pitchfork',
    'Spider_Jerusalem_Weapon',
    'Chibuxi',
    'Samurai_Dagger',
    'BOOBS_calc',
    'Computer',
    'Flamings',
    "Lord_of_the_Banana's_Gandolph_Staff",
    'Magical_Staff',
    'Nunchucks',
    'Shovel',
  ],
  Lower_Accessory: [
    'Black_Shoes',
    'Diana_Banana_Shoes',
    'Dr_Jonathan_Osterman',
    'Sandals',
    'Legolas_Boots',
    'Piers_Plowman_Boots',
    'Rick_Astley_Boots',
  ],
  Oral_Fixation: ['Nothing', 'Mouthstraw', 'Blunt_1k'],
  Outfit: [
    'Nothing',
    'Smoking',
    'Athos',
    'Baker',
    'Banhovah',
    'Banmora',
    'Bannible_Lector',
    'Banny_Ipkiss',
    'Banny_Potter',
    'Banny_Stark',
    'Baobhan_Sith',
    'Batbanny',
    'Beatrix_Kiddo',
    'Blondie',
    'Bronson',
    'Desmond_Miles',
    'Diana_Banana_Dress',
    'Dolly_Parton',
    'Dotty_Gale',
    'Dr_Harleen_Quinzel',
    'Dr_Jonathan_Osterman',
    'Edward_Teach',
    'Emmett_Doc_Brown',
    'Gautama_Buddha',
    'Jango_Fett',
    'Jinx',
    'John_Row_Vest',
    'Johnny_Rotten',
    'Johnny_Utah_T-shirt',
    'Legolas',
    'Lestat_The_Undead',
    'Louise_Burns',
    'Mario',
    'Masako_Tanaka',
    'Mick_Mulligan',
    'Miyamoto_Musashi',
    'Musa',
    'Naruto',
    'Obiwan_Kenobanana',
    'Pamela_Anderson',
    'Pharaoh_King_Banatut',
    'Piers_Plowman',
    'Primrose',
    'Prince_of_Darkness',
    'Princess_Leia',
    'Princess_Peach_Toadstool',
    'Rose_Bertin_Dress',
    'Sakura_Haruno',
    'Smalls',
    'Spider_Jerusalem',
    'Spock',
    'Tafari_Makonnen',
    'Tamar_of_Georgia',
    'The_Witch_of_Endor_Belt',
    'Tinkerbanny',
    'Wade',
    'Blue_T-Shirt',
    'Firefighter',
    'Flash',
    'Hawaiian',
    'JuiceBox_Bunny',
    'Suit',
    'Mummy',
    'Panda',
    'Purple_Samurai',
    'Rick_Astley',
    'Ducttape',
    'Wings',
  ],
  Right_Hand: [
    'Nothing',
    'Athos_Rapier',
    'Katana',
    'Pistol',
    'Butcher_Knife',
    'Diana_Banana',
    'Basket',
    'Dr_Harleen_Quinzel',
    'Lollipop',
    'Ivar_the_Boneless_Axe',
    'Fishing_Pole',
    'Wagasa',
    'Lightsaber',
    'Anch',
    'Piers_Plowman_Dagger',
    'Dagger',
    'The_Witch_of_Endor_Broom',
    'Firefighter',
    'Juicebox',
    'Triangle_guitar',
    'Axe',
    'Beer',
    'Bow_and_Arrow',
    'Bread',
    'Fans',
    'Fly_Swatter',
    'Frying_Pan',
    'Guitar',
    'Hammer',
    'Mace',
    'Mini_Axe',
    'Shark',
    'Sword',
    'Thanos_Glove',
    'Wakanda',
  ],
};

export const traitsShiftOffset: { [key: string]: number } = {
  Body: 0, // uint4
  Both_Hands: 4, // uint4
  Choker: 8, // uint4
  Face: 12, // uint8, 6 needed
  Headgear: 20, // uint8, 7 needed
  Left_Hand: 28, // uint8, 5 needed
  Lower_Accessory: 36, // uint4, 3 needed
  Oral_Fixation: 40, // uint4, 2 needed
  Outfit: 44, // uint8, 7 needed
  Right_Hand: 52, // uint8, 6 needed
};

export function processCharacters(): { [key: string]: any } {
  const characters = JSON.parse(fs.readFileSync('../characters.json').toString());
  const reduced: any = {};

  for (const id of Object.keys(characters)) {
    reduced[id] = JSON.parse(JSON.stringify(characters[id]));
    delete reduced[id]['metadata']['history'];
    delete reduced[id]['metadata']['motto'];
    delete reduced[id]['layers'];

    let traits = BigNumber.from(0);
    for (const l of Object.keys(characters[id]['layers'])) {
      const trait = traitDefinition[l];
      const feature = characters[id]['layers'][l];

      traits = traits.add(
        `0x${(trait.indexOf(feature) + 1).toString(16)}${'0'.repeat(traitsShiftOffset[l] / 4)}`,
      );
    }

    reduced[id]['layers'] = traits.toString();
  }

  return reduced;
}

export async function loadLayers(storage: any, deployer: SignerWithAddress): Promise<BigNumber> {
  const layers = JSON.parse(fs.readFileSync('../layerOptions.json').toString());

  let gas = BigNumber.from(0);

  for (const group of Object.keys(layers)) {
    for (let i = 0; i < layers[group].length; i++) {
      const item = layers[group][i];
      if (item === 'Nothing') {
        continue;
      }

      const png = path.resolve(__dirname, '..', '..', 'layers', group, `${item}.png`);
      const id = BigNumber.from(
        `0x${(i + 1).toString(16)}${'0'.repeat(traitsShiftOffset[group] / 4)}`,
      );

      const incrementalGas = await loadAsset(storage, deployer, png, id.toString());
      gas = gas.add(incrementalGas);
    }
  }

  return gas;
}

export async function loadFile(storage: any, deployer: SignerWithAddress, pathInfo: string[], id = '9223372036854775809'): Promise<BigNumber> {
    const fontData = path.resolve(__dirname, ...pathInfo);
    return await loadAsset(storage, deployer, fontData, id);
}

/**
 *
 * @param storage Storage contract.
 * @param signer Account with permissions to add assets.
 * @param asset Fully qualified path of the file to load.
 * @param assetId Asset id to store the file as. WARNING: no validation, duplicates will fail, limit 64bit uint.
 */
export async function loadAsset(
  storage: any,
  signer: SignerWithAddress,
  asset: string,
  assetId: string,
): Promise<BigNumber> {
  let assetParts: any;
  let inflatedSize = 0;

  if (asset.endsWith('svg')) {
    assetParts = chunkDeflate(asset);
    inflatedSize = assetParts.inflatedSize;
  } else {
    assetParts = chunkAsset(asset);
    inflatedSize = assetParts.length;
  }

  let sliceKey = '0x' + Buffer.from(uuid4(), 'utf-8').toString('hex').slice(-64);
  let tx: TransactionResponse = await storage
    .connect(signer)
    .createAsset(assetId, sliceKey, assetParts.parts[0], assetParts.length, {
      gasLimit: 5_000_000,
    });
  const receipt = await tx.wait();
  let gas = BigNumber.from(receipt.gasUsed);

  for (let i = 1; i < assetParts.parts.length; i++) {
    sliceKey = '0x' + Buffer.from(uuid4(), 'utf-8').toString('hex').slice(-64);
    tx = await storage
      .connect(signer)
      .appendAssetContent(assetId, sliceKey, assetParts.parts[i], { gasLimit: 5_000_000 });
    const receipt = await tx.wait();
    gas = gas.add(receipt.gasUsed);
  }

  // if (inflatedSize != assetParts.length) {
  //     tx = await storage.connect(signer).setAssetAttribute(0, '_inflatedSize', AssetAttrType.UINT_VALUE, [smallIntToBytes32(inflatedSize)]);
  //     await tx.wait();
  //     console.log(`added ${asset}, compressed ${assetParts.inflatedSize} to ${assetParts.length} as ${assetId}`);
  // } else {
  //     console.log(`added ${asset}, ${assetParts.length} as ${assetId}/${Number(assetId).toString(16)}`);
  // }

  return gas;
}
