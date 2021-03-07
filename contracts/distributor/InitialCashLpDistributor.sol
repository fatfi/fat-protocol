pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '../lib/IBEP20.sol';

import '../interfaces/IDistributor.sol';
import '../interfaces/IRewardDistributionRecipient.sol';

contract InitialCashLpDistributor is IDistributor {

    using SafeMath for uint256;

    event Distributed(address pool, uint256 cashAmount);

    bool public once = true;

    IBEP20 public cash;

    IRewardDistributionRecipient public busdFatLPPool;
    uint256 public busdFatInitialBalance;

    constructor (
        IBEP20 _cash,
        IRewardDistributionRecipient _busdFatLPPool,
        uint256 _busdFatInitialBalance
    ) public {
        cash = _cash;
        busdFatLPPool = _busdFatLPPool;
        busdFatInitialBalance = _busdFatInitialBalance;
    }

    function distribute() public override {
        require(
            once,
            'InitialCashLpDistributor: you cannot run this function twice'
        );
        cash.transfer(address(busdFatLPPool), busdFatInitialBalance);
        busdFatLPPool.notifyRewardAmount(busdFatInitialBalance);
        emit Distributed(address(busdFatLPPool), busdFatInitialBalance);

        once = false;
    }
}
