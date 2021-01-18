pragma solidity ^0.6.0;

import './owner/Operator.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol';
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Token is ERC20Burnable, Ownable, Operator {

    using SafeMath for uint256;

    uint256 private _cap = 200000000e18; // 200.000.000
    uint256 private _totalLock;

    mapping(address => uint256) private _locks;
    mapping(address => uint256) private _lastUnlockBlock;

    event Lock(address indexed to, uint256 value);
    /**
     * @notice Constructs the Fat ERC-20 contract.
     */
    constructor(address crowdsale_,address team_,address advisor_,address prisale_) public ERC20('FAT', 'FAT') {

        // 15% of Total Token Cap
        uint256 teamSupply = cap().mul(15).div(100);
        _mint(team_,teamSupply);
        lock(team_,teamSupply,10142779);

        // 5% of Total Token Cap
        uint256 advisorSupply = cap().mul(5).div(100);
        _mint(advisor_,advisorSupply);
        lock(advisor_,advisorSupply,10142779);

        // 25% of Total Token Cap
        uint256 prisaleSupply = cap().mul(25).div(100);
        _mint(prisale_,prisaleSupply);
        lock(prisale_,prisaleSupply,10142779);

        //2,5% of Total Token Cap
        uint256 crowdsaleSupply = cap().mul(25).div(1000);
        _mint(crowdsale_,crowdsaleSupply);

    }


    function cap() public view returns (uint256) {
        return _cap;
    }

    function totalLock() public view returns (uint256) {
        return _totalLock;
    }

    function totalBalanceOf(address _holder) public view returns (uint256) {
        return _locks[_holder].add(balanceOf(_holder));
    }

    function lockOf(address _holder) public view returns (uint256) {
        return _locks[_holder];
    }

    function lastUnlockBlock(address _holder) public view returns (uint256) {
        return _lastUnlockBlock[_holder];
    }

    function lock(address _holder, uint256 _amount ,uint256 lockToBlock) public onlyOwner {
        require(_holder != address(0), "ERC20: lock to the zero address");
        require(_amount <= balanceOf(_holder), "ERC20: lock amount over blance");
        _transfer(_holder, address(this), _amount);
        _locks[_holder] = _locks[_holder].add(_amount);
        _totalLock = _totalLock.add(_amount);
        if (_lastUnlockBlock[_holder] < lockToBlock) {
            _lastUnlockBlock[_holder] = lockToBlock;
        }
        emit Lock(_holder, _amount);
    }

    function canUnlockAmount(address _holder) public view returns (uint256) {
        if (block.number < _lastUnlockBlock[_holder] ) {
            return 0;
        }
        return _locks[_holder];
    }

    function unlock() public {
        require(_locks[msg.sender] > 0, "ERC20: cannot unlock");

        uint256 amount = canUnlockAmount(msg.sender);
        // just for sure
        if (amount > balanceOf(address(this))) {
            amount = balanceOf(address(this));
        }
        _transfer(address(this), msg.sender, amount);
        _locks[msg.sender] = _locks[msg.sender].sub(amount);
        _lastUnlockBlock[msg.sender] = block.number;
        _totalLock = _totalLock.sub(amount);
    }

    /**
     * @notice Operator mints Fat to a recipient
     * @param recipient_ The address of recipient
     * @param amount_ The amount of Fat to mint to
     * @return whether the process has been done
     */

    function mint(address recipient_, uint256 amount_)
        public
        onlyOperator
        returns (bool)
    {
        require(totalSupply().add(amount_) <= _cap, "ERC20Capped: cap exceeded");
        uint256 balanceBefore = balanceOf(recipient_);
        _mint(recipient_, amount_);
        uint256 balanceAfter = balanceOf(recipient_);
        return balanceAfter > balanceBefore;
    }

    function burn(uint256 amount) public override onlyOperator {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount)
        public
        override
        onlyOperator
    {
        super.burnFrom(account, amount);
    }
}
