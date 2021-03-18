pragma solidity ^0.6.0;

// K-Rewards Pools - Communities
import '../distribution/FACGUMPool.sol';
import '../distribution/FACSFPPool.sol';
import '../distribution/FACTWTPool.sol';
import '../distribution/FACLINKPool.sol';
import '../distribution/FACFATPool.sol';
import '../distribution/FACADAPool.sol';
import '../distribution/FACDOTPool.sol';
import '../distribution/FACSXPPool.sol';
import '../distribution/FACXRPPool.sol';
import '../distribution/FACWBNBPool.sol';
import '../distribution/FACETHPool.sol';
import '../distribution/FACBURGERPool.sol';
import '../distribution/FACBAKEPool.sol';
import '../distribution/FACCAKEPool.sol';
// K-Rewards Pools - Stablecoins
import '../distribution/FACUSDCPool.sol';
import '../distribution/FACBUSDPool.sol';
import '../distribution/FACDAIPool.sol';
import '../distribution/FACBUSDTPool.sol';
import '../interfaces/IDistributor.sol';

contract InitialCashDistributor is IDistributor {
    using SafeMath for uint256;

    event Distributed(address pool, uint256 cashAmount);

    bool public once = true;

    IBEP20 public cash;
    IRewardDistributionRecipient[] public pools;
    uint256 public totalInitialBalance;

    constructor(
        IBEP20 _cash,
        IRewardDistributionRecipient[] memory _pools,
        uint256 _totalInitialBalance

    ) public {
        require(_pools.length != 0, 'a list of FAC pools are required');
        cash = _cash;
        pools = _pools;
        totalInitialBalance = _totalInitialBalance;
    }

    function distribute() public override {
        require(
            once,
            'InitialCashDistributor: you cannot run this function twice'
        );

        for (uint256 i = 0; i < pools.length; i++) {
            uint256 amount = totalInitialBalance.div(pools.length);

            cash.transfer(address(pools[i]), amount);
            pools[i].notifyRewardAmount(amount);

            emit Distributed(address(pools[i]), amount);
        }

        once = false;
    }
}
