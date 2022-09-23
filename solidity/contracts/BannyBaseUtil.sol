// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

contract BannyBaseUtil {
  function validateTraits(uint256 _traits) public pure returns (bool) {
    uint8[10] memory offsets = [0, 4, 8, 12, 20, 28, 36, 40, 44, 52];
    uint8[10] memory cardinality = [5, 5, 5, 17, 70, 18, 7, 3, 68, 35];

    for (uint8 i = 0; i != 9; ) {
        if (uint8(_traits >> offsets[i]) > cardinality[i]) {
            return false;
        }
        ++i;
    }

    return true;
  }

  function generateTraits(uint256 _seed) public pure returns (uint256 traits) {
    uint8[10] memory offsets = [0, 4, 8, 12, 20, 28, 36, 40, 44, 52];
    uint8[10] memory cardinality = [5, 5, 5, 17, 70, 18, 7, 3, 68, 35];

    traits = uint256(uint8(_seed) % cardinality[0]);
    for (uint8 i = 1; i != 9; ) {
      traits |= uint256((uint8(_seed >> offsets[i]) % cardinality[i])) << offsets[i];
      ++i;
    }
  }

  function getIndexedTokenTraits(uint256 _index) public pure returns (uint256) {
    uint64[77] memory indexedTraits = [
      0,
      // escrow
      4522360314008081,
      40551157357089297,
      22783049442791953,
      5015149023859217,
      5156778560983569,
      5261232171913747,
      5314008732176913,
      5331600919237137,
      4610321249473042,
      4645505623659026,
      50015753453179409,
      31860617445904913,
      4698282184942097,
      68294378365391377,
      45054757790814737,
      4997349366567441,
      5349193106330129,
      5366785293423121,
      5419561854702097,
      5120494675169809,
      4627913436566033,
      5489930602025233,
      72991148398874897,
      4821427494601233,
      4575136875286801,
      9061144315564305,
      77512340265767441,
      4786243120402961,
      4592729330815249,
      4522360314008083,
      4891796779831825,
      5032808617612049,
      5173271236448529,
      63772842953544209,
      4539952501101073,
      4715874372030993,
      5085310300983825,
      54642498389152273,
      4944572805288465,
      5472338414932497,
      4680689997844753,
      4909388430053905,
      13740665813864977,
      5067718113890833,
      5138088472875537,
      59234058951987729,
      4522360314028562,
      5401969667609105,
      36381809260384785,
      5208455610663441,
      5296416545051153,
      5050125926797841,
      4962166066123281,
      5384379627999761,
      27321902163833361,
      4663097810752017,
      5278826192966164,
      18261857628328465,
      4874341494821137,
      4926980593054225,
      // special
      4522360314044945,
      5507522789118481,
      82086308641509905,
      5542707163304465,
      5560299290629137,
      5577891476714001,
      86642684769387025,
      5577891476718097,
      90090753293816337,
      5595486139453969,
      5613075910627857,
      4522360314008085,
      5630668097720849,
      5648262969168401,
      5666264788816401,
      5683444592939537
    ];

    return indexedTraits[_index];
  }

  /**
    @dev Returns packed traits JSON for a given trait uint.
    */
  function getTokenTraits(uint256 traits) public pure returns (bytes memory json) {
    json = abi.encodePacked(
      '[',
      '{"trait_type":"Body","value":"',
      bodyTraits(uint64(uint8(traits) & 15) - 1),
      '"},',
      '{"trait_type":"Both Hands","value":"',
      handsTraits(uint64(uint8(traits >> 4) & 15) - 1),
      '"},',
      '{"trait_type":"Choker","value":"',
      chokerTraits(uint64(uint8(traits >> 8) & 15) - 1),
      '"},',
      '{"trait_type":"Face","value":"',
      faceTraits(uint64(uint8(traits >> 12)) - 1),
      '"},',
      '{"trait_type":"Headgear","value":"',
      headgearTraits(uint64(uint8(traits >> 20)) - 1),
      '"},',
      '{"trait_type":"Left Hand","value":"',
      leftHandTraits(uint64(uint8(traits >> 28)) - 1),
      '"},',
      '{"trait_type":"Lower Accessory","value":"',
      lowerTraits(uint64(uint8(traits >> 36) & 15) - 1),
      '"},',
      '{"trait_type":"Oral Fixation","value":"',
      oralTraits(uint64(uint8(traits >> 40) & 15) - 1),
      '"},',
      '{"trait_type":"Outfit","value":"',
      outfitTraits(uint64(uint8(traits >> 44)) - 1),
      '"},',
      '{"trait_type":"Right Hand","value":"',
      rightHandTraits(uint64(uint8(traits >> 52)) - 1),
      '"}',
      ']'
    );
  }

  function bodyTraits(uint256 _index) public pure returns (string memory trait) {
    string[5] memory traits = ['Yellow', 'Green', 'Pink', 'Red', 'Orange'];
    if (_index > traits.length) {
        trait = '';
    } else {
        trait = traits[_index];
    }
  }

  function handsTraits(uint256 _index) public pure returns (string memory) {
    string[5] memory traits = ['Nothing', 'AK-47', 'Blue_Paint', 'M4', 'Sword_Shield'];
    return traits[_index];
  }

  function chokerTraits(uint256 _index) public pure returns (string memory) {
    string[5] memory traits = [
      'Nothing',
      'Choker',
      'Christmas_Lights',
      'Hawaiian',
      'Blockchain_Necklace'
    ];
    return traits[_index];
  }

  function faceTraits(uint256 _index) public pure returns (string memory) {
    string[17] memory traits = [
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
    return traits[_index];
  }

  function headgearTraits(uint256 _index) public pure returns (string memory) {
    string[70] memory traits = [
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
    return traits[_index];
  }

  function leftHandTraits(uint256 _index) public pure returns (string memory) {
    string[18] memory traits = [
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
    return traits[_index];
  }

  function lowerTraits(uint256 _index) public pure returns (string memory) {
    string[7] memory traits = [
      'Black_Shoes',
      'Diana_Banana_Shoes',
      'Dr_Jonathan_Osterman',
      'Sandals',
      'Legolas_Boots',
      'Piers_Plowman_Boots',
      'Rick_Astley_Boots'
    ];
    return traits[_index];
  }

  function oralTraits(uint256 _index) public pure returns (string memory) {
    string[3] memory traits = ['Nothing', 'Mouthstraw', 'Blunt_1k'];
    return traits[_index];
  }

  function outfitTraits(uint256 _index) public pure returns (string memory) {
    string[68] memory traits = [
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
    return traits[_index];
  }

  function rightHandTraits(uint256 _index) public pure returns (string memory) {
    string[35] memory traits = [
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

    return traits[_index];
  }
}
