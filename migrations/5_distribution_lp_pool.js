const knownContracts = require('./known-contracts');
const { POOL_START_DATE } = require('./pools');

const Cash = artifacts.require('Cash');
const Share = artifacts.require('Share');
const Oracle = artifacts.require('Oracle');
const MockBEP20 = artifacts.require('MockBEP20');
const IBEP20 = artifacts.require('IBEP20');

const BUSDFACLPToken_FASPool = artifacts.require('BUSDFACLPTokenSharePool')
const BUSDFASLPToken_FASPool = artifacts.require('BUSDFASLPTokenSharePool')

const UniswapV2Factory = artifacts.require('UniswapV2Factory');

module.exports = async (deployer, network, accounts) => {
  const uniswapFactory = ['dev'].includes(network)
    ? await UniswapV2Factory.deployed()
    : await UniswapV2Factory.at(knownContracts.UniswapV2Factory[network]);
  const busd = ['dev'].includes(network)
    ? await MockBEP20.deployed()
    : await IBEP20.at(knownContracts.BUSD[network]);

  const oracle = await Oracle.deployed();

  const busd_fac_lpt = await oracle.pairFor(uniswapFactory.address, Cash.address, busd.address);
  const busd_fas_lpt = await oracle.pairFor(uniswapFactory.address, Share.address, busd.address);

  await deployer.deploy(BUSDFACLPToken_FASPool, Share.address, busd_fac_lpt, POOL_START_DATE);
  await deployer.deploy(BUSDFASLPToken_FASPool, Share.address, busd_fas_lpt, POOL_START_DATE);

};
