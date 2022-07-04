// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

import './libraries/Base64.sol';
import './interfaces/IBannyCommonUtil.sol';
import './interfaces/IJBVeTokenUriResolver.sol';
import './BannyCommonUtil.sol';
import './enums/AssetDataType.sol';

/**
  @notice 

  @dev https://github.com/tankbottoms/jbx-staking/blob/master/contracts/JBVeTokenUriResolver.sol
 */
contract JBVeTokenUriResolver is IJBVeTokenUriResolver, Ownable {
  string public override contractURI;
  IStorage public assets;
  IBannyCommonUtil private bannyUtil;
  string public name;

  constructor(
    IStorage _assets,
    IBannyCommonUtil _bannyUtil,
    address _admin,
    string memory _name,
    string memory _contractURI
  ) {
    assets = _assets;
    bannyUtil = _bannyUtil;
    name = _name;
    contractURI = _contractURI;

    _transferOwnership(_admin);
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
    uint256, // _lockedUntil
    uint256[] memory _lockDurationOptions
  ) public view override returns (string memory) {
    uint16 tokenTranslation = uint16(
      (_getTokenRange(_amount) * 5 + _getTokenStakeMultiplier(_duration, _lockDurationOptions)) % 61
    );
    uint256 traits = bannyUtil.getIndexedTokenTraits(tokenTranslation);

    string memory json = Base64.encode(
      abi.encodePacked(
        '{"name": "',
        name,
        ' No.',
        Strings.toString(_tokenId),
        '", "description": "Fully on-chain NFT", "image": "data:image/svg+xml;base64,',
        _getFramedImage(traits, _duration),
        '", "attributes":',
        bannyUtil.getTokenTraits(traits),
        '}'
      )
    );

    return string(abi.encodePacked('data:application/json;base64,', json));
  }

  function _getFramedImage(uint256 _traits, uint256 _duration)
    internal
    view
    returns (string memory image)
  {
    uint256 dayDuration = _duration / 86_400;
    uint256 weekDuration = dayDuration / 7;
    uint256 yearDuration = weekDuration / 52;

    uint256 numericDuration;
    string memory durationTextLabel;
    if (yearDuration > 0) {
      durationTextLabel = 'YEARS';
      numericDuration = yearDuration;
    } else if (dayDuration > 0) {
      durationTextLabel = 'DAYS';
      numericDuration = dayDuration;
    } else if (weekDuration > 0) {
      durationTextLabel = 'WEEKS';
      numericDuration = weekDuration;
    }

    image = Base64.encode(
      abi.encodePacked(
        '<svg id="token" width="300" height="300" viewBox="0 0 1080 1080" fill="none" xmlns="http://www.w3.org/2000/svg"> <defs><radialGradient id="paint0_radial_772_22716" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(540.094 539.992) rotate(90) scale(539.413)"><stop stop-color="#B4B4B4" /><stop offset="1" /></radialGradient><path id="textPathBottom" d="M 540 540 m -450,0 a 450,450 0 1,0 900,0"/><path id="textPathTop" d="M 540 540 m -450,0 a 450,450 0 1,1 900,0" /><style>@font-face{font-family:"Pixel Font-7-on-chain";src:url(data:application/font-woff;charset=utf-8;base64,',
        bannyUtil.getAssetBase64(assets, uint64(9223372036854775809), AssetDataType.RAW_DATA),
        ') format("woff");font-weight:normal;font-style:normal;}</style></defs><circle cx="540.094" cy="539.992" r="539.413" fill="url(#paint0_radial_772_22716)"/><g id="bannyPlaceholder">',
        bannyUtil.getImageStack(assets, _traits),
        '</g><text font-family="Pixel Font-7-on-chain" font-size="90" fill="white" text-anchor="middle" x="700" dominant-baseline="mathematical"><textPath id="topText" href="#textPathTop">',
        Strings.toString(numericDuration),
        ' ',
        durationTextLabel,
        '</textPath></text><text font-size="90" fill="white" text-anchor="middle" x="710" dominant-baseline="mathematical"><textPath id="bottomText" href="#textPathBottom"></textPath></text></svg>'
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
