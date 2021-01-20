pragma solidity ^0.6.0;
/**
 *Submitted for verification at Etherscan.io on 2020-07-17
 */

/*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Synthetix: FATCASHRewards.sol
*
* Docs: https://docs.synthetix.io/
*
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

// File: @openzeppelin/contracts/math/Math.sol

import '@openzeppelin/contracts/math/Math.sol';

// File: @openzeppelin/contracts/math/SafeMath.sol

import '@openzeppelin/contracts/math/SafeMath.sol';

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

// File: @openzeppelin/contracts/utils/Address.sol

import '@openzeppelin/contracts/utils/Address.sol';

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';

// File: contracts/IRewardDistributionRecipient.sol

import '../interfaces/IRewardDistributionRecipient.sol';

import '../token/LPTokenWrapper.sol';

contract USDTFATLPTokenCashPool is
LPTokenWrapper,
IRewardDistributionRecipient
{
    IERC20 public fatCash;
    IERC20 public fatToken;
    uint256 public DURATION = 5 days;

    uint256 public initreward = 20000 * 10**18; // 20,000 Cash
    uint256 public starttime; // starttime TBD
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 public reward_per_block = 12;  // 12 fat / 1 block
    mapping(address => uint256) public userFatRewardDebtAtBlock; // the last block user stake
    mapping(address => uint256) public fatRewards; // total user's fat rewards

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(
        address fatCash_,
        address fatToken_,
        address lptoken_,
        uint256 starttime_
    ) public {
        fatCash = IERC20(fatCash_);
        fatToken = IERC20(fatToken_);
        lpt = IERC20(lptoken_);
        starttime = starttime_;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
            fatRewards[account] = earned2(account);
            userFatRewardDebtAtBlock[account] = block.number;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function lastBlockRewardApplicable(address account) public view returns (uint256) {
        return block.number.sub(userFatRewardDebtAtBlock[account]);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable()
            .sub(lastUpdateTime)
            .mul(rewardRate)
            .mul(1e18)
            .div(totalSupply())
        );
    }

    function earned(address account) public view returns (uint256) {
        return
        balanceOf(account)
        .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
        .div(1e18)
        .add(rewards[account]);
    }

    function earned2(address account) public view returns (uint256) {
        return
        balanceOf(account)
        .mul(
            lastBlockRewardApplicable(account).mul(
                reward_per_block.mul(1e18).div(totalSupply())
            )
        )
        .div(1e18)
        .add(fatRewards[account]);
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount)
    public
    override
    updateReward(msg.sender)
    checkhalve
    checkStart
    {
        require(amount > 0, 'Cannot stake 0');
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount)
    public
    override
    updateReward(msg.sender)
    checkhalve
    checkStart
    {
        require(amount > 0, 'Cannot withdraw 0');
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkhalve checkStart {
        uint256 reward = earned(msg.sender);
        uint256 fatReward = earned2(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            fatCash.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
        if(fatReward > 0){
            fatRewards[msg.sender] = 0;
            userFatRewardDebtAtBlock[msg.sender] = block.number;
            // The mining reward is FAT, sent to the contract caller
            fatToken.safeTransfer(msg.sender, fatReward);
            // Trigger sending reward event
            emit RewardPaid(msg.sender, fatReward);
        }
    }

    modifier checkhalve() {
        if (block.timestamp >= periodFinish) {
            initreward = initreward.mul(80).div(100);

            rewardRate = initreward.div(DURATION);
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(initreward);
        }
        _;
    }

    modifier checkStart() {
        require(block.timestamp >= starttime, 'not start');
        _;
    }

    function notifyRewardAmount(uint256 reward)
    external
    override
    onlyRewardDistribution
    updateReward(address(0))
    {
        if (block.timestamp > starttime) {
            if (block.timestamp >= periodFinish) {
                rewardRate = reward.div(DURATION);
            } else {
                uint256 remaining = periodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardRate);
                rewardRate = reward.add(leftover).div(DURATION);
            }
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(reward);
        } else {
            rewardRate = initreward.div(DURATION);
            lastUpdateTime = starttime;
            periodFinish = starttime.add(DURATION);
            emit RewardAdded(reward);
        }
    }
}
