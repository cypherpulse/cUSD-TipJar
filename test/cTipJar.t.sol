// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {cTipJar} from "../src/cTipJar.sol";
import {ERC20Mock} from "openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {IERC20Errors} from "openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol";

// errors
error cTipJar__ZeroAmount();
error cTipJar__NotOwner();
error cTipJar__TransferFailed();
error cTipJar__InvalidAddress();
error cTipJar__InsufficientBalance();
error cTipJar__NoFundsToWithdraw();

contract cTipJarTest is Test {
    cTipJar tipJar;
    ERC20Mock mockCusd;
    address owner = address(1);
    address tipper = address(2);
    address notOwner = address(3);

    function setUp() public {
        mockCusd = new ERC20Mock();
        tipJar = new cTipJar(address(mockCusd), owner);
    }

    function testTipNonZeroAmount() public {
        uint256 amount = 100;
        mockCusd.mint(tipper, amount);
        vm.prank(tipper);
        mockCusd.approve(address(tipJar), amount);

        vm.prank(tipper);
        tipJar.tip(amount);

        assertEq(tipJar.totalReceived(), amount);
        assertEq(tipJar.tipsFrom(tipper), amount);
        assertEq(mockCusd.balanceOf(address(tipJar)), amount);
    }

    function testTipZeroAmountReverts() public {
        vm.prank(tipper);
        vm.expectRevert(cTipJar__ZeroAmount.selector);
        tipJar.tip(0);
    }

    function testWithdrawByOwner() public {
        uint256 amount = 100;
        mockCusd.mint(tipper, amount);
        vm.prank(tipper);
        mockCusd.approve(address(tipJar), amount);
        vm.prank(tipper);
        tipJar.tip(amount);

        vm.prank(owner);
        tipJar.withdraw(amount);

        assertEq(mockCusd.balanceOf(owner), amount);
        assertEq(mockCusd.balanceOf(address(tipJar)), 0);
    }

    function testWithdrawAllByOwner() public {
        uint256 amount = 100;
        mockCusd.mint(tipper, amount);
        vm.prank(tipper);
        mockCusd.approve(address(tipJar), amount);
        vm.prank(tipper);
        tipJar.tip(amount);

        vm.prank(owner);
        tipJar.withdrawAll();

        assertEq(mockCusd.balanceOf(owner), amount);
        assertEq(mockCusd.balanceOf(address(tipJar)), 0);
    }

    function testWithdrawNotOwnerReverts() public {
        vm.prank(notOwner);
        vm.expectRevert(cTipJar__NotOwner.selector);
        tipJar.withdraw(1);
    }

    function testWithdrawInsufficientBalanceReverts() public {
        vm.prank(owner);
        vm.expectRevert(cTipJar__InsufficientBalance.selector);
        tipJar.withdraw(1);
    }

    function testWithdrawAllZeroBalanceReverts() public {
        vm.prank(owner);
        vm.expectRevert(cTipJar__NoFundsToWithdraw.selector);
        tipJar.withdrawAll();
    }

    function testTipWithoutAllowanceReverts() public {
        uint256 amount = 100;
        mockCusd.mint(tipper, amount);
        // No approve

        vm.prank(tipper);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, address(tipJar), 0, amount));
        tipJar.tip(amount);
    }
}