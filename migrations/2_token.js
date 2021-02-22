// ============ Contracts ============

// Token
// deployed first
const Token = artifacts.require('Token')
const Cash = artifacts.require('Cash')
const Bond = artifacts.require('Bond')
const Share = artifacts.require('Share')
const MockBUSD = artifacts.require('MockBUSD');

// ============ Main Migration ============

const migration = async (deployer, network, accounts) => {
  await Promise.all([deployToken(deployer, network, accounts)])
}

module.exports = migration

// ============ Deploy Functions ============

async function deployToken(deployer, network, accounts) {
  await deployer.deploy(Token);
  await deployer.deploy(Cash);
  await deployer.deploy(Bond);
  await deployer.deploy(Share);
  if (network === 'dev') {
    const busd = await deployer.deploy(MockBUSD);
    console.log(`MockBUSD address: ${busd.address}`);
  }
}
