pragma solidity ^0.6.0;

import './owner/Operator.sol';
import './lib/BEP20Burnable.sol';

contract Bond is BEP20Burnable, Operator {
    /**
     * @notice Constructs the Fat Bond BEP-20 contract.
     */
    constructor() public BEP20('FAB', 'FAB', 18) {}

    /**
     * @notice Operator mints Fat bonds to a recipient
     * @param recipient_ The address of recipient
     * @param amount_ The amount of Fat bonds to mint to
     * @return whether the process has been done
     */
    function mint(address recipient_, uint256 amount_)
        public
        onlyOperator
        returns (bool)
    {
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
