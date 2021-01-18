pragma solidity ^0.6.0;
import '../distribution/USDTFATLPTokenCashPool.sol';
import '../interfaces/IDistributor.sol';

contract InitialTokenDistributor is IDistributor {
    using SafeMath for uint256;

    event Distributed(address pool, uint256 cashAmount);

    bool public once = true;

    IERC20 public cash;
    IERC20 public token;
    IRewardDistributionRecipient[] public pools;
    uint256 public totalInitialBalance1;
    uint256 public totalInitialBalance2;

    constructor(
        IERC20 _cash,
        IERC20 _token,
        IRewardDistributionRecipient[] memory _pools,
        uint256 _totalInitialBalance1,
        uint256 _totalInitialBalance2
    ) public {
        require(_pools.length != 0, 'a list of FAT pools are required');
        cash = _cash;
        token = _token;
        pools = _pools;
        totalInitialBalance1 = _totalInitialBalance1;
        totalInitialBalance2 = _totalInitialBalance2;
    }

    function distribute() public override {
        require(
            once,
            'InitialTokenDistributor: you cannot run this function twice'
        );

        for (uint256 i = 0; i < pools.length; i++) {
            uint256 amount1 = totalInitialBalance1.div(pools.length);
            uint256 amount2 = totalInitialBalance2.div(pools.length);

            cash.transfer(address(pools[i]), amount1);
            emit Distributed(address(pools[i]), amount1);
            token.transfer(address(pools[i]), amount2);
            emit Distributed(address(pools[i]), amount2);
            pools[i].notifyRewardAmount(amount1);
        }

        once = false;
    }
}
