// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title TRIToken
 * @dev This contract defines the TRI token, an ERC20 token used in the marketplace.
 */
contract TRIToken is ERC20 {
    event Minted(address indexed sender, uint256 amount);

    /**
     * @dev Constructor function to initialize the TRIToken.
     * @param initialSupply The initial supply of TRI tokens to be minted.
     */
    constructor(uint256 initialSupply) ERC20("TRIKONE", "TRI") {
        // Mint initial supply of tokens to the contract deployer
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Mint new TRI tokens and emit the Minted event.
     * @param amount The amount of TRI tokens to mint.
     */
    function mint(uint256 amount) public {
        // Mint new tokens and assign them to the sender's balance
        _mint(msg.sender, amount);
        // Emit the Minted event to indicate the minting
        emit Minted(msg.sender, amount);
    }
}
