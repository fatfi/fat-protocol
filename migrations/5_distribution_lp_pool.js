const knownContracts = require('./known-contracts');
const { POOL_START_DATE } = require('./pools');
const IERC20 = artifacts.require('IERC20');

const Token = artifacts.require('Token');
const Cash = artifacts.require('Cash');
const Share = artifacts.require('Share');
const Oracle = artifacts.require('Oracle');
const MockToken = artifacts.require('MockToken');

const USDTFACLPToken_FASPool = artifacts.require('USDTFACLPTokenSharePool')
const USDTFASLPToken_FASPool = artifacts.require('USDTFASLPTokenSharePool')
const USDTFATLPToken_FACPool = artifacts.require('USDTFATLPTokenCashPool')

const UniswapV2Factory = artifacts.require('UniswapV2Factory');

module.exports = async (deployer, network, accounts) => {
  const uniswapFactory = ['dev'].includes(network)
    ? await UniswapV2Factory.deployed()
    : await UniswapV2Factory.at(knownContracts.UniswapV2Factory[network]);
  const usdt = ['dev'].includes(network)
    ? await MockToken.deployed()
    : await IERC20.at(knownContracts.USDT[network]);

  const oracle = await Oracle.deployed();

  const usdt_fac_lpt = await oracle.pairFor(uniswapFactory.address, Cash.address, usdt.address);
  const usdt_fas_lpt = await oracle.pairFor(uniswapFactory.address, Share.address, usdt.address);
  const usdt_fat_lpt = await oracle.pairFor(uniswapFactory.address, Token.address, usdt.address);

  await deployer.deploy(USDTFACLPToken_FASPool, Share.address, usdt_fac_lpt, POOL_START_DATE);
  await deployer.deploy(USDTFASLPToken_FASPool, Share.address, usdt_fas_lpt, POOL_START_DATE);
  await deployer.deploy(USDTFATLPToken_FACPool, Cash.address, Token.address, usdt_fat_lpt, POOL_START_DATE);
};
