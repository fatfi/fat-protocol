/**
  * Fat Cash Boardroom contract
  * Realization function:
  * 1. FAS is mortgaged to Boardroom, and FAS is redeemed from Boardroom
  * 2. At each Epoch, Operator calculates the number of additional FAC issuances (the calculation formula is in the Treasury contract), and distributes the FAC rewards to the directors who pledged FAS to Boardroom
  */

pragma solidity ^0.6.0;
//pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';

import './lib/Safe112.sol';
import './owner/Operator.sol';
import './utils/ContractGuard.sol';
import './interfaces/IFatAsset.sol';

contract ShareWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public share;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     *@notice Mortgage FAS to Boardroom
     */
    function stake(uint256 amount) public virtual {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        share.safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     *@notice Redeem FAS from Boardroom
     */
    function withdraw(uint256 amount) public virtual {
        uint256 directorShare = _balances[msg.sender];
        require(
            directorShare >= amount,
            'Boardroom: withdraw request greater than staked amount'
        );
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = directorShare.sub(amount);
        share.safeTransfer(msg.sender, amount);
    }
}

contract Boardroom is ShareWrapper, ContractGuard, Operator {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    using Safe112 for uint112;

    /* ========== DATA STRUCTURES ========== */

    //Structure: Board seats
    struct Boardseat {
        uint256 lastSnapshotIndex;
        uint256 rewardEarned;
    }

    //Structure: Board snapshot
    struct BoardSnapshot {
        uint256 time;
        uint256 rewardReceived;
        uint256 rewardPerShare;
    }

    /* ========== STATE VARIABLES ========== */

    IERC20 private cash;

    //Mapping: Each address corresponds to each board seat, that is, one address corresponds to one director (structure)
    mapping(address => Boardseat) private directors;
    BoardSnapshot[] private boardHistory;

    /* ========== CONSTRUCTOR ========== */

    /**
     *@notice Constructor
     */
    constructor(IERC20 _cash, IERC20 _share) public {
        cash = _cash;
        share = _share;

        BoardSnapshot memory genesisSnapshot = BoardSnapshot({
            time: block.number,
            rewardReceived: 0,
            rewardPerShare: 0
        });
        //Genesis snapshot of the board
        boardHistory.push(genesisSnapshot);
    }

    /* ========== Modifiers =============== */
    //Modifier：The caller needs to mortgage the FAS in the Boardroom to be greater than 0
    modifier directorExists {
        require(
            balanceOf(msg.sender) > 0,
            'Boardroom: The director does not exist'
        );
        _;
    }

    //Modifier: Update the rewards of each director (FAC)
    modifier updateReward(address director) {
        if (director != address(0)) {
            Boardseat memory seat = directors[director];
            seat.rewardEarned = earned(director);
            seat.lastSnapshotIndex = latestSnapshotIndex();
            directors[director] = seat;
        }
        _;
    }

    /* ========== VIEW FUNCTIONS ========== */

    // =========== Snapshot getters
    // Some read-only methods: get snapshot information

    function latestSnapshotIndex() public view returns (uint256) {
        return boardHistory.length.sub(1);
    }

    function getLatestSnapshot() internal view returns (BoardSnapshot memory) {
        return boardHistory[latestSnapshotIndex()];
    }

    function getLastSnapshotIndexOf(address director)
        public
        view
        returns (uint256)
    {
        return directors[director].lastSnapshotIndex;
    }

    function getLastSnapshotOf(address director)
        internal
        view
        returns (BoardSnapshot memory)
    {
        return boardHistory[getLastSnapshotIndexOf(director)];
    }

    // =========== Director getters

    /**
     *@notice Get the rewardable FAC of each FAS in the latest snapshot
     */
    function rewardPerShare() public view returns (uint256) {
        return getLatestSnapshot().rewardPerShare;
    }

    /**
     *@notice Calculate the total award (FAC) that can be withdrawn by the director
     */
    function earned(address director) public view returns (uint256) {
        uint256 latestRPS = getLatestSnapshot().rewardPerShare;
        uint256 storedRPS = getLastSnapshotOf(director).rewardPerShare;

        return
            balanceOf(director).mul(latestRPS.sub(storedRPS)).div(1e18).add(
                directors[director].rewardEarned
            );
    // The total rewards that can be withdrawn by the director = the number of FAS pledged by the director * (the number of FACs that can be obtained per FAS in the latest snapshot-the number of FACs that can be obtained per FAS in the last snapshot) + the awards not withdrawn by the director
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /**
     *@notice Mortgage FAS to Boardroom
     */
    function stake(uint256 amount)
        public
        override
        onlyOneBlock
        updateReward(msg.sender)
    {
        require(amount > 0, 'Boardroom: Cannot stake 0');
        super.stake(amount);
        // Trigger mortgage event
        emit Staked(msg.sender, amount);
    }

    /**
     *@notice Redeem FAS from Boardroom
     */
    function withdraw(uint256 amount)
        public
        override
        onlyOneBlock
        directorExists
        updateReward(msg.sender)
    {
        require(amount > 0, 'Boardroom: Cannot withdraw 0');
        super.withdraw(amount);
        // Trigger redemption event
        emit Withdrawn(msg.sender, amount);
    }

    /**
     *@notice Redeem FAS from Boardroom and withdraw rewards
     */
    function exit() external {
        withdraw(balanceOf(msg.sender));
        claimReward();
    }

    /**
     *@notice Receive rewards from Boardroom, rewards are FAC
     */
    function claimReward() public updateReward(msg.sender) {
        //After updating the director’s reward, get the reward quantity
        uint256 reward = directors[msg.sender].rewardEarned;
        if (reward > 0) {
            directors[msg.sender].rewardEarned = 0;
            //Reset the number of rewards to 0
            cash.safeTransfer(msg.sender, reward);
            //Send rewards to directors
            emit RewardPaid(msg.sender, reward);
            //Trigger completion reward event
        }
    }

    /**
     *@notice Allocation of coins, that is, how many FACs can be obtained for each FAS, only Operator has the authority to control
     *@notice How many additional FACs are issued per Epoch is only determined by the Operator, and the specific calculation formula is in the Treasury contract
     */
    function allocateSeigniorage(uint256 amount)
        external
        onlyOneBlock
        onlyOperator
    {
        require(amount > 0, 'Boardroom: Cannot allocate 0');
        require(
            totalSupply() > 0,
            'Boardroom: Cannot allocate when totalSupply is 0'
        );

        // Create & add new snapshot
        uint256 prevRPS = getLatestSnapshot().rewardPerShare;
        //prevRPS: In the last snapshot, the number of FACs that can be awarded for each FAS
        uint256 nextRPS = prevRPS.add(amount.mul(1e18).div(totalSupply()));
        //nextRPS：In the next snapshot, the number of FACs that can be awarded for each FAS = the number of FACs that can be awarded for each BAS in the previous snapshot + (the total number of FACs issued to the board this time / the total supply of FAS)
        //@notice Each snapshot recorded is the total amount (cumulative amount), and increment (subtraction) is used when calculating the number of new rewards per Epoch

        BoardSnapshot memory newSnapshot = BoardSnapshot({
            time: block.number,
            rewardReceived: amount,
            rewardPerShare: nextRPS
        });
        //Update snapshot
        boardHistory.push(newSnapshot);

        //Send the amount of additional FAC to this contract, and the amount of additional issuance is determined by the Operator
        cash.safeTransferFrom(msg.sender, address(this), amount);
        //Trigger the issue of FAC to the board of directors
        emit RewardAdded(msg.sender, amount);
    }

    /* ========== EVENTS ========== */

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardAdded(address indexed user, uint256 reward);
}
