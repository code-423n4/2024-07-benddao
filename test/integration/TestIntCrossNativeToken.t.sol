// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';

import 'test/setup/TestWithPrepare.sol';

contract TestIntCrossNativeToken is TestWithPrepare {
  struct TestCaseLocalVars {
    // results
    uint256 userBalanceBefore;
    uint256 userBalanceAfter;
  }

  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_Should_Deposit_Native() public {
    tsDepositor1.approveERC20(address(tsWETH), type(uint256).max);

    // deposit
    TestCaseLocalVars memory testVars1;
    testVars1.userBalanceBefore = tsDepositor1.balanceOfNative();

    uint256 amount1 = 123 ether;
    tsDepositor1.depositERC20(tsCommonPoolId, Constants.NATIVE_TOKEN_ADDRESS, amount1, address(tsDepositor1));

    testVars1.userBalanceAfter = tsDepositor1.balanceOfNative();

    assertEq(testVars1.userBalanceAfter, (testVars1.userBalanceBefore - amount1), '1 userBalanceAfter not eq');

    // withdraw
    TestCaseLocalVars memory testVars2;
    testVars2.userBalanceBefore = tsDepositor1.balanceOfNative();

    uint256 amount2 = 123 ether;
    tsDepositor1.withdrawERC20(
      tsCommonPoolId,
      Constants.NATIVE_TOKEN_ADDRESS,
      amount2,
      address(tsDepositor1),
      address(tsDepositor1)
    );

    testVars2.userBalanceAfter = tsDepositor1.balanceOfNative();

    assertEq(testVars2.userBalanceAfter, (testVars2.userBalanceBefore + amount2), '2 userBalanceAfter not eq');
  }

  function test_Should_Borrow_Native() public {
    prepareWETH(tsDepositor1);

    prepareCrossBAYC(tsBorrower1);

    // borrow
    TestCaseLocalVars memory testVars1;
    testVars1.userBalanceBefore = tsBorrower1.balanceOfNative();

    TestUserAccountData memory accountDataBeforeBorrow1 = getUserAccountData(address(tsBorrower1), tsCommonPoolId);

    uint8[] memory borrowGroups1 = new uint8[](1);
    borrowGroups1[0] = tsLowRateGroupId;

    uint256[] memory borrowAmounts1 = new uint256[](1);
    borrowAmounts1[0] =
      (accountDataBeforeBorrow1.availableBorrowInBase * (10 ** tsWETH.decimals())) /
      tsPriceOracle.getAssetPrice(address(tsWETH));

    borrowAmounts1[0] = borrowAmounts1[0];

    tsBorrower1.approveERC20(address(tsWETH), type(uint256).max);
    tsBorrower1.crossBorrowERC20(
      tsCommonPoolId,
      Constants.NATIVE_TOKEN_ADDRESS,
      borrowGroups1,
      borrowAmounts1,
      address(tsBorrower1),
      address(tsBorrower1)
    );

    testVars1.userBalanceAfter = tsBorrower1.balanceOfNative();

    assertEq(
      testVars1.userBalanceAfter,
      (testVars1.userBalanceBefore + borrowAmounts1[0]),
      '1 userBalanceAfter not eq'
    );

    // repay
    TestCaseLocalVars memory testVars2;
    testVars2.userBalanceBefore = tsBorrower1.balanceOfNative();

    uint8[] memory repayGroups2 = new uint8[](1);
    repayGroups2[0] = tsLowRateGroupId;

    uint256[] memory repayAmounts = new uint256[](1);
    (, repayAmounts[0], , ) = tsPoolLens.getUserAssetGroupData(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsWETH),
      uint8(tsLowRateGroupId)
    );

    tsBorrower1.crossRepayERC20(
      tsCommonPoolId,
      Constants.NATIVE_TOKEN_ADDRESS,
      repayGroups2,
      repayAmounts,
      address(tsBorrower1)
    );

    testVars2.userBalanceAfter = tsBorrower1.balanceOfNative();

    assertEq(testVars2.userBalanceAfter, (testVars2.userBalanceBefore - repayAmounts[0]), '2 userBalanceAfter not eq');
  }
}
