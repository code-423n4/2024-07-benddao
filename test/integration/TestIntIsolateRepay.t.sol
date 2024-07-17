// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';

import 'test/helpers/TestUser.sol';
import 'test/setup/TestWithIsolateAction.sol';

contract TestIntIsolateRepay is TestWithIsolateAction {
  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_Should_RepayUSDT_HasBAYC_Full() public {
    prepareUSDT(tsDepositor1);

    uint256[] memory tokenIds = prepareIsolateBAYC(tsBorrower1);

    TestLoanData memory loanDataBeforeBorrow = getIsolateCollateralData(
      tsCommonPoolId,
      address(tsBAYC),
      0,
      address(tsUSDT)
    );

    uint256[] memory borrowAmounts = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      borrowAmounts[i] = loanDataBeforeBorrow.availableBorrow - (i + 1);
    }

    actionIsolateBorrow(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      address(tsUSDT),
      borrowAmounts,
      new bytes(0)
    );

    tsBorrower1.approveERC20(address(tsUSDT), type(uint256).max);

    // make some interest
    advanceTimes(365 days);

    // repay full
    TestLoanData[] memory loanDataBeforeRepay = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);

    uint256[] memory repayAmounts = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      repayAmounts[i] = loanDataBeforeRepay[i].borrowAmount;
    }

    actionIsolateRepay(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      address(tsUSDT),
      repayAmounts,
      new bytes(0)
    );
  }

  function test_Should_RepayUSDT_HasBAYC_Part() public {
    prepareUSDT(tsDepositor1);

    uint256[] memory tokenIds = prepareIsolateBAYC(tsBorrower1);

    TestLoanData memory loanDataBeforeBorrow = getIsolateCollateralData(
      tsCommonPoolId,
      address(tsBAYC),
      0,
      address(tsUSDT)
    );

    uint256[] memory borrowAmounts = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      borrowAmounts[i] = loanDataBeforeBorrow.availableBorrow - (i + 1);
    }

    actionIsolateBorrow(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      address(tsUSDT),
      borrowAmounts,
      new bytes(0)
    );

    tsBorrower1.approveERC20(address(tsUSDT), type(uint256).max);

    // make some interest
    advanceTimes(365 days);

    // repay part
    TestLoanData[] memory loanDataBeforeRepay1 = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);

    uint256[] memory repayAmounts1 = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      repayAmounts1[i] = (loanDataBeforeRepay1[i].borrowAmount * (50 + i)) / 100;
    }

    actionIsolateRepay(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      address(tsUSDT),
      repayAmounts1,
      new bytes(0)
    );

    // repay full
    TestLoanData[] memory loanDataBeforeRepay2 = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    uint256[] memory repayAmounts2 = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      repayAmounts2[i] = loanDataBeforeRepay2[i].borrowAmount;
    }

    actionIsolateRepay(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      address(tsUSDT),
      repayAmounts2,
      new bytes(0)
    );
  }
}
