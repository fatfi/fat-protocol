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

    IRewardDistributionRecipient public bnbFatLPPool;
    uint256 public bnbFatInitialBalance;

    constructor (
        IBEP20 _cash,
        IRewardDistributionRecipient _bnbFatLPPool,
        uint256 _bnbFatInitialBalance
    ) public {
        cash = _cash;
        bnbFatLPPool = _bnbFatLPPool;
        bnbFatInitialBalance = _bnbFatInitialBalance;
    }

    function distribute() public override {
        require(
            once,
            'InitialCashLpDistributor: you cannot run this function twice'
        );
        cash.transfer(address(bnbFatLPPool), bnbFatInitialBalance);
        bnbFatLPPool.notifyRewardAmount(bnbFatInitialBalance);
        emit Distributed(address(bnbFatLPPool), bnbFatInitialBalance);

        once = false;
    }
}
