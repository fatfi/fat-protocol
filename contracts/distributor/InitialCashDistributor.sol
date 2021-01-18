pragma solidity ^0.6.0;
// K-Rewards Pools - Stablecoins
import '../distribution/FACDAIPool.sol';
import '../distribution/FACUSDTPool.sol';
import '../distribution/FACUSDCPool.sol';
import '../distribution/FACBUSDPool.sol';
import '../distribution/FACSUSDPool.sol';
import '../distribution/FACESDPool.sol';
import '../distribution/FACBACPool.sol';
import '../distribution/FACMICPool.sol';

// K-Rewards Pools - Communities
import '../distribution/FACUNIPool.sol';
import '../distribution/FACYFIPool.sol';
import '../distribution/FACSUSHIPool.sol';
import '../distribution/FACCREAMPool.sol';
import '../distribution/FACCOMPPool.sol';
import '../distribution/FACAAVEPool.sol';
import '../distribution/FACCRVPool.sol';
import '../distribution/FACLINKPool.sol';
import '../distribution/FACINCHPool.sol';
import '../distribution/FACWETHPool.sol';
import '../interfaces/IDistributor.sol';

contract InitialCashDistributor is IDistributor {
    using SafeMath for uint256;

    event Distributed(address pool, uint256 cashAmount);

    bool public once = true;

    IERC20 public cash;
    IRewardDistributionRecipient[] public pools;
    uint256 public totalInitialBalance;

    constructor(
        IERC20 _cash,
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
