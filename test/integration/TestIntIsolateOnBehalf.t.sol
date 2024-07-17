// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';

import 'test/setup/TestWithPrepare.sol';

contract TestIntIsolateOnBehalf is TestWithPrepare {
  struct TestCaseLocalVars {
    // results
    // sender
    uint256 senderBalanceBefore;
    uint256 senderBalanceAfter;
    // onBehalf
    uint256 onBehalfBalanceBefore;
    uint256 onBehalfBalanceAfter;
    // receiver
    uint256 receiverBalanceBefore;
    uint256 receiverBalanceAfter;
  }

  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_RevertIf_Borrow_OnBehalf_Invalid_Params() public {
    // prepare
    prepareUSDT(tsDepositor1);
    uint256[] memory tokenIds = prepareIsolateBAYC(tsBorrower2);

    // calculate borrow amount
    TestLoanData memory loanDataBeforeBorrow = getIsolateCollateralData(
      tsCommonPoolId,
      address(tsBAYC),
      0,
      address(tsUSDT)
    );

    uint256 totalBorrowAmount;
    uint256[] memory borrowAmounts = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      borrowAmounts[i] = loanDataBeforeBorrow.availableBorrow - (i + 1);
      totalBorrowAmount += borrowAmounts[i];
    }

    // not approved
    tsHEVM.expectRevert(bytes(Errors.SENDER_NOT_APPROVED));
    tsBorrower1.isolateBorrow(
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      address(tsUSDT),
      borrowAmounts,
      address(tsBorrower2),
      address(tsBorrower3)
    );

    // invalid receiver
    tsBorrower2.setApprovalForAll(tsCommonPoolId, address(tsBAYC), address(tsBorrower1), true);

    tsHEVM.expectRevert(bytes(Errors.INVALID_TO_ADDRESS));
    tsBorrower1.isolateBorrow(
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      address(tsUSDT),
      borrowAmounts,
      address(tsBorrower2),
      address(0)
    );
  }

  function test_Should_Borrow_OnBehalf() public {
    // prepare
    prepareUSDT(tsDepositor1);
    uint256[] memory tokenIds = prepareIsolateBAYC(tsBorrower2);

    // calculate borrow amount
    TestLoanData memory loanDataBeforeBorrow = getIsolateCollateralData(
      tsCommonPoolId,
      address(tsBAYC),
      0,
      address(tsUSDT)
    );

    uint256 totalBorrowAmount;
    uint256[] memory borrowAmounts = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      borrowAmounts[i] = loanDataBeforeBorrow.availableBorrow - (i + 1);
      totalBorrowAmount += borrowAmounts[i];
    }

    // approve
    tsBorrower2.setApprovalForAll(tsCommonPoolId, address(tsBAYC), address(tsBorrower1), true);

    TestCaseLocalVars memory testVars;
    testVars.senderBalanceBefore = tsUSDT.balanceOf(address(tsBorrower1));
    testVars.onBehalfBalanceBefore = tsUSDT.balanceOf(address(tsBorrower2));
    testVars.receiverBalanceBefore = tsUSDT.balanceOf(address(tsBorrower3));

    tsBorrower1.isolateBorrow(
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      address(tsUSDT),
      borrowAmounts,
      address(tsBorrower2),
      address(tsBorrower3)
    );

    testVars.senderBalanceAfter = tsUSDT.balanceOf(address(tsBorrower1));
    testVars.onBehalfBalanceAfter = tsUSDT.balanceOf(address(tsBorrower2));
    testVars.receiverBalanceAfter = tsUSDT.balanceOf(address(tsBorrower3));

    assertEq(testVars.senderBalanceAfter, (testVars.senderBalanceBefore), 'sender.walletBalance not eq');
    assertEq(testVars.onBehalfBalanceAfter, (testVars.onBehalfBalanceBefore), 'onBehalf.walletBalance not eq');
    assertEq(
      testVars.receiverBalanceAfter,
      (testVars.receiverBalanceBefore + totalBorrowAmount),
      'receiver.walletBalance not eq'
    );
  }

  function test_RevertIf_Repay_OnBehalf_Invalid_Params() public {
    // prepare
    prepareUSDT(tsDepositor1);
    uint256[] memory tokenIds = prepareIsolateBAYC(tsBorrower2);

    // calculate borrow amount
    TestLoanData memory loanDataBeforeBorrow = getIsolateCollateralData(
      tsCommonPoolId,
      address(tsBAYC),
      0,
      address(tsUSDT)
    );

    uint256 totalBorrowAmount;
    uint256[] memory borrowAmounts = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      borrowAmounts[i] = loanDataBeforeBorrow.availableBorrow - (i + 1);
      totalBorrowAmount += borrowAmounts[i];
    }

    // borrow
    tsBorrower2.isolateBorrow(
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      address(tsUSDT),
      borrowAmounts,
      address(tsBorrower2),
      address(tsBorrower2)
    );

    // repay
    tsHEVM.expectRevert(bytes(Errors.INVALID_ONBEHALF_ADDRESS));
    tsBorrower1.isolateRepay(tsCommonPoolId, address(tsBAYC), tokenIds, address(tsUSDT), borrowAmounts, address(0));
  }

  function test_Should_Repay_OnBehalf() public {
    // prepare
    prepareUSDT(tsDepositor1);
    uint256[] memory tokenIds = prepareIsolateBAYC(tsBorrower2);

    // calculate borrow amount
    TestLoanData memory loanDataBeforeBorrow = getIsolateCollateralData(
      tsCommonPoolId,
      address(tsBAYC),
      0,
      address(tsUSDT)
    );

    uint256 totalBorrowAmount;
    uint256[] memory borrowAmounts = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      borrowAmounts[i] = loanDataBeforeBorrow.availableBorrow - (i + 1);
      totalBorrowAmount += borrowAmounts[i];
    }

    // borrow
    tsBorrower2.isolateBorrow(
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      address(tsUSDT),
      borrowAmounts,
      address(tsBorrower2),
      address(tsBorrower2)
    );

    // repay
    TestCaseLocalVars memory testVars;
    testVars.senderBalanceBefore = tsUSDT.balanceOf(address(tsBorrower1));
    testVars.onBehalfBalanceBefore = tsUSDT.balanceOf(address(tsBorrower2));

    tsBorrower1.approveERC20(address(tsUSDT), type(uint256).max);

    tsBorrower1.isolateRepay(
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      address(tsUSDT),
      borrowAmounts,
      address(tsBorrower2)
    );

    testVars.senderBalanceAfter = tsUSDT.balanceOf(address(tsBorrower1));
    testVars.onBehalfBalanceAfter = tsUSDT.balanceOf(address(tsBorrower2));

    assertEq(
      testVars.senderBalanceAfter,
      (testVars.senderBalanceBefore - totalBorrowAmount),
      'sender.walletBalance not eq'
    );
    assertEq(testVars.onBehalfBalanceAfter, (testVars.onBehalfBalanceBefore), 'onBehalf.walletBalance not eq');
  }
}
