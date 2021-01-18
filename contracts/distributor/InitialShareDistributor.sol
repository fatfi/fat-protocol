pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import '../interfaces/IDistributor.sol';
import '../interfaces/IRewardDistributionRecipient.sol';

contract InitialShareDistributor is IDistributor {
    using SafeMath for uint256;

    event Distributed(address pool, uint256 cashAmount);

    bool public once = true;

    IERC20 public share;
    IRewardDistributionRecipient public usdtfacLPPool;
    uint256 public usdtfacInitialBalance;
    IRewardDistributionRecipient public usdtfasLPPool;
    uint256 public usdtfasInitialBalance;

    constructor(
        IERC20 _share,
        IRewardDistributionRecipient _usdtfacLPPool,
        uint256 _usdtfacInitialBalance,
        IRewardDistributionRecipient _usdtfasLPPool,
        uint256 _usdtfasInitialBalance
    ) public {
        share = _share;
        usdtfacLPPool = _usdtfacLPPool;
        usdtfacInitialBalance = _usdtfacInitialBalance;
        usdtfasLPPool = _usdtfasLPPool;
        usdtfasInitialBalance = _usdtfasInitialBalance;
    }

    function distribute() public override {
        require(
            once,
            'InitialShareDistributor: you cannot run this function twice'
        );

        share.transfer(address(usdtfacLPPool), usdtfacInitialBalance);
        usdtfacLPPool.notifyRewardAmount(usdtfacInitialBalance);
        emit Distributed(address(usdtfacLPPool), usdtfacInitialBalance);

        share.transfer(address(usdtfasLPPool), usdtfasInitialBalance);
        usdtfasLPPool.notifyRewardAmount(usdtfasInitialBalance);
        emit Distributed(address(usdtfasLPPool), usdtfasInitialBalance);

        once = false;
    }
}
