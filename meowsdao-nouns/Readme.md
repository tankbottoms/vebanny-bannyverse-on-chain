# layer-cake configuration

```typescript
/* eslint-disable max-len */
import moment from 'moment';
import { CollageOutput, ProjectConfig } from '../interfaces';
import { random } from '../utils';
import {
  collage11110,
  collage1600,
  collage4444,
  collage4000,
  collage5000,
  collageOpenSea1200x75,
  collageDiscord600x240,
  collageTwitter1200x675,
  collageTwitter1500x500,
  collage10000,
} from './collages';
const iso_datetime_now = new Date().toISOString();

export const meowsnouns_colors = [
  'F6A3AD',
  'FF808D',
  'FFAFB9',
  'CBEEC2',
  '8EE9F2',
  'F5F3BA',
  '71CEF3',
  'FCEEB2',
  'FCAD5E',
  'FB6155',
  'E5BBD7',
  'AFD7D0',
];

export const meowsnouns_description: string = `Meows(DAO)'s Nouns Edition are hand drawn illustrations by artist Natasha Pankina (natasha-pankina.eth). This NFT collection expands the universe of Mr.Whiskers (Inventor of Proof of Meow\u2122 and CEO of CompuGlobalHyperMega) beyond his Progeny as an homage to the Nouns.`;

const population_size = 6969;

export const meowsnounsConfig: ProjectConfig = {
  name: `meowsdao-nouns`,
  upload_images_to_ipfs: true,
  upload_metadata_to_ipfs: true,
  shuffle_assets: true,
  resume_folder: '',
  re_generate_collages: false,
  metadata_outputs: ['ethereum'],
  metadata_file_extension: false,
  hide_rarity_names: true,
  rotated_images_allowed: 0,
  mirror_images_allowed: 0,
  // asset_origin: 0,
  metadata_input: {
    name: `MeowsDAO Nouns Edition`,
    symbol: 'MEOWSNOUNS-',
    description: meowsnouns_description,
    birthdate: `${moment(iso_datetime_now)
      .subtract(365 + random(365 * 2), 'days')
      .toISOString()}`,
    background_colors: meowsnouns_colors,
    minter: `tankbottoms.eth`,
    creators: [`juicebox.meowsdao.eth`, `natasha-pankina.eth`],
    publishers: [`juicebox.meowsdao.eth`, `natasha-pankina.eth`, `tankbottoms.eth`],
    genres: [`meowsnouns`, `meows`, `character`, `profile`],
    tags: [`ETH`],
    drop_date: `${iso_datetime_now}`,
    native_size: '1000x1000', // '2084x2084',
    more_info_link: 'https://meowsdao.xyz',
    include_total_population_in_name: true,
    royalties: {
      artist_address: `natasha-pankina.eth`,
      artist_percentage: 10,
      additional_payee: 'juicebox.meowsdao.eth',
      additional_payee_percentage: 5,
    },
    rights: `© 2022 MeowsDAO, JuiceBoxDAO, Important Stuff Inc.`,
    decimals: 0,
    generation: 1,
    edition: 0,
  },
  image_outputs: [
    // feeds into collage, please don't remove.
    { width: 350, height: 350, tag: 'icon', ipfs_tag: 's' },
    { width: 512, height: 512, tag: 'profile', ipfs_tag: '' },
    { width: 1_000, height: 1_000, tag: 'image', ipfs_tag: '' },
    // { width: 1_500, height: 1_500, tag: 'image', ipfs_tag: '' },
  ],
  stacked_gif_outputs: [
    {
      tag: 'stacked-gif',
      source_image_type: 'profile',
      max_stacks: 40,
      images_per_stack: 50,
    },
  ],
  populations: [    
    {
      name: 'naked',
      layer_order: [
        'Background',
        'Fur',
        'Ears',
        'Brows',
        'Eyes',
        'Nose',
        'Nipples',
        'Headwear',
        'Glasses',
        'Collar',
        'Signature',
        'Juicebox',
      ],
      population_size: population_size / 3,
    },
    {
      name: 't-shirt',
      layer_order: [
        'Background',
        'Fur',
        'Ears',
        'Brows',
        'Eyes',
        'Nose',
        'T-shirt',
        'Pattern',
        'Headwear',
        'Glasses',
        'Signature',
        'Juicebox',
      ],
      population_size: population_size / 3,
    },
    {
      name: 'shirt',
      layer_order: [
        'Background',
        'Fur',
        'Ears',
        'Brows',
        'Eyes',
        'Nose',
        'Shirt',
        'Tie',
        'Blazer',
        'Headwear',
        'Glasses',
        'Signature',
        'Juicebox',
      ],
      population_size: population_size / 3 - 1,
    },
  ],
  anim_outputs: [],
  collage_outputs: [
    collage1600,
    collage4444,
    collage4000,
    collageOpenSea1200x75,
    collageDiscord600x240,
    collageTwitter1200x675,
    collageTwitter1500x500,
  ],
  re_generate_metadata_cid: false,
  excluded_layers_from_metadata: [],
};

```
