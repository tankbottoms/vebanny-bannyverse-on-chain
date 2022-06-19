# README

## Minimal layering page

To see the layering of a Banny given it's index,

```sh
npm install # Will install http-server
npm run dev # Will open localhost:5500/web
```

- Define which banny to show in the url by adding `/?banny=20`
- Define lock period in the url `/?banny=20&lock=2`

  - Lock period defined by index in the url, so 2 corresponds to `3 Months`

    ```js
    const lockPeriods = [
      "1 WEEK",
      "1 MONTH",
      "3 MONTHS",
      "6 MONTHS",
      "1 YEAR",
      "4 YEARS",
    ];
    ```

The JBX range is gotten from the metadata file.

The Banny is created by using it's attributes from the metadata file.

## Sanity check Bannies and tag incompatible assets (i.e. the Banny Grid)

TLDR;

```sh
# In root of this project. Serve the assets over http.
npm run dev
# Then, in svelte part of the project
cd svelte
npm run dev
```

- Go to `localhost:3000/secret` to see the grid of Bannies.
- Click on a banny and end up on `localhost:3000/secret/{bannyIndex}` and click on the assets that are not working out.
- Save the json in the modal by copying it to clipboard.

## Metadata

Create metadata folder with a file for each Banny defined in the `characters.json` by running `createMetadata.mjs`

```sh
node createMetadata.mjs
```

NOTE: Thinking these won't actually be used in the tokenURI, but are here to crosscheck when we create the function to build up the tokenURI.

## TLDR

A Banny is defined by a structure like this;

```json
{
  "layers": {
    "Body": "Yellow",
    "Both_Hands": "Nothing",
    "Choker": "Choker",
    "Face": "Gautama_Buddha",
    "Headgear": "No_Hat",
    "Left_Hand": "Nothing",
    "Lower_Accessory": "Black_Shoes",
    "Oral_Fixation": "Nothing",
    "Outfit": "Gautama_Buddha",
    "Right_Hand": "Nothing"
  }
}
```

Which is encoded in the Banny's metadata json in the attributes, e.g.

```json
{
    ...
    "attributes": [
      {
         "trait_type": "Background",
         "value": "10 days"
      },
      {
         "trait_type": "Body",
         "value": "Yellow"
      },
      {
         "trait_type": "Face",
         "value": "Eye mouth"
      },
      {
         "trait_type": "Choker",
         "value": "Choker"
      },
      {
         "trait_type": "Lower Accessory",
         "value": "Black shoes"
      },
      {
         "trait_type": "Outfit",
         "value": "No outfit"
      },
      {
         "trait_type": "Oral Fixation",
         "value": "Nothing"
      },
      {
         "trait_type": "Headgear",
         "value": "No hat"
      },
      {
         "trait_type": "Left Hand",
         "value": "Nothing"
      },
      {
         "trait_type": "Right Hand",
         "value": "Nothing"
      },
      {
         "trait_type": "Both Hands",
         "value": "Nothing"
      },
   ],
}

```
