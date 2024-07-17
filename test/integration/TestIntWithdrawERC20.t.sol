// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';

import 'test/setup/TestWithBaseAction.sol';

contract TestIntWithdrawERC20 is TestWithBaseAction {
  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_RevertIf_AmountZero() public {
    uint256 amount = 0 ether;

    actionWithdrawERC20(address(tsDepositor1), tsCommonPoolId, address(tsWETH), amount, bytes(Errors.INVALID_AMOUNT));
  }

  function test_Should_Withdraw_WETH() public {
    uint256 amount = 100 ether;

    tsDepositor1.approveERC20(address(tsWETH), amount);
    actionDepositERC20(address(tsDepositor1), tsCommonPoolId, address(tsWETH), amount, new bytes(0));

    actionWithdrawERC20(address(tsDepositor1), tsCommonPoolId, address(tsWETH), amount, new bytes(0));
  }
}
