// https://docs.stand.cash/mechanisms/yield-farming
const INITIAL_FAC_FOR_POOLS = 180000; // 18 pools
const INITIAL_FAS_FOR_BUSD_FAC = 750000;
const INITIAL_FAS_FOR_BUSD_FAS = 250000; // 365 days

const POOL_START_DATE = Date.parse('2021-02-24T09:30:00Z') / 1000;
console.log('POOL_START_DATE = '+POOL_START_DATE);
const ORACLE_START_DATE = Date.parse('2021-02-24T09:30:00Z') / 1000;
console.log('ORACLE_START_DATE = '+ORACLE_START_DATE);

const facPools = [
  { contractName: 'FACBUSDPool', token: 'BUSD' },
];

const fasPools = {
  BUSDFAC: { contractName: 'BUSDFACLPTokenSharePool', token: 'BUSD_FAC-LPv2' },
  BUSDFAS: { contractName: 'BUSDFASLPTokenSharePool', token: 'BUSD_FAS-LPv2' },
}

module.exports = {
  POOL_START_DATE,
  ORACLE_START_DATE,
  INITIAL_FAC_FOR_POOLS,
  INITIAL_FAS_FOR_BUSD_FAC,
  INITIAL_FAS_FOR_BUSD_FAS,
  facPools,
  fasPools,
};
