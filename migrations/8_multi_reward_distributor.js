const { fatPools, INITIAL_FAT_FOR_FAT_POOLS , INITIAL_FAC_FOR_FAT_POOLS } = require('./pools');

// Pools
// deployed first
const Token = artifacts.require('Token')
const Cash = artifacts.require('Cash')
const InitialTokenDistributor = artifacts.require('InitialTokenDistributor');

// ============ Main Migration ============

module.exports = async (deployer, network, accounts) => {
  const unit = web3.utils.toBN(10 ** 18);
  const initialCashAmount1 = unit.muln(INITIAL_FAC_FOR_FAT_POOLS).toString();
  const initialCashAmount2 = unit.muln(INITIAL_FAT_FOR_FAT_POOLS).toString();
  const cash = await Cash.deployed();
  const token = await Token.deployed();
  const pools = fatPools.map(({contractName}) => artifacts.require(contractName));

  await deployer.deploy(
    InitialTokenDistributor,
    cash.address,
    token.address,
    pools.map(p => p.address),
    initialCashAmount1,
    initialCashAmount2,
  );

  const distributor = await InitialTokenDistributor.deployed();

  console.log(`Setting distributor to InitialTokenDistributor (${distributor.address})`);
  for await (const poolInfo of pools) {
    const pool = await poolInfo.deployed()
    await pool.setRewardDistribution(distributor.address);
  }

  await cash.mint(distributor.address, initialCashAmount1);
  console.log(`Deposited ${INITIAL_FAC_FOR_FAT_POOLS} FAC to InitialTokenDistributor.`);
  await token.mint(distributor.address, initialCashAmount2);
  console.log(`Deposited ${INITIAL_FAT_FOR_FAT_POOLS} FAT to InitialTokenDistributor.`);

  await distributor.distribute();
}
