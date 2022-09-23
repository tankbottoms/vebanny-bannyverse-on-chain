## Bannyverse Tokens

### Tests

`npx hardhat test`

```bash
 ·------------------------|--------------|----------------·
 |  Contract Name         ·  Size (KiB)  ·  Change (KiB)  │
 ·························|··············|·················
 |  BannyCommonUtil       ·      23.109  ·                │
 ·························|··············|·················
 |  JBVeTokenUriResolver  ·      10.366  ·                │
 ·························|··············|·················
 |  Storage               ·      18.746  ·                │
 ·························|··············|·················
 |  Token                 ·      19.013  ·                │
 ·------------------------|--------------|----------------·


  Banny Asset Storage Tests
total gas: 454649971
    ✔ Load PNG assets (16773ms)
total gas: 812335
    ✔ Load font assets (38ms)
total gas: 29349472
    ✔ Load audio assets (557ms)
cumulative gas 484811778
    ✔ Cumulative Gas

  veBanny URI Resolver Tests
Initializing contracts
Contracts deployed in 16.747s
Started character definition tests
Finished character definition tests in 17.711s
    ✔ Character Definition Tests (17711ms)
    ✔ InvalidLockDuration Test
Started contribution tiers tests
Finished contribution tiers tests in 69.372s
    ✔ Contribution Tiers Tests (69372ms)

  BannyVerse Tests
    ✔ Basic Mint Tests (12117ms)
    ✔ Permissions Tests
    ✔ supportsInterface() Test
    ✔ Contract Metadata Tests
    ✔ Transfer Tests
    ✔ Merkle Mint Tests (86ms)


  13 passing (3m)

Time: 0h:02m:33s
```
