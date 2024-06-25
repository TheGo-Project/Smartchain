// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ManualMinter is ERC20, Ownable {
    address private _admin;

    // Constructor sets the default admin and token details
    constructor(address initialAdmin) ERC20("ManualToken", "MTK") {
        require(initialAdmin != address(0), "Admin address cannot be zero.");
        _admin = initialAdmin;
    }

    // Function to mint new tokens, restricted to the admin
    function mint(address to, uint256 amount) public {
        require(msg.sender == _admin, "Only the admin can mint tokens.");
        _mint(to, amount);
    }

    // Get the current admin address
    function admin() public view returns (address) {
        return _admin;
    }

    // Set or change the admin address, only callable by the contract owner
    function setAdmin(address newAdmin) public onlyOwner {
        require(newAdmin != address(0), "Admin address cannot be Null.");
        _admin = newAdmin;
    }
}
