// ============ Contracts ============

// Token
// deployed first
const Token = artifacts.require('Token')
const Cash = artifacts.require('Cash')
const Bond = artifacts.require('Bond')
const Share = artifacts.require('Share')

// ============ Main Migration ============

const migration = async (deployer, network, accounts) => {
  await Promise.all([deployToken(deployer, network, accounts)])
}

module.exports = migration

// ============ Deploy Functions ============

async function deployToken(deployer, network, accounts) {
  await deployer.deploy(Token,"0x6eBC585FEF5Cc2e1854e8c5b28d8E5ec289E3A52","0x2dA17e719B1799Be2Ae7859204bA0192c3BCaC7f","0x2dA17e719B1799Be2Ae7859204bA0192c3BCaC7f","0x2dA17e719B1799Be2Ae7859204bA0192c3BCaC7f");
  await deployer.deploy(Cash);
  await deployer.deploy(Bond);
  await deployer.deploy(Share);
}
