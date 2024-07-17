// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';

import 'test/helpers/TestUser.sol';
import 'test/setup/TestWithBaseAction.sol';

contract TestIntYieldBorrowERC20 is TestWithBaseAction {
  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_Should_BorrowWETH() public {
    prepareWETH(tsDepositor1);

    uint256 borrowAmount = 10 ether;

    tsStaker1.yieldBorrowERC20(tsCommonPoolId, address(tsWETH), borrowAmount);
  }
}
