const contract = require('@truffle/contract');
const { POOL_START_DATE , ORACLE_START_DATE} = require('./pools');
const knownContracts = require('./known-contracts');

const Token = artifacts.require('Token');
const Cash = artifacts.require('Cash');
const Bond = artifacts.require('Bond');
const Share = artifacts.require('Share');
const IBEP20 = artifacts.require('IBEP20');
const MockBEP20 = artifacts.require('MockBEP20');
const MockWBNB = artifacts.require('MockWBNB');

const Oracle = artifacts.require('Oracle')
const Boardroom = artifacts.require('Boardroom')
const Treasury = artifacts.require('Treasury')

const UniswapV2Factory = artifacts.require('UniswapV2Factory');
const UniswapV2Router02 = artifacts.require('UniswapV2Router02');

const HOUR = 60 * 60;
const DAY = 86400;


async function migration(deployer, network, accounts) {
  let uniswap, uniswapRouter, busd;
  if (['dev'].includes(network)) {

    await deployer.deploy(MockWBNB);

    console.log('Deploying pancakeswap on dev network.');

    await deployer.deploy(UniswapV2Factory, accounts[0]);
    uniswap = await UniswapV2Factory.deployed();

    await deployer.deploy(UniswapV2Router02, uniswap.address, MockWBNB.address);
    uniswapRouter = await UniswapV2Router02.deployed();


    //uniswap = await UniswapV2Factory.at(knownContracts.UniswapV2Factory[network]);
    //uniswapRouter = await UniswapV2Router02.at(knownContracts.UniswapV2Router02[network]);
    busd = await deployer.deploy(MockBEP20, 'BUSD Token', 'BUSD', 18);
  } else {
    await deployer.deploy(MockWBNB);
    console.log('Deploying pancakeswap on network.');
    uniswap = await UniswapV2Factory.at(knownContracts.UniswapV2Factory[network]);
    uniswapRouter = await UniswapV2Router02.at(knownContracts.UniswapV2Router02[network]);
    busd = await IBEP20.at(knownContracts.BUSD[network]);
  }


  console.log(`busd address: ${busd.address}`);

  // 2. provide liquidity to FAC-BUSD, FAS-BUSD and FAT-BUSD pair
  // if you don't provide liquidity to FAC-BUSD, FAS-BUSD and FAT-BUSD pair after step 1 and before step 3,
  //  creating Oracle will fail with NO_RESERVES error.
  const unit = web3.utils.toBN(10 ** 18).toString();
  const unitB = web3.utils.toBN(10 ** 18).toString();
  const max = web3.utils.toBN(10 ** 18).muln(10000).toString();

  const token = await Token.deployed();
  const cash = await Cash.deployed();
  const share = await Share.deployed();

  console.log('Approving pancakeswap on tokens for liquidity');
  await Promise.all([
    approveIfNot(token, accounts[0], uniswapRouter.address, max),
    approveIfNot(cash, accounts[0], uniswapRouter.address, max),
    approveIfNot(share, accounts[0], uniswapRouter.address, max),
    approveIfNot(busd, accounts[0], uniswapRouter.address, max),
  ]);

  // WARNING: msg.sender must hold enough BUSD to add liquidity to FAC-BUSD , FAS-BUSD &  FAT-BUSD  pools
  // otherwise tranFACtion will revert
  console.log('Adding liquidity to pools');

  await uniswapRouter.addLiquidity(
      cash.address, busd.address, unit, unitB, unit, unitB, accounts[0], deadline(),
  );
  await uniswapRouter.addLiquidity(
      share.address, busd.address, unit, unitB, unit, unitB, accounts[0],  deadline(),
  );

  console.log(`BUSD-FAC pair address: ${await uniswap.getPair(busd.address, cash.address)}`);
  console.log(`BUSD-FAS pair address: ${await uniswap.getPair(busd.address, share.address)}`);

  // Deploy boardroom
  await deployer.deploy(Boardroom, cash.address, share.address);

  // 2. Deploy oracle for the pair between fac and busd
  await deployer.deploy(
    Oracle,
    uniswap.address,
    cash.address, 
    busd.address,
    DAY,
    ORACLE_START_DATE
  );

  let REBASE_START_DATE = POOL_START_DATE;
  if (network === 'mainnet') {
    REBASE_START_DATE += 5 * DAY;
  }

  await deployer.deploy(
    Treasury,
    cash.address,
    Bond.address,
    Share.address,
    Oracle.address,
    Boardroom.address,
    REBASE_START_DATE
  );
}

async function approveIfNot(token, owner, spender, amount) {
  const allowance = await token.allowance(owner, spender);
  if (web3.utils.toBN(allowance).gte(web3.utils.toBN(amount))) {
    return;
  }
  await token.approve(spender, amount);
  console.log(` - Approved ${token.symbol ? (await token.symbol()) : token.address}`);
}

function deadline() {
  // 30 minutes
  return Math.floor(new Date().getTime() / 1000) + 1800;
}

module.exports = migration;
