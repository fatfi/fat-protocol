const {
  fasPools,
  INITIAL_FAS_FOR_USDT_FAC,
  INITIAL_FAS_FOR_USDT_FAS,
} = require('./pools');

// Pools
// deployed first
const Share = artifacts.require('Share');
const InitialShareDistributor = artifacts.require('InitialShareDistributor');

// ============ Main Migration ============

async function migration(deployer, network, accounts) {
  const unit = web3.utils.toBN(10 ** 18);
  const totalBalanceForUSDTFAC = unit.muln(INITIAL_FAS_FOR_USDT_FAC)
  const totalBalanceForUSDTFAS = unit.muln(INITIAL_FAS_FOR_USDT_FAS)
  const totalBalance = totalBalanceForUSDTFAC.add(totalBalanceForUSDTFAS);

  const share = await Share.deployed();

  const lpPoolUSDTFAC = artifacts.require(fasPools.USDTFAC.contractName);
  const lpPoolUSDTFAS = artifacts.require(fasPools.USDTFAS.contractName);

  await deployer.deploy(
    InitialShareDistributor,
    share.address,
    lpPoolUSDTFAC.address,
    totalBalanceForUSDTFAC.toString(),
    lpPoolUSDTFAS.address,
    totalBalanceForUSDTFAS.toString(),
  );
  const distributor = await InitialShareDistributor.deployed();

  await share.mint(distributor.address, totalBalance.toString());
  console.log(`Deposited ${INITIAL_FAS_FOR_USDT_FAC} FAS to InitialShareDistributor.`);

  console.log(`Setting distributor to InitialShareDistributor (${distributor.address})`);
  await lpPoolUSDTFAC.deployed().then(pool => pool.setRewardDistribution(distributor.address));
  await lpPoolUSDTFAS.deployed().then(pool => pool.setRewardDistribution(distributor.address));

  await distributor.distribute();
}

module.exports = migration;
