# README

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

We want the Banny's metadata json to be onchain, so something like the [cyberbrokers](https://etherscan.deth.net/address/0x892848074ddea461a15f337250da3ce55580ca85) function

```c
  function tokenURI(uint256 tokenId) public view returns (string memory) {
    return string(
        abi.encodePacked(
            abi.encodePacked(
                bytes('data:application/json;utf8,{"name":"'),
                getName(tokenId),
                bytes('","description":"'),
                getDescription(tokenId),
                bytes('","external_url":"'),
                getExternalUrl(tokenId),
                ...
            ),
            abi.encodePacked(
                bytes('","attributes":['),
                getAttributes(tokenId),
                bytes(']}')
            )
        )
    );
  }
```
