# FATFI.IO

FATFI has some unique features over other algorithmic stablecoins.
## DiffChecker
* [Diff checker: BasisDollar and Fatfi](https://www.diffchecker.com/KVlWQm0A)


## The Fatfi Protocol

Fatfi differs from the original Basis Project in several meaningful ways:
**FAT Token (FAT)** :
FAT total supply is at 200 million FAT. With a proportion of 40% - 80 million FAT will be reserved for Liquidity Rewards Program. The base reward is 12 FAT per block divided across many pools

**A Four-token System** :
There four types (Token,Cash,Bonds,Share) of assets in the Fatfi system

    Fat Cash ($FAT): a stablecoin, which the protocol aims to keep value-pegged to 1USD.
    Fat Bonds ($FAB): IOUs issued by the system to buy back Fat Cash when price($FAT) < $1. Bonds are sold at a meaningful discount to price($FAT), and redeemed at 1USD when price($FAT) normalizes to 1USD.
    Fat Shares ($FAS): receives surplus seigniorage (seigniorage left remaining after all the bonds have been redeemed).
    Fat Token ($FAT):  FAT will be reserved for liquidity rewards program after TGE

## Usage
Contract Address:
* [Mainnet]()
* [Ropsten](https://ropsten.etherscan.io/address/0x5f81f85a25a6e330bda410c0e7ceb35f8473b072)

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
