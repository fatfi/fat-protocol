# FATFI.IO

FATFI has some unique features over other algorithmic stablecoins.

### Token 
+ Token: [0x90e767a68a7d707b74d569c8e79f9bbb79b98a8b](https://bscscan.com/token/0x90e767a68a7d707b74d569c8e79f9bbb79b98a8b)
+ Cash: [0x6D5c0D359ad489bC6603fAdd16554B1dd3E8F9cB](https://bscscan.com/token/0x6D5c0D359ad489bC6603fAdd16554B1dd3E8F9cB)
+ Bond: [0x0c8c5d77D054c764A28DAa65eEa2e2a0DA6b85A4](https://bscscan.com/token/0x0c8c5d77D054c764A28DAa65eEa2e2a0DA6b85A4)
+ Share: [0xaC97Ad4606Dd239d3b656cBfe9b13d81dC8afB6B](https://bscscan.com/token/0xaC97Ad4606Dd239d3b656cBfe9b13d81dC8afB6B)
### Pool
+ BUSDFACLPTokenSharePool: [0x2720Ce92A751c96c8fe126395D585C6bBE2acDfd](https://bscscan.com/address/0x2720Ce92A751c96c8fe126395D585C6bBE2acDfd)
+ BUSDFASLPTokenSharePool: [0x45a62b352aE3077eB9D41B508E296F5fae8DB27A](https://bscscan.com/address/0x45a62b352aE3077eB9D41B508E296F5fae8DB27A)
+ BUSDFATLPTokenSharePool: [0x379f293770366D9A5864887a7BFabfc6c420AEFc](https://bscscan.com/address/0x379f293770366D9A5864887a7BFabfc6c420AEFc)
+ FACBUSDPool: [0xe212c81e1D4b8F22F096f6D06eAAD15663CEB0b4](https://bscscan.com/address/0xe212c81e1D4b8F22F096f6D06eAAD15663CEB0b4)



### Monetary Policy
+ Treasury: [0xf39f3ad536B4bA627500Ea114735eB526fA8CbdF](https://bscscan.com/address/0xf39f3ad536B4bA627500Ea114735eB526fA8CbdF)
+ Boardroom: [0x6Ba86145EBA300a2cB65A862c06C0A6d377ce4eE](https://bscscan.com/address/0x6Ba86145EBA300a2cB65A862c06C0A6d377ce4eE)
+ Oracle: [0xc20d029f568E39d3f6391Be173f13eA13a207aFC](https://bscscan.com/address/0xc20d029f568E39d3f6391Be173f13eA13a207aFC)

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
