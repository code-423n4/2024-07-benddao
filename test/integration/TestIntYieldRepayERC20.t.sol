// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';

import 'test/helpers/TestUser.sol';
import 'test/setup/TestWithBaseAction.sol';

contract TestIntYieldRepayERC20 is TestWithBaseAction {
  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_Should_RepayWETH() public {
    prepareWETH(tsDepositor1);

    uint256 borrowAmount = 10 ether;

    tsStaker1.yieldBorrowERC20(tsCommonPoolId, address(tsWETH), borrowAmount);

    // make some interest
    advanceTimes(365 days);

    // repay full
    uint256 repayAmount = tsPoolLens.getYieldERC20BorrowBalance(tsCommonPoolId, address(tsWETH), address(tsStaker1));
    assertGt(repayAmount, borrowAmount, 'yield balance should have interest');

    tsStaker1.approveERC20(address(tsWETH), type(uint256).max);

    tsStaker1.yieldRepayERC20(tsCommonPoolId, address(tsWETH), repayAmount);
  }
}
