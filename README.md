# FATFI.IO

FATFI has some unique features over other algorithmic stablecoins.
## Contract Addresses
| Contract  | Address |
| ------------- | ------------- |
| Token ($FAT) | [0xxxx](https://etherscan.io/token/0xxx) |
| Cash ($FAC) | [0xxxx](https://etherscan.io/token/0xxx) |
| Share ($FAS) | [0xxxx](https://xxx) |
| Bond ($FAB) | [0xxxx](https://xxx) |
| Treasury | [0xxxx](https://xxx) |
| Boardroom | [0xxxx](https://xxx) |
| Stables Farming Pool | [0xxxx](https://xxx#code) |
| Timelock 24h | [0xxxx](https://etherscan.io/token/0xxx) |

## DiffChecker
* [Diff checker: BasisCash and Fatfi](https://www.diffchecker.com/KVlWQm0A)


## The Fatfi Protocol

Fatfi differs from the original Basis Project in several meaningful ways:

**Fat Token (FAT)** : 
FAT total supply is at 200 million FAT. With a proportion of 40% - 80 million FAT will be reserved for Liquidity Rewards Program. The base reward is 12 FAT per block divided across many pools

**Multiple Reward (FAT+FAC)** :
This is the Exclusive pool that will give 2 rewards during the Genesis Event (USDTFATLPTokenCashPool)

**TBA Pools** :
There are the exclusive pools that will give FAT(Token) rewards after TGE ,The base reward is 12 FAT per block divided across many pools:
``FAT – FAC``
``FAT– FAS``
``Pools TBA (Update on next deploy)``

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
