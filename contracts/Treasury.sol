/**
  * Fat Cash Treasury contract
  * Realization function:
  * 1. Obtain the FAC price through the oracle. According to the different FAC price, use FAC to buy FAB, or redeem FAB to obtain FAC
  * 2. According to different FAC prices, issue additional FACs and allocate the newly issued FACs to the fund treasury boardroom
  * Note: TimBear 20210107
*/

pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/Math.sol';
import './lib/IBEP20.sol';
import './lib/SafeBEP20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

import './lib/Babylonian.sol';
import './lib/FixedPoint.sol';
import './lib/Safe112.sol';
import './owner/Operator.sol';
import './utils/ContractGuard.sol';
import './interfaces/IFatAsset.sol';
import './interfaces/IOracle.sol';
import './interfaces/IBoardroom.sol';

/**
 * @title Fat Cash Treasury contract
 * @notice Monetary policy logic to adjust supplies of fat cash assets
 */
contract Treasury is ContractGuard, Operator {
    using FixedPoint for *;
    using SafeBEP20 for IBEP20;
    using Address for address;
    using SafeMath for uint256;
    using Safe112 for uint112;

    /* ========= CONSTANT VARIABLES ======== */

    uint256 public constant PERIOD = 1 days;

    /* ========== STATE VARIABLES ========== */

    // flags
    bool private migrated = false;
    bool private initialized = false;

    // epoch
    uint256 public startTime;
    uint256 public epoch = 0;

    // core components
    address private cash;
    address private bond;
    address private share;
    address private boardroom;
    address private cashOracle;

    // price
    uint256 public cashPriceOne;
    uint256 public cashPriceCeiling;
    uint256 private bondDepletionFloor;
    uint256 private seigniorageSaved = 0;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _cash,
        address _bond,
        address _share,
        address _cashOracle,
        address _boardroom,
        uint256 _startTime
    ) public {
        cash = _cash;
        bond = _bond;
        share = _share;
        cashOracle = _cashOracle;
        boardroom = _boardroom;

        startTime = _startTime;

        cashPriceOne = 10**18;
        cashPriceCeiling = uint256(105).mul(cashPriceOne).div(10**2);

        bondDepletionFloor = uint256(1000).mul(cashPriceOne);
    }

    /* =================== Modifier =================== */

    modifier checkCondition {
        require(!migrated, 'Treasury: migrated');
        require(now >= startTime, 'Treasury: not started yet');

        _;
    }

    modifier checkEpoch {
        require(now >= nextEpochPoint(), 'Treasury: not opened yet');

        _;

        epoch = epoch.add(1);
    }

    modifier checkOperator {
        require(
            IFatAsset(cash).operator() == address(this) &&
            IFatAsset(bond).operator() == address(this) &&
            IFatAsset(share).operator() == address(this) &&
            Operator(boardroom).operator() == address(this),
            'Treasury: need more permission'
        );

        _;
    }

    modifier notInitialized {
        require(!initialized, 'Treasury: already initialized');

        _;
    }

    /* ========== VIEW FUNCTIONS ========== */

    // flags
    function isMigrated() public view returns (bool) {
        return migrated;
    }

    function isInitialized() public view returns (bool) {
        return initialized;
    }

    // epoch
    function nextEpochPoint() public view returns (uint256) {
        return startTime.add(epoch.mul(PERIOD));
    }

    // oracle
    function getCashPrice() public view returns (uint256 cashPrice) {
        try IOracle(cashOracle).consult(cash, 1e18) returns (uint256 price) {
            return price;
        } catch {
            revert('Treasury: failed to consult cash price from the oracle');
        }
    }

    // budget
    function getReserve() public view returns (uint256) {
        return seigniorageSaved;
    }

    /* ========== GOVERNANCE ========== */

    function initialize() public notInitialized checkOperator {
        // burn all of it's balance
        IFatAsset(cash).burn(IBEP20(cash).balanceOf(address(this)));

        // mint only 1001 cash to itself
        IFatAsset(cash).mint(address(this), 1001 ether);

        // set seigniorageSaved to it's balance
        seigniorageSaved = IBEP20(cash).balanceOf(address(this));

        initialized = true;
        emit Initialized(msg.sender, block.number);
    }

    function migrate(address target) public onlyOperator checkOperator {
        require(!migrated, 'Treasury: migrated');

        // cash
        Operator(cash).transferOperator(target);
        Operator(cash).transferOwnership(target);
        IBEP20(cash).transfer(target, IBEP20(cash).balanceOf(address(this)));

        // bond
        Operator(bond).transferOperator(target);
        Operator(bond).transferOwnership(target);
        IBEP20(bond).transfer(target, IBEP20(bond).balanceOf(address(this)));

        // share
        Operator(share).transferOperator(target);
        Operator(share).transferOwnership(target);
        IBEP20(share).transfer(target, IBEP20(share).balanceOf(address(this)));

        migrated = true;
        emit Migration(target);
    }

    /* ========== MUTABLE FUNCTIONS ========== */

    function _updateCashPrice() internal {
        try IOracle(cashOracle).update()  {} catch {}
    }

    function buyBonds(uint256 amount, uint256 targetPrice)
    external
    onlyOneBlock
    checkCondition
    checkOperator
    {
        require(amount > 0, 'Treasury: cannot purchase bonds with zero amount');

        uint256 cashPrice = getCashPrice();
        require(cashPrice == targetPrice, 'Treasury: cash price moved');
        require(
            cashPrice < cashPriceOne, // price < $1
            'Treasury: cashPrice not eligible for bond purchase'
        );

        uint256 bondPrice = cashPrice;

        IFatAsset(cash).burnFrom(msg.sender, amount);
        IFatAsset(bond).mint(msg.sender, amount.mul(1e18).div(bondPrice));
        _updateCashPrice();

        emit BoughtBonds(msg.sender, amount);
    }

    function redeemBonds(uint256 amount, uint256 targetPrice)
    external
    onlyOneBlock
    checkCondition
    checkOperator
    {
        require(amount > 0, 'Treasury: cannot redeem bonds with zero amount');

        uint256 cashPrice = getCashPrice();
        require(cashPrice == targetPrice, 'Treasury: cash price moved');
        require(
            cashPrice > cashPriceCeiling, // price > $1.05
            'Treasury: cashPrice not eligible for bond purchase'
        );
        require(
            IBEP20(cash).balanceOf(address(this)) >= amount,
            'Treasury: treasury has no more budget'
        );

        seigniorageSaved = seigniorageSaved.sub(
            Math.min(seigniorageSaved, amount)
        );

        IFatAsset(bond).burnFrom(msg.sender, amount);
        IBEP20(cash).safeTransfer(msg.sender, amount);
        _updateCashPrice();

        emit RedeemedBonds(msg.sender, amount);
    }

    function allocateSeigniorage()
    external
    onlyOneBlock
    checkCondition
    checkEpoch
    checkOperator
    {
        _updateCashPrice();
        uint256 cashPrice = getCashPrice();
        require(
            cashPrice > cashPriceCeiling,
            'Treasury: there is no seigniorage to be allocated'
        );

        uint256 cashSupply = IBEP20(cash).totalSupply().sub(seigniorageSaved);
        uint256 percentage = cashPrice.sub(cashPriceOne);
        uint256 seigniorage = cashSupply.mul(percentage).div(1e18);

        if (seigniorageSaved > bondDepletionFloor) {
            IFatAsset(cash).mint(address(this), seigniorage);
            IBEP20(cash).safeApprove(boardroom, seigniorage);
            IBoardroom(boardroom).allocateSeigniorage(seigniorage);
            emit BoardroomFunded(now, seigniorage);
        } else {
            seigniorageSaved = seigniorageSaved.add(seigniorage);
            IFatAsset(cash).mint(address(this), seigniorage);
            emit TreasuryFunded(now, seigniorage);
        }
    }

    event Initialized(address indexed executor, uint256 at);
    event Migration(address indexed target);
    event RedeemedBonds(address indexed from, uint256 amount);
    event BoughtBonds(address indexed from, uint256 amount);
    event TreasuryFunded(uint256 timestamp, uint256 seigniorage);
    event BoardroomFunded(uint256 timestamp, uint256 seigniorage);
}
