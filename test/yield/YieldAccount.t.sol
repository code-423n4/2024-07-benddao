// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/interfaces/IWETH.sol';

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';
import 'src/yield/YieldAccount.sol';

import 'test/setup/TestWithSetup.sol';
import '@forge-std/Test.sol';

contract TestYieldAccount is TestWithSetup {
  YieldAccount internal yieldAccount;

  function onSetUp() public virtual override {
    super.onSetUp();

    yieldAccount = new YieldAccount();
  }

  function test_RevertIf_InvalidCaller() public {
    yieldAccount.initialize(address(this), address(this));

    tsHEVM.startPrank(address(tsHacker1));

    tsHEVM.expectRevert(bytes(Errors.YIELD_MANAGER_IS_NOT_AUTH));
    yieldAccount.safeApprove(address(tsWETH), address(this), 100);

    tsHEVM.expectRevert(bytes(Errors.YIELD_MANAGER_IS_NOT_AUTH));
    yieldAccount.safeTransfer(address(tsWETH), address(this), 100);

    tsHEVM.expectRevert(bytes(Errors.YIELD_MANAGER_IS_NOT_AUTH));
    yieldAccount.safeTransferNativeToken(address(this), 100);

    tsHEVM.expectRevert(bytes(Errors.YIELD_MANAGER_IS_NOT_AUTH));
    yieldAccount.execute(address(this), new bytes(0));

    tsHEVM.expectRevert(bytes(Errors.YIELD_MANAGER_IS_NOT_AUTH));
    yieldAccount.executeWithValue{value: 100}(address(this), new bytes(0), 100);

    tsHEVM.expectRevert(bytes(Errors.YIELD_REGISTRY_IS_NOT_AUTH));
    yieldAccount.rescue(address(tsWETH), new bytes(0));

    tsHEVM.stopPrank();
  }

  function test_Should_Basic_Methods() public {
    yieldAccount.initialize(address(this), address(this));

    // approve
    yieldAccount.safeApprove(address(tsWETH), address(this), type(uint256).max);
    assertEq(tsWETH.allowance(address(yieldAccount), address(this)), type(uint256).max, 'allowance not eq');

    // transfer erc20
    uint256 erc20Amount = 100 ether;
    tsHEVM.prank(address(tsDepositor1));
    tsWETH.transferFrom(address(tsDepositor1), address(yieldAccount), erc20Amount);

    yieldAccount.safeTransfer(address(tsWETH), address(this), erc20Amount);
    assertEq(tsWETH.balanceOf(address(this)), erc20Amount, 'erc20Amount not eq');

    // transfer eth
    uint256 ethAmount = 200 ether;
    tsHEVM.prank(address(tsDepositor1));
    (bool callOk, ) = address(yieldAccount).call{value: ethAmount}(new bytes(0));
    assertEq(callOk, true, 'callOk not eq');

    uint256 ethBalanceBefore = address(this).balance;
    yieldAccount.safeTransferNativeToken(address(this), ethAmount);
    assertEq(address(this).balance, (ethBalanceBefore + ethAmount), 'ethAmount not eq');
  }

  function test_Should_Execute() public {
    yieldAccount.initialize(address(this), address(this));

    uint256 erc20Amount = 200 ether;
    tsHEVM.prank(address(tsDepositor1));
    tsWETH.transferFrom(address(tsDepositor1), address(yieldAccount), erc20Amount);

    // read storage
    bytes memory result1 = yieldAccount.execute(
      address(tsWETH),
      abi.encodeWithSelector(IWETH.balanceOf.selector, address(yieldAccount))
    );
    uint256 erc20Balance1 = abi.decode(result1, (uint256));
    assertEq(erc20Balance1, erc20Amount, 'erc20Balance1 not eq');

    // write storage
    uint256 withdrawAmount = erc20Amount / 2;
    bytes memory result2 = yieldAccount.execute(
      address(tsWETH),
      abi.encodeWithSelector(IWETH.withdraw.selector, withdrawAmount)
    );
    assertEq(result2.length, 0, 'result2 not 0');

    uint256 ethBalance3 = address(yieldAccount).balance;
    assertEq(ethBalance3, withdrawAmount, 'ethBalance3 not eq');
  }

  function test_Should_ExecuteWithValue() public {
    yieldAccount.initialize(address(this), address(this));

    uint256 ethAmount = 200 ether;
    bytes memory result = yieldAccount.executeWithValue{value: ethAmount}(
      address(tsWETH),
      abi.encodeWithSelector(IWETH.deposit.selector),
      ethAmount
    );
    assertEq(result.length, 0, 'result not 0');

    uint256 wethBalance = tsWETH.balanceOf(address(yieldAccount));
    assertEq(wethBalance, ethAmount, 'wethBalance not eq');
  }

  function test_Should_Rescue() public {
    yieldAccount.initialize(address(this), address(this));

    uint256 erc20Amount = 200 ether;
    tsHEVM.prank(address(tsDepositor1));
    tsWETH.transferFrom(address(tsDepositor1), address(yieldAccount), erc20Amount);

    yieldAccount.rescue(
      address(tsWETH),
      abi.encodeWithSelector(IWETH.transferFrom.selector, address(yieldAccount), address(this), erc20Amount)
    );

    uint256 wethBalance = tsWETH.balanceOf(address(this));
    assertEq(wethBalance, erc20Amount, 'wethBalance not eq');
  }

  receive() external payable {}
}
