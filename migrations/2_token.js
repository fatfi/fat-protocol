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
  await deployer.deploy(Token,"0x9F8A4F6950D21C535965d7ac8fB2461A1cecc905","0xCFfa1E1805aF7feA74a8FF2A59ea184c2cE83586","0xCFfa1E1805aF7feA74a8FF2A59ea184c2cE83586","0xCFfa1E1805aF7feA74a8FF2A59ea184c2cE83586");
  await deployer.deploy(Cash);
  await deployer.deploy(Bond);
  await deployer.deploy(Share);
}
