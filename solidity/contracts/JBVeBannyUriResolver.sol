// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

import './libraries/Base64.sol';
import './interfaces/IJBVeTokenUriResolver.sol';
import './BannyCommonUtil.sol';

/**
  @notice 

  @dev https://github.com/tankbottoms/jbx-staking/blob/master/contracts/JBVeTokenUriResolver.sol
 */
contract JBVeTokenUriResolver is IJBVeTokenUriResolver, Ownable, BannyCommonUtil {
  string public override contractURI;
  IStorage public assets;
  string public name;
  mapping(uint16 => uint256) public tokenTraits;

  constructor(
    IStorage _assets,
    string memory _name,
    string memory _contractURI
  ) {
    assets = _assets;
    name = _name;
    contractURI = _contractURI;

    tokenTraits[1] = 4522360314008081;
    tokenTraits[2] = 40551157357089297;
    tokenTraits[3] = 22783049442791953;
    tokenTraits[4] = 5015149023859217;
    tokenTraits[5] = 5156778560983569;
    tokenTraits[6] = 5261232171913747;
    tokenTraits[7] = 5314008732176913;
    tokenTraits[8] = 5331600919237137;
    tokenTraits[9] = 4610321249473042;
    tokenTraits[10] = 4645505623659026;
    tokenTraits[11] = 50015753453179409;
    tokenTraits[12] = 31860617445904913;
    tokenTraits[13] = 4698282184942097;
    tokenTraits[14] = 68294378365391377;
    tokenTraits[15] = 45054757790814737;
    tokenTraits[16] = 4997349366567441;
    tokenTraits[17] = 5349193106330129;
    tokenTraits[18] = 5366785293423121;
    tokenTraits[19] = 5419561854702097;
    tokenTraits[20] = 5120494675169809;
    tokenTraits[21] = 4627913436566033;
    tokenTraits[22] = 5489930602025233;
    tokenTraits[23] = 72991148398874897;
    tokenTraits[24] = 4821427494601233;
    tokenTraits[25] = 4575136875286801;
    tokenTraits[26] = 9061144315564305;
    tokenTraits[27] = 77512340265767441;
    tokenTraits[28] = 4786243120402961;
    tokenTraits[29] = 4592729330815249;
    tokenTraits[30] = 4522360314008083;
    tokenTraits[31] = 4891796779831825;
    tokenTraits[32] = 5032808617612049;
    tokenTraits[33] = 5173271236448529;
    tokenTraits[34] = 63772842953544209;
    tokenTraits[35] = 4539952501101073;
    tokenTraits[36] = 4715874372030993;
    tokenTraits[37] = 5085310300983825;
    tokenTraits[38] = 54642498389152273;
    tokenTraits[39] = 4944572805288465;
    tokenTraits[40] = 5472338414932497;
    tokenTraits[41] = 4680689997844753;
    tokenTraits[42] = 4909388430053905;
    tokenTraits[43] = 13740665813864977;
    tokenTraits[44] = 5067718113890833;
    tokenTraits[45] = 5138088472875537;
    tokenTraits[46] = 59234058951987729;
    tokenTraits[47] = 4522360314028562;
    tokenTraits[48] = 5401969667609105;
    tokenTraits[49] = 36381809260384785;
    tokenTraits[50] = 5208455610663441;
    tokenTraits[51] = 5296416545051153;
    tokenTraits[52] = 5050125926797841;
    tokenTraits[53] = 4962166066123281;
    tokenTraits[54] = 5384379627999761;
    tokenTraits[55] = 27321902163833361;
    tokenTraits[56] = 4663097810752017;
    tokenTraits[57] = 5278826192966164;
    tokenTraits[58] = 18261857628328465;
    tokenTraits[59] = 4874341494821137;
    tokenTraits[60] = 4926980593054225;
    tokenTraits[61] = 4522360314044945;
    tokenTraits[62] = 5507522789118481;
    tokenTraits[63] = 82086308641509905;
    tokenTraits[64] = 5542707163304465;
    tokenTraits[65] = 5560299290629137;
    tokenTraits[66] = 5577891476714001;
    tokenTraits[67] = 86642684769387025;
    tokenTraits[68] = 5577891476718097;
    tokenTraits[69] = 90090753293816337;
    tokenTraits[70] = 5595486139453969;
    tokenTraits[71] = 5613075910627857;
    tokenTraits[72] = 4522360314008085;
    tokenTraits[73] = 5630668097720849;
    tokenTraits[74] = 5648262969168401;
    tokenTraits[75] = 5666264788816401;
    tokenTraits[76] = 5683444592939537;
  }

  /**
    @notice Sets the baseUri for the JBVeToken on IPFS.

    @param _contractURI The baseUri for the JBVeToken on IPFS.  
  */
  function setcontractURI(string memory _contractURI) public onlyOwner {
    contractURI = _contractURI;
  }

  /**
    @notice Returns a fully qualified URI containing encoded token image data and metadata.
   */
  function tokenURI(
    uint256 _tokenId,
    uint256 _amount,
    uint256 _duration,
    uint256 _lockedUntil,
    uint256[] memory _lockDurationOptions
  ) public view override returns (string memory) {
    uint16 tokenTranslation = uint16((_getTokenRange(_amount) * 5 + _getTokenStakeMultiplier(_duration, _lockDurationOptions)) % 76);
    uint256 traits = tokenTraits[tokenTranslation];

    string memory json = Base64.encode(
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
        _getImageStack(assets, traits),
        '</g><text font-size="90" fill="white" text-anchor="middle" x="700" dominant-baseline="mathematical"><textPath id="topText" href="#textPathTop">10 DAYS</textPath></text><text font-size="90" fill="white" text-anchor="middle" x="710" dominant-baseline="mathematical"><textPath id="bottomText" href="#textPathBottom"></textPath></text></svg>'
      )
    );
  }

  function _getTokenRange(uint256 _amount) private pure returns (uint256) {
    _amount = _amount / 10**18;

    if (_amount < 100) {
      return 0;
    } else if (_amount < 200) {
      return 1;
    } else if (_amount < 300) {
      return 2;
    } else if (_amount < 400) {
      return 3;
    } else if (_amount < 500) {
      return 4;
    } else if (_amount < 600) {
      return 5;
    } else if (_amount < 700) {
      return 6;
    } else if (_amount < 800) {
      return 7;
    } else if (_amount < 900) {
      return 8;
    } else if (_amount < 1_000) {
      return 9;
    } else if (_amount < 2_000) {
      return 10;
    } else if (_amount < 3_000) {
      return 11;
    } else if (_amount < 4_000) {
      return 12;
    } else if (_amount < 5_000) {
      return 13;
    } else if (_amount < 6_000) {
      return 14;
    } else if (_amount < 7_000) {
      return 15;
    } else if (_amount < 8_000) {
      return 16;
    } else if (_amount < 9_000) {
      return 17;
    } else if (_amount < 10_000) {
      return 18;
    } else if (_amount < 12_000) {
      return 19;
    } else if (_amount < 14_000) {
      return 20;
    } else if (_amount < 16_000) {
      return 21;
    } else if (_amount < 18_000) {
      return 22;
    } else if (_amount < 20_000) {
      return 23;
    } else if (_amount < 22_000) {
      return 24;
    } else if (_amount < 24_000) {
      return 25;
    } else if (_amount < 26_000) {
      return 26;
    } else if (_amount < 28_000) {
      return 27;
    } else if (_amount < 30_000) {
      return 28;
    } else if (_amount < 40_000) {
      return 29;
    } else if (_amount < 50_000) {
      return 30;
    } else if (_amount < 60_000) {
      return 31;
    } else if (_amount < 70_000) {
      return 32;
    } else if (_amount < 80_000) {
      return 33;
    } else if (_amount < 90_000) {
      return 34;
    } else if (_amount < 100_000) {
      return 35;
    } else if (_amount < 200_000) {
      return 36;
    } else if (_amount < 300_000) {
      return 37;
    } else if (_amount < 400_000) {
      return 38;
    } else if (_amount < 500_000) {
      return 39;
    } else if (_amount < 600_000) {
      return 40;
    } else if (_amount < 700_000) {
      return 41;
    } else if (_amount < 800_000) {
      return 42;
    } else if (_amount < 900_000) {
      return 43;
    } else if (_amount < 1_000_000) {
      return 44;
    } else if (_amount < 2_000_000) {
      return 45;
    } else if (_amount < 3_000_000) {
      return 46;
    } else if (_amount < 4_000_000) {
      return 47;
    } else if (_amount < 5_000_000) {
      return 48;
    } else if (_amount < 6_000_000) {
      return 49;
    } else if (_amount < 7_000_000) {
      return 50;
    } else if (_amount < 8_000_000) {
      return 51;
    } else if (_amount < 9_000_000) {
      return 52;
    } else if (_amount < 10_000_000) {
      return 53;
    } else if (_amount < 20_000_000) {
      return 54;
    } else if (_amount < 40_000_000) {
      return 55;
    } else if (_amount < 60_000_000) {
      return 56;
    } else if (_amount < 100_000_000) {
      return 57;
    } else if (_amount < 600_000_000) {
      return 58;
    } else {
      return 59;
    }
  }

  function _getTokenStakeMultiplier(uint256 _duration, uint256[] memory _lockDurationOptions)
    private
    pure
    returns (uint256)
  {
    for (uint256 _i = 0; _i < _lockDurationOptions.length; _i++) {
      if (_lockDurationOptions[_i] == _duration) {
        return _i + 1;
      }
    }
    revert INVALID_LOCK_DURATION(_duration);
  }
}
