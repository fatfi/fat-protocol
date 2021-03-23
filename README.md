# FATFI.IO

FATFI has some unique features over other algorithmic stablecoins.

### Token 
+ Token: [0x90e767A68a7d707B74D569C8E79f9bBb79b98a8b](https://bscscan.com/token/0x90e767A68a7d707B74D569C8E79f9bBb79b98a8b)
+ Cash: [0xD6A49E581F7fB1b793a52fB21731BEA228A46B56](https://bscscan.com/token/0xD6A49E581F7fB1b793a52fB21731BEA228A46B56)
+ Bond: [0xFAedFCCa6ea3c9721218c05353beFf4dd6C30f00](https://bscscan.com/token/0xFAedFCCa6ea3c9721218c05353beFf4dd6C30f00)
+ Share: [0xa7348f2c2c3a85f9405D77F24ab23E6B091ECf29](https://bscscan.com/token/0xa7348f2c2c3a85f9405D77F24ab23E6B091ECf29)

### Pool
+ BUSDFACLPTokenSharePool: [0xF85f31b650C4F41956456f8e2D1367ffD06d6505](https://bscscan.com/address/0xF85f31b650C4F41956456f8e2D1367ffD06d6505)
+ BUSDFASLPTokenSharePool: [0x91459f4890Eb9112Dc25D0dd750218987AcCF688](https://bscscan.com/address/0x91459f4890Eb9112Dc25D0dd750218987AcCF688)
+ BUSDFATLPTokenSharePool: [0x037fE94F1c97C9a2E9F2F30D36B861d5A1B3A2d1](https://bscscan.com/address/0x037fE94F1c97C9a2E9F2F30D36B861d5A1B3A2d1)


### Monetary Policy
+ Treasury: [0xC0d35b3868293CdC8C21BE731E995c618F341c90](https://bscscan.com/address/0xC0d35b3868293CdC8C21BE731E995c618F341c90)
+ Boardroom: [0x006bBab9fA9886FaE47799958891EeF233cFE8d5](https://bscscan.com/address/0x006bBab9fA9886FaE47799958891EeF233cFE8d5)
+ Oracle: [0xA733db5905Dd60f79cD581550B46FA93A0d7157C](https://bscscan.com/address/0xA733db5905Dd60f79cD581550B46FA93A0d7157C)

## The Fatfi Protocol

Fatfi differs from the original Basis Project in several meaningful ways:

**A Three-token System** :
There three types (Cash,Bonds,Share) of assets in the Fatfi system

    Fat Cash ($FAC): a stablecoin, which the protocol aims to keep value-pegged to 1USD.
    Fat Bonds ($FAB): IOUs issued by the system to buy back Fat Cash when price($FAT) < $1. Bonds are sold at a meaningful discount to price($FAT), and redeemed at 1USD when price($FAT) normalizes to 1USD.
    Fat Shares ($FAS): receives surplus seigniorage (seigniorage left remaining after all the bonds have been redeemed).

**Fat Token ($FAT)**:  FAT will be reserved for liquidity rewards program after TGE

## Development
Rename `truffle-config.js.dev` to `truffle-config.js`
```
$ yarn install
$ truffle migrate --reset --network [option]

```

For security concerns, please submit an issue here.
``
dev@fatfi.io
``

© Copyright 2021, Fatfi.io
