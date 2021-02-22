pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '../lib/IBEP20.sol';

import '../interfaces/IDistributor.sol';
import '../interfaces/IRewardDistributionRecipient.sol';

contract InitialShareDistributor is IDistributor {
    using SafeMath for uint256;

    event Distributed(address pool, uint256 cashAmount);

    bool public once = true;

    IBEP20 public share;
    IRewardDistributionRecipient public busdFacLPPool;
    uint256 public busdFacInitialBalance;
    IRewardDistributionRecipient public busdFasLPPool;
    uint256 public busdFasInitialBalance;

    constructor(
        IBEP20 _share,
        IRewardDistributionRecipient _busdFacLPPool,
        uint256 _busdFacInitialBalance,
        IRewardDistributionRecipient _busdFasLPPool,
        uint256 _busdFasInitialBalance
    ) public {
        share = _share;
        busdFacLPPool = _busdFacLPPool;
        busdFacInitialBalance = _busdFacInitialBalance;
        busdFasLPPool = _busdFasLPPool;
        busdFasInitialBalance = _busdFasInitialBalance;
    }

    function distribute() public override {
        require(
            once,
            'InitialShareDistributor: you cannot run this function twice'
        );

        share.transfer(address(busdFacLPPool), busdFacInitialBalance);
        busdFacLPPool.notifyRewardAmount(busdFacInitialBalance);
        emit Distributed(address(busdFacLPPool), busdFacInitialBalance);

        share.transfer(address(busdFasLPPool), busdFasInitialBalance);
        busdFasLPPool.notifyRewardAmount(busdFasInitialBalance);
        emit Distributed(address(busdFasLPPool), busdFasInitialBalance);

        once = false;
    }
}
