// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// USDT Token Contract
contract USDTToken is ERC20{
    constructor() ERC20("Tether USD", "USDT") {
        // Mint initial supply to the contract owner
        _mint(msg.sender, 1000 * 10**decimals()); // Mint 1 thousand USDT tokens
    }

    // Function to mint additional tokens (if required)
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
