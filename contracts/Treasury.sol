/**
  * Fat Cash Treasury contract
  * Realization function:
  * 1. Obtain the BAC price through the oracle. According to the different FAC price, use FAC to buy FAB, or redeem FAB to obtain FAC
  * 2. According to different FAC prices, issue additional FACs and allocate the newly issued FACs to the fund treasury boardroom
  * Note: TimBear 20210107
*/

pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/Math.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

import './interfaces/IOracle.sol';
import './interfaces/IBoardroom.sol';
import './interfaces/IFatAsset.sol';
import './interfaces/ISimpleERCFund.sol';
import './lib/Babylonian.sol';
import './lib/FixedPoint.sol';
import './lib/Safe112.sol';
import './owner/Operator.sol';
import './utils/Epoch.sol';
import './utils/ContractGuard.sol';

/**
 * @title Basis Cash Treasury contract
 * @notice Monetary policy logic to adjust supplies of basis cash assets
 * @author Summer Smith & Rick Sanchez
 */
contract Treasury is ContractGuard, Epoch {
    using FixedPoint for *;
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    using Safe112 for uint112;

    /* ========== STATE VARIABLES ========== */

    // ========== FLAGS
    bool public migrated = false;
    bool public initialized = false;

    // ========== CORE
    address public token;
    address public fund;
    address public cash;
    address public bond;
    address public share;
    address public boardroom;

    address public bondOracle;
    address public seigniorageOracle;

    // ========== PARAMS
    uint256 public cashPriceOne;
    uint256 public cashPriceCeiling;
    uint256 public bondDepletionFloor;
    uint256 private accumulatedSeigniorage = 0;
    uint256 public fundAllocationRate = 2; // %

    /* ========== CONSTRUCTOR ========== */
    /**
    *@notice constructor
     */
    constructor(
        address _token,
        address _cash,
        address _bond,
        address _share,
        address _bondOracle,
        address _seigniorageOracle,
        address _boardroom,
        address _fund,
        uint256 _startTime
    ) public Epoch(1 days, _startTime, 0) {
        token = _token;
        cash = _cash;
        bond = _bond;
        share = _share;
        bondOracle = _bondOracle;
        seigniorageOracle = _seigniorageOracle;

        boardroom = _boardroom;
        fund = _fund;

        //The base price is 1
        cashPriceOne = 10**18;
        //cashPriceCeiling is 1.05
        cashPriceCeiling = uint256(105).mul(cashPriceOne).div(10**2);
        bondDepletionFloor = uint256(1000).mul(cashPriceOne);
    }

    /* =================== Modifier =================== */

    //Modifier: Need to complete Migration, that is complete the replacement of Operator to this contract
    modifier checkMigration {
        require(!migrated, 'Treasury: migrated');

        _;
    }

    //Modifier: Operator of the contract token , cash , bond , share boardroom must be this contract
    modifier checkOperator {
        require(
            IFatAsset(token).operator() == address(this) &&
            IFatAsset(cash).operator() == address(this) &&
            IFatAsset(bond).operator() == address(this) &&
            IFatAsset(share).operator() == address(this) &&
                Operator(boardroom).operator() == address(this),
            'Treasury: need more permission'
        );

        _;
    }

    /* ========== VIEW FUNCTIONS ========== */
    //Some read-only methods

    // budget
    function getReserve() public view returns (uint256) {
        return accumulatedSeigniorage;
    }

    // oracle
    function getBondOraclePrice() public view returns (uint256) {
        return _getCashPrice(bondOracle);
    }

    function getSeigniorageOraclePrice() public view returns (uint256) {
        return _getCashPrice(seigniorageOracle);
    }

    /**
     *notice:Choose different oracles to feed prices according to different scenarios
     */
    function _getCashPrice(address oracle) internal view returns (uint256) {
        try IOracle(oracle).consult(cash, 1e18) returns (uint256 price) {
            return price;
        } catch {
            revert('Treasury: failed to consult cash price from the oracle');
        }
    }

    /* ========== GOVERNANCE ========== */
    /**
     *@notice Contract initialization
     */
    function initialize() public checkOperator {
        require(!initialized, 'Treasury: initialized');

        // burn all of it's balance
        // Destroy all FAC in this contract
        IFatAsset(cash).burn(IERC20(cash).balanceOf(address(this)));

        // set accumulatedSeigniorage to it's balance
        // Set the cumulative reserve amount to the initial balance of the FAC quantity of this contract, which is 0
        accumulatedSeigniorage = IERC20(cash).balanceOf(address(this));

        initialized = true;
        //Trigger contract initialization event
        emit Initialized(msg.sender, block.number);
    }

    /**
      *@notice Change Operator to target (this contract), only the current Operator has the right to change
      */
    function migrate(address target) public onlyOperator checkOperator {
        require(!migrated, 'Treasury: migrated');

        // cash
        // Replace the Operator of the FAC contract, the Owner is the target, and send the FAC of the original contract to the target
        Operator(cash).transferOperator(target);
        Operator(cash).transferOwnership(target);
        IERC20(cash).transfer(target, IERC20(cash).balanceOf(address(this)));

        // bond
        // Replace the Operator of the FAB contract, the Owner is the target, and send the FAB of the original contract to the target
        Operator(bond).transferOperator(target);
        Operator(bond).transferOwnership(target);
        IERC20(bond).transfer(target, IERC20(bond).balanceOf(address(this)));

        // share
        // Replace the Operator of the FAS contract with Owner as the target, and send the FAS of the original contract to the target
        Operator(share).transferOperator(target);
        Operator(share).transferOwnership(target);
        IERC20(share).transfer(target, IERC20(share).balanceOf(address(this)));

        migrated = true;
        // Trigger ownership transfer event
        emit Migration(target);
    }

    function setFund(address newFund) public onlyOperator {
        // Set up developer contributor bonus pool
        fund = newFund;
        // Trigger replacement of developer contributor bonus pool event
        emit ContributionPoolChanged(msg.sender, newFund);
    }

    function setFundAllocationRate(uint256 rate) public onlyOperator {
        // Set the bonus ratio of developer contributors
        fundAllocationRate = rate;
        // Trigger the replacement of developer contributor bonus ratio event
        emit ContributionPoolRateChanged(msg.sender, rate);
    }

    /* ========== MUTABLE FUNCTIONS ========== */

    /**
      *@notice Get FAC price through oracle
      */
    function _updateCashPrice() internal {
        try IOracle(bondOracle).update()  {} catch {}
        try IOracle(seigniorageOracle).update()  {} catch {}
    }

    /**
      *@notice When the FAC price is lower than 1, use FAC to buy FAB
      */
    function buyBonds(uint256 amount, uint256 targetPrice)
        external
        onlyOneBlock
        checkMigration
        checkStartTime
        checkOperator
    {
        require(amount > 0, 'Treasury: cannot purchase bonds with zero amount');

        //Get FAC price through oracle
        uint256 cashPrice = _getCashPrice(bondOracle);
        //FAC price must be equal to target price
        require(cashPrice == targetPrice, 'Treasury: cash price moved');
        // Need FAC price less than 1
        require(
            cashPrice < cashPriceOne, // price < $1
            'Treasury: cashPrice not eligible for bond purchase'
        );

        uint256 bondPrice = cashPrice;
        //Destroy FAC
        IFatAsset(cash).burnFrom(msg.sender, amount);
        //Casting FAB: Burning 1 FAC can exchange (1/bondPrice) FAB
        IFatAsset(bond).mint(msg.sender, amount.mul(1e18).div(bondPrice));
        //Update FAC price
        _updateCashPrice();
        //Trigger purchase FAB event
        emit BoughtBonds(msg.sender, amount);
    }

    /**
      *@notice When the FAC price is greater than 1.05, use FAB to exchange for FAC
      */
    function redeemBonds(uint256 amount, uint256 targetPrice)
        external
        onlyOneBlock
        checkMigration
        checkStartTime
        checkOperator
    {
        require(amount > 0, 'Treasury: cannot redeem bonds with zero amount');

        // Get the FAC price through the oracle
        uint256 cashPrice = _getCashPrice(bondOracle);
        // FAC price must be equal to target price
        require(cashPrice == targetPrice, 'Treasury: cash price moved');
        // Need FAC price to be greater than cashPriceCeiling, which is 1.05
        require(
            cashPrice > cashPriceCeiling, // price > $1.05
            'Treasury: cashPrice not eligible for bond purchase'
        );
        // The number of FACs in this contract needs to be greater than the number of FABs to be redeemed
        require(
            IERC20(cash).balanceOf(address(this)) >= amount,
            'Treasury: treasury has no more budget'
        );
        // Cumulative reserves = Cumulative reserves-the number of FABs to be redeemed, i.e. 1FAB in exchange for 1FAC
        accumulatedSeigniorage = accumulatedSeigniorage.sub(
            Math.min(accumulatedSeigniorage, amount)
        );

        // Destroy FAB
        IFatAsset(bond).burnFrom(msg.sender, amount);
        // Send FAC
        IERC20(cash).safeTransfer(msg.sender, amount);
        // Update FAC price
        _updateCashPrice();

        //Trigger the redemption FAB event
        emit RedeemedBonds(msg.sender, amount);
    }

    /**
      *@notice Issuing additional FAC and assigning FAC
      */
    function allocateSeigniorage()
        external
        onlyOneBlock
        checkMigration
        checkStartTime
        checkEpoch
        checkOperator
    {
        // Update FAC price
        _updateCashPrice();
        uint256 cashPrice = _getCashPrice(seigniorageOracle);
        // Determine when the FAC price is less than or equal to cashPriceCeiling, which is 1.05, then return, and no additional FAC will be issued
        if (cashPrice <= cashPriceCeiling) {
            return; // just advance epoch instead revert
        }

        // circulating supply
        //Number of FAC in circulation = total supply of FAC-cumulative reserve
        uint256 cashSupply = IERC20(cash).totalSupply().sub(
            accumulatedSeigniorage
        );
        //Additional issuance ratio = FAC price-1
        uint256 percentage = cashPrice.sub(cashPriceOne);
        //The number of newly minted FACs = the number of circulating FACs * the additional issuance ratio
        uint256 seigniorage = cashSupply.mul(percentage).div(1e18);
        //Newly minted FAC and sent to this contract
        IFatAsset(cash).mint(address(this), seigniorage);

        // ======================== BIP-3
        // Fund reserve = number of newly minted FAC * fundAllocationRate / 100 = number of newly minted FAC * 2%
        uint256 fundReserve = seigniorage.mul(fundAllocationRate).div(100);
        if (fundReserve > 0) {
            IERC20(cash).safeApprove(fund, fundReserve);
            ISimpleERCFund(fund).deposit(
                cash,
                fundReserve,
                'Treasury: Seigniorage Allocation'
            );
            // Trigger the event that FAC has been issued to the development contribution pool
            emit ContributionPoolFunded(now, fundReserve);
        }
        //The number of newly minted FAC = the number of newly minted FAC-fund reserve
        seigniorage = seigniorage.sub(fundReserve);

        // ======================== BIP-4
        // New Treasury Reserve = min (the number of newly minted FAC, the total supply of FAB-the cumulative FAC reserve)
        // That is the newly minted FAC must be reserved for FAB first, and the rest can be allocated to the Boardroom
        uint256 treasuryReserve = Math.min(
            seigniorage,
            IERC20(bond).totalSupply().sub(accumulatedSeigniorage)
        );
        if (treasuryReserve > 0) {
            // Cumulative FAC Reserves = Cumulative FAC Reserves + New Treasury Reserves
            accumulatedSeigniorage = accumulatedSeigniorage.add(
                treasuryReserve
            );
            //Trigger the issued treasury reserve event
            emit TreasuryFunded(now, treasuryReserve);
        }

        // boardroom
        //New FAC Reserves of the Board of Directors = Newly Minted FAC-New Treasury Reserves
        uint256 boardroomReserve = seigniorage.sub(treasuryReserve);
        if (boardroomReserve > 0) {
            IERC20(cash).safeApprove(boardroom, boardroomReserve);
            // Call the allocateSeigniorage method of the Boardroom contract
            IBoardroom(boardroom).allocateSeigniorage(boardroomReserve);
            // Trigger the issue of funds to the board of directors event
            emit BoardroomFunded(now, boardroomReserve);
        }
    }

    // GOV
    event Initialized(address indexed executor, uint256 at);
    event Migration(address indexed target);
    event ContributionPoolChanged(address indexed operator, address newFund);
    event ContributionPoolRateChanged(
        address indexed operator,
        uint256 newRate
    );

    // CORE
    event RedeemedBonds(address indexed from, uint256 amount);
    event BoughtBonds(address indexed from, uint256 amount);
    event TreasuryFunded(uint256 timestamp, uint256 seigniorage);
    event BoardroomFunded(uint256 timestamp, uint256 seigniorage);
    event ContributionPoolFunded(uint256 timestamp, uint256 seigniorage);
}
