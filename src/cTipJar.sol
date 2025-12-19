
// SPDX-License-Identifier: MIT
// Layout of the contract file:
// version
// imports
// errors
// interfaces, libraries, contract

// Inside Contract:
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.20;

// imports
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// errors
error cTipJar__ZeroAmount();
error cTipJar__NotOwner();
error cTipJar__TransferFailed();
error cTipJar__InvalidAddress();
error cTipJar__InsufficientBalance();
error cTipJar__NoFundsToWithdraw();

// interfaces, libraries, contract

/**
 * @title cTipJar - Stablecoin Tip Jar on Celo
 * @author cypherpulse.base.eth
 * @notice A simple tip jar contract for Celo network using cUSD (ERC-20) as the tipping token.
 *         Each deployed instance belongs to one recipient address, holds cUSD tips, and lets that recipient withdraw funds.
 * @dev This contract is minimal, secure, and ideal for learning ERC-20 transfers, contract state, and wallet interaction.
 *      On Celo Sepolia/Mainnet, inject the proper cUSD address at deployment.
 *      Deployment and RPC config is handled via Foundry (foundry.toml + forge script with Celo RPC).
 */
contract cTipJar {
    // Type declarations
    // (none)

    // State variables
    IERC20 public immutable I_CUSD; // cUSD ERC-20
    address public immutable I_OWNER; // tip jar recipient
    uint256 private sTotalReceived; // total cUSD ever received
    mapping(address => uint256) private sTipsFrom; // per tipper total

    // Events
    event Tipped(address indexed from, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    // Modifiers
    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    // Functions

    // constructor
    /**
     * @notice Constructor to initialize the tip jar.
     * @param cusd The address of the cUSD ERC-20 token on Celo.
     * @param owner The address of the recipient who can withdraw tips.
     */
    constructor(address cusd, address owner) {
        if (cusd == address(0)) revert cTipJar__InvalidAddress();
        if (owner == address(0)) revert cTipJar__InvalidAddress();
        I_CUSD = IERC20(cusd);
        I_OWNER = owner;
    }

    // receive function (if exists)
    // (none)

    // fallback function (if exists)
    // (none)

    // external
    /**
     * @notice Allows anyone to tip cUSD to the jar.
     * @dev The tipper must first approve this contract to spend the amount.
     * @param amount The amount of cUSD to tip (in wei).
     */
    function tip(uint256 amount) external {
        if (amount == 0) revert cTipJar__ZeroAmount();
        // Effects: update state
        sTotalReceived += amount;
        sTipsFrom[msg.sender] += amount;
        // Interactions: transfer
        bool success = I_CUSD.transferFrom(msg.sender, address(this), amount);
        if (!success) revert cTipJar__TransferFailed();
        // Emit event
        emit Tipped(msg.sender, amount);
    }

    /**
     * @notice Allows the owner to withdraw a specific amount of cUSD.
     * @param amount The amount of cUSD to withdraw (in wei).
     */
    function withdraw(uint256 amount) external onlyOwner {
        if (amount == 0) revert cTipJar__ZeroAmount();
        uint256 balance = I_CUSD.balanceOf(address(this));
        if (amount > balance) revert cTipJar__InsufficientBalance();
        bool success = I_CUSD.transfer(I_OWNER, amount);
        if (!success) revert cTipJar__TransferFailed();
        emit Withdrawn(I_OWNER, amount);
    }

    /**
     * @notice Allows the owner to withdraw all cUSD in the jar.
     */
    function withdrawAll() external onlyOwner {
        uint256 balance = I_CUSD.balanceOf(address(this));
        if (balance == 0) revert cTipJar__NoFundsToWithdraw();
        bool success = I_CUSD.transfer(I_OWNER, balance);
        if (!success) revert cTipJar__TransferFailed();
        emit Withdrawn(I_OWNER, balance);
    }

    // public
    // (none additional)

    // internal
    function _onlyOwner() internal view {
        if (msg.sender != I_OWNER) revert cTipJar__NotOwner();
    }

    // private
    // (none)

    // view & pure functions
    /**
     * @notice Returns the total cUSD received by the jar.
     * @return The total amount received.
     */
    function totalReceived() external view returns (uint256) {
        return sTotalReceived;
    }

    /**
     * @notice Returns the total cUSD tipped by a specific address.
     * @param tipper The address of the tipper.
     * @return The total amount tipped by the tipper.
     */
    function tipsFrom(address tipper) external view returns (uint256) {
        return sTipsFrom[tipper];
    }
}