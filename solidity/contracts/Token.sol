// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

import './components/StringHelpers.sol';

import './libraries/Base64.sol';
import './libraries/ERC721Enumerable.sol';
import './interfaces/IToken.sol';
import './interfaces/IStorage.sol';
import './enums/AssetDataType.sol';

error ARGUMENT_EMPTY(string);

contract Token is IToken, ERC721Enumerable, ReentrancyGuard, AccessControl {
  bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

  IStorage public assets;

  /**
    @notice Maps token id to packed traits definition.
    */
  mapping(uint256 => uint256) public tokenTraits;

  string public contractMetadataURI;
  // TODO: create banny library of traits
  string[5] bodyTraits = ['Yellow', 'Green', 'Pink', 'Red', 'Orange'];
  string[5] handsTraits = ['Nothing', 'AK-47', 'Blue_Paint', 'M4', 'Sword_Shield'];
  string[5] chokerTraits = [
    'Nothing',
    'Choker',
    'Christmas_Lights',
    'Hawaiian',
    'Blockchain_Necklace'
  ];
  string[17] faceTraits = [
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
    'Surprised'
  ];
  string[70] headgearTraits = [
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
    'Queen_Crown'
  ];
  string[18] leftHandTraits = [
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
    'Shovel'
  ];
  string[7] lowerTraits = [
    'Black_Shoes',
    'Diana_Banana_Shoes',
    'Dr_Jonathan_Osterman',
    'Sandals',
    'Legolas_Boots',
    'Piers_Plowman_Boots',
    'Rick_Astley_Boots'
  ];
  string[3] oralTraits = ['Nothing', 'Mouthstraw', 'Blunt_1k'];
  string[68] outfitTraits = [
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
    'Wings'
  ];
  string[35] rightHandTraits = [
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
    'Wakanda'
  ];

  constructor(
    IStorage _assets,
    string memory _name,
    string memory _symbol
  ) ERC721Enumerable(_name, _symbol) {
    assets = _assets;

    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  //*********************************************************************//
  // ------------------------ Token Operations ------------------------- //
  //*********************************************************************//

  function contractURI() public view override returns (string memory) {
    return contractMetadataURI;
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    return dataUri(_tokenId);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) public override {
    _beforeTokenTransfer(_from, _to, _tokenId);
    super.transferFrom(_from, _to, _tokenId);
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) public override {
    _beforeTokenTransfer(_from, _to, _tokenId);
    super.safeTransferFrom(_from, _to, _tokenId);
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  ) public override {
    _beforeTokenTransfer(_from, _to, _tokenId);
    super.safeTransferFrom(_from, _to, _tokenId, _data);
  }

  /**
    @notice ERC165
    */
  function supportsInterface(bytes4 _interfaceId)
    public
    view
    override(AccessControl, ERC721Enumerable)
    returns (bool)
  {
    return super.supportsInterface(_interfaceId);
  }

  function validateTraits(uint256 _traits) public pure override returns (bool valid) {
    if (_traits == 0) {
      return false;
    }

    valid = true;
  }

  //*********************************************************************//
  // ---------------------- Privileged Operations ---------------------- //
  //*********************************************************************//

  /**
    @notice 

    @param _owner Address of the owner.
    @param _traits Packed NFT traits.
    */
  function mint(address _owner, uint256 _traits)
    public
    override
    onlyRole(MINTER_ROLE)
    returns (uint256 tokenId)
  {
    tokenId = totalSupply() + 1;

    tokenTraits[tokenId] = _traits;

    _beforeTokenTransfer(address(0), _owner, tokenId);

    _mint(_owner, tokenId);
  }

  function addMinter(address _account) public override onlyRole(DEFAULT_ADMIN_ROLE) {
    _grantRole(MINTER_ROLE, _account);
  }

  function removeMinter(address _account) public override onlyRole(DEFAULT_ADMIN_ROLE) {
    _revokeRole(MINTER_ROLE, _account);
  }

  function setContractURI(string calldata _uri) public override onlyRole(DEFAULT_ADMIN_ROLE) {
    if (bytes(_uri).length == 0) {
      revert ARGUMENT_EMPTY('_uri');
    }

    contractMetadataURI = _uri;
  }

  function withdrawEther() public override onlyRole(DEFAULT_ADMIN_ROLE) {
    require(payable(msg.sender).send(address(this).balance), 'withdrawEther failed');
  }

  //*********************************************************************//
  // ----------------------- Storage Management ------------------------ //
  //*********************************************************************//

  function getAssetBase64(uint64 _assetId, AssetDataType _assetType)
    public
    view
    override
    returns (string memory)
  {
    string memory prefix = '';

    if (_assetType == AssetDataType.AUDIO_MP3) {
      prefix = 'data:audio/mp3;base64,';
    } else if (_assetType == AssetDataType.IMAGE_SVG) {
      prefix = 'data:image/svg+xml;base64,';
    } else if (_assetType == AssetDataType.IMAGE_PNG) {
      prefix = 'data:image/png;base64,';
    }

    return string(abi.encodePacked(prefix, Base64.encode(assets.getAssetContentForId(_assetId))));
  }

  function dataUri(uint256 _tokenId) public view override returns (string memory json) {
    uint256 traits = tokenTraits[_tokenId];

    json = Base64.encode(
      abi.encodePacked(
        '{"name": "',
        name,
        ' No.',
        Strings.toString(_tokenId),
        '", "description": "Fully on-chain NFT", "image": "data:image/svg+xml;base64,',
        _getFramedImage(traits),
        '", "attributes":',
        _getTokenTraits(traits),
        '}'
      )
    );

    return string(abi.encodePacked('data:application/json;base64,', json));
  }

  function _getFramedImage(uint256 traits) internal view returns (string memory image) {
    image = Base64.encode(
      abi.encodePacked(
        '<svg id="token" width="300" height="300" viewBox="0 0 1080 1080" fill="none" xmlns="http://www.w3.org/2000/svg"> <defs><radialGradient id="paint0_radial_772_22716" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(540.094 539.992) rotate(90) scale(539.413)"><stop stop-color="#B4B4B4" /><stop offset="1" /></radialGradient><path id="textPathBottom" d="M 540 540 m -450,0 a 450,450 0 1,0 900,0"/><path id="textPathTop" d="M 540 540 m -450,0 a 450,450 0 1,1 900,0" /></defs><circle cx="540.094" cy="539.992" r="539.413" fill="url(#paint0_radial_772_22716)"/><g id="bannyPlaceholder">',
        _getImageStack(traits),
        '</g><text font-size="90" fill="white" text-anchor="middle" x="700" dominant-baseline="mathematical"><textPath id="topText" href="#textPathTop">10 DAYS</textPath></text><text font-size="90" fill="white" text-anchor="middle" x="710" dominant-baseline="mathematical"><textPath id="bottomText" href="#textPathBottom"></textPath></text></svg>'
      )
    );
  }

  function _getImageStack(uint256 traits) internal view returns (string memory image) {
    // BODY_TRAIT_OFFSET = 0; // uint4
    // HANDS_TRAIT_OFFSET = 4; // uint4
    // CHOKER_TRAIT_OFFSET = 8; // uint4
    // FACE_TRAIT_OFFSET = 12; // uint8, 6 needed
    // HEADGEAR_TRAIT_OFFSET = 20; // uint8, 7 needed
    // LEFTHAND_TRAIT_OFFSET = 28; // uint8, 5 needed
    // LOWER_TRAIT_OFFSET = 36; // uint4, 3 needed
    // ORAL_TRAIT_OFFSET = 40; // uint4, 2 needed
    // OUTFIT_TRAIT_OFFSET = 44; // uint8, 7 needed
    // RIGHTHAND_TRAIT_OFFSET = 52; // uint8, 6 needed
    // uint4Mask = 15;

    string[10] memory stack;
    uint64 contentId = uint64(uint8(traits) & 15);
    stack[0] = __imageTag(getAssetBase64(contentId, AssetDataType.IMAGE_PNG)); // bodyContent

    contentId = uint64(uint8(traits >> 4) & 15);
    if (contentId > 1) {
      stack[1] = __imageTag(getAssetBase64(contentId << 4, AssetDataType.IMAGE_PNG)); // handsContent
    }

    contentId = uint64(uint8(traits >> 8) & 15);
    if (contentId > 1) {
      stack[2] = __imageTag(getAssetBase64(contentId << 8, AssetDataType.IMAGE_PNG)); // chokerContent
    }

    contentId = uint64(uint8(traits >> 12)) << 12;
    stack[3] = __imageTag(getAssetBase64(contentId, AssetDataType.IMAGE_PNG)); // faceContent

    contentId = uint64(uint8(traits >> 20));
    if (contentId > 1) {
      stack[4] = __imageTag(getAssetBase64(contentId << 20, AssetDataType.IMAGE_PNG)); // headgearContent
    }

    contentId = uint64(uint8(traits >> 28));
    if (contentId > 1) {
      stack[5] = __imageTag(getAssetBase64(contentId << 28, AssetDataType.IMAGE_PNG)); // leftHandContent
    }

    contentId = uint64(uint8(traits >> 36) & 15) << 36;
    stack[6] = __imageTag(getAssetBase64(contentId, AssetDataType.IMAGE_PNG)); // lowerContent

    contentId = uint64(uint8(traits >> 40) & 15);
    if (contentId > 1) {
      stack[7] = __imageTag(getAssetBase64(contentId << 40, AssetDataType.IMAGE_PNG)); // oralContent
    }

    contentId = uint64(uint8(traits >> 44));
    if (contentId > 1) {
      stack[8] = __imageTag(getAssetBase64(contentId << 44, AssetDataType.IMAGE_PNG)); // outfitContent
    }

    contentId = uint64(uint8(traits >> 52));
    if (contentId > 1) {
      stack[9] = __imageTag(getAssetBase64(contentId << 52, AssetDataType.IMAGE_PNG)); // rightHandContent
    }

    image = string(
      abi.encodePacked(
        stack[0], // bodyContent
        stack[3], // faceContent
        stack[2], // chokerContent
        stack[6], // lowerContent
        stack[8], // outfitContent
        stack[7], // oralContent
        stack[4], // headgearContent
        /* 
        (stack[5] == 'Nothing' && stack[9] == 'Nothing) || stack[1] == 'Nothing' 
        // ensure that left and right are not occupied before allowing hands to be not Nothing
        */
        stack[5], // leftHandContent
        stack[9], // rightHandContent
        stack[1] // handsContent
      )
    );
  }

  /**
    @dev Returns packed traits JSON for a given trait uint.
    */
  function _getTokenTraits(uint256 traits) internal view returns (bytes memory json) {
    // TODO: replace part name underscores with space  
    // StringHelper.replace(bodyTraits[uint64(uint8(traits) & 15) - 1], '_', trait_value)
    json = abi.encodePacked(
      '[',
      '{"trait_type":"Body","value":"',
      bodyTraits[uint64(uint8(traits) & 15) - 1],
      '"},',
      '{"trait_type":"Both Hands","value":"',
      handsTraits[uint64(uint8(traits >> 4) & 15) - 1],
      '"},',
      '{"trait_type":"Choker","value":"',
      chokerTraits[uint64(uint8(traits >> 8) & 15) - 1],
      '"},',
      '{"trait_type":"Face","value":"',
      faceTraits[uint64(uint8(traits >> 12)) - 1],
      '"},',
      '{"trait_type":"Headgear","value":"',
      headgearTraits[uint64(uint8(traits >> 20)) - 1],
      '"},',
      '{"trait_type":"Left Hand","value":"',
      leftHandTraits[uint64(uint8(traits >> 28)) - 1],
      '"},',
      '{"trait_type":"Lower Accessory","value":"',
      lowerTraits[uint64(uint8(traits >> 36) & 15) - 1],
      '"},',
      '{"trait_type":"Oral Fixation","value":"',
      oralTraits[uint64(uint8(traits >> 40) & 15) - 1],
      '"},',
      '{"trait_type":"Outfit","value":"',
      outfitTraits[uint64(uint8(traits >> 44)) - 1],
      '"},',
      '{"trait_type":"Right Hand","value":"',
      rightHandTraits[uint64(uint8(traits >> 52)) - 1],
      '"}',
      ']'
    );
  }

  /**
    @dev incoming parameter is wrapped blindly without checking content.
    */
  function __imageTag(string memory _content) private pure returns (string memory tag) {
    tag = string(
      abi.encodePacked(
        '<image x="50%" y="50%" width="1000" href="',
        _content,
        '" style="transform: translate(-500px, -500px)" />'
      )
    );
  }
}
