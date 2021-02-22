const {
  fasPools,
  INITIAL_FAS_FOR_BUSD_FAC,
  INITIAL_FAS_FOR_BUSD_FAS,
} = require('./pools');

// Pools
// deployed first
const Share = artifacts.require('Share');
const InitialShareDistributor = artifacts.require('InitialShareDistributor');

// ============ Main Migration ============

async function migration(deployer, network, accounts) {
  const unit = web3.utils.toBN(10 ** 18);
  const totalBalanceForBUSDFAC = unit.muln(INITIAL_FAS_FOR_BUSD_FAC)
  const totalBalanceForBUSDFAS = unit.muln(INITIAL_FAS_FOR_BUSD_FAS)
  const totalBalance = totalBalanceForBUSDFAC.add(totalBalanceForBUSDFAS);

  const share = await Share.deployed();

  const lpPoolBUSDFAC = artifacts.require(fasPools.BUSDFAC.contractName);
  const lpPoolBUSDFAS = artifacts.require(fasPools.BUSDFAS.contractName);

  await deployer.deploy(
    InitialShareDistributor,
    share.address,
    lpPoolBUSDFAC.address,
    totalBalanceForBUSDFAC.toString(),
    lpPoolBUSDFAS.address,
    totalBalanceForBUSDFAS.toString(),
  );
  const distributor = await InitialShareDistributor.deployed();

  await share.mint(distributor.address, totalBalance.toString());
  console.log(`Deposited ${INITIAL_FAS_FOR_BUSD_FAC} FAS to InitialShareDistributor.`);

  console.log(`Setting distributor to InitialShareDistributor (${distributor.address})`);
  await lpPoolBUSDFAC.deployed().then(pool => pool.setRewardDistribution(distributor.address));
  await lpPoolBUSDFAS.deployed().then(pool => pool.setRewardDistribution(distributor.address));

  await distributor.distribute();
}

module.exports = migration;
