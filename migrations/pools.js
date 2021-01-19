// https://docs.stand.cash/mechanisms/yield-farming
const INITIAL_FAT_FOR_FAT_POOLS = 78000; // 5 days
const INITIAL_FAC_FOR_FAT_POOLS = 20000; //  5 days
const INITIAL_FAC_FOR_POOLS = 180000; // 18 pools
const INITIAL_FAS_FOR_USDT_FAC = 750000;
const INITIAL_FAS_FOR_USDT_FAS = 250000; // 365 days

const POOL_START_DATE = Date.parse('2021-01-20T12:00:00Z') / 1000;

const fatPools = [
  { contractName: 'USDTFATLPTokenCashPool', token: 'USDT_FAT-LPv2' },
]

const facPools = [
  { contractName: 'FACDAIPool', token: 'DAI' },
  { contractName: 'FACBUSDPool', token: 'BUSD' },
  { contractName: 'FACUSDTPool', token: 'USDT' },
  { contractName: 'FACUSDCPool', token: 'USDC' },
  { contractName: 'FACSUSDPool', token: 'SUSD' },
  { contractName: 'FACESDPool', token: 'ESD' },
  { contractName: 'FACBACPool', token: 'BAC' },
  { contractName: 'FACMICPool', token: 'MIC' },
  { contractName: 'FACUNIPool', token: 'UNI' },
  { contractName: 'FACYFIPool', token: 'YFI' },
  { contractName: 'FACSUSHIPool', token: 'SUSHI' },
  { contractName: 'FACCREAMPool', token: 'CREAM' },
  { contractName: 'FACCOMPPool', token: 'COMP' },
  { contractName: 'FACAAVEPool', token: 'AAVE' },
  { contractName: 'FACCRVPool', token: 'CRV' },
  { contractName: 'FACLINKPool', token: 'LINK' },
  { contractName: 'FACINCHPool', token: 'INCH' },
  { contractName: 'FACWETHPool', token: 'WETH' },
];

const fasPools = {
  USDTFAC: { contractName: 'USDTFACLPTokenSharePool', token: 'USDT_FAC-LPv2' },
  USDTFAS: { contractName: 'USDTFASLPTokenSharePool', token: 'USDT_FAS-LPv2' },
}

module.exports = {
  POOL_START_DATE,
  INITIAL_FAT_FOR_FAT_POOLS,
  INITIAL_FAC_FOR_FAT_POOLS,
  INITIAL_FAC_FOR_POOLS,
  INITIAL_FAS_FOR_USDT_FAC,
  INITIAL_FAS_FOR_USDT_FAS,
  fatPools,
  facPools,
  fasPools,
};
