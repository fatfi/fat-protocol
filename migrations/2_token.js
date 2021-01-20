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
  await deployer.deploy(Token,"0x4c823337a345dc77Fc2620783f84F3bA29C567f1","0x919cA80bB6CEFc164C37622219424c1BDe3dFEB0","0x919cA80bB6CEFc164C37622219424c1BDe3dFEB0","0x919cA80bB6CEFc164C37622219424c1BDe3dFEB0");
  await deployer.deploy(Cash);
  await deployer.deploy(Bond);
  await deployer.deploy(Share);
}
