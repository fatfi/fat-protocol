pragma solidity ^0.6.0;

import './owner/Operator.sol';
import './lib/BEP20Burnable.sol';

contract Token is BEP20Burnable, Ownable, Operator {

    /**
     * @notice Constructs the Fat Token BEP-20 contract.
     */
    constructor() public BEP20('FAT', 'FAT', 18) {}

    /**
     * @notice Operator mints Fat bonds to a recipient
     * @param recipient_ The address of recipient
     * @param amount_ The amount of Fat bonds to mint to
     * @return whether the process has been done
     */

    function mint(address recipient_, uint256 amount_)
    public
    onlyOwner
    returns (bool)
    {
        uint256 balanceBefore = balanceOf(recipient_);
        _mint(recipient_, amount_);
        uint256 balanceAfter = balanceOf(recipient_);

        return balanceAfter > balanceBefore;
    }

    function burn(uint256 amount) public override onlyOwner {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount)
    public
    override
    onlyOwner
    {
        super.burnFrom(account, amount);
    }
}
