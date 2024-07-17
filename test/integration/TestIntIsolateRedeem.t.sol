// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';

import 'test/helpers/TestUser.sol';
import 'test/setup/TestWithIsolateAction.sol';

contract TestIntIsolateRedeem is TestWithIsolateAction {
  struct TestCaseLocalVars {
    uint256 poolBalanceBefore;
    uint256 poolBalanceAfter;
    // 1 - liquidator, 2 - borrower
    uint256 walletBalanceBefore1;
    uint256 walletBalanceBefore2;
    uint256 walletBalanceAfter1;
    uint256 walletBalanceAfter2;
    TestLoanData[] loanDataBefore;
    TestLoanData[] loanDataAfter;
    uint256 txAuctionTimestamp;
    uint256 totalBidAmount;
    uint256 totalBidFine;
    uint256 totalRedeemAmount;
  }

  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function prepareBorrow(TestUser user, address nftAsset, uint256[] memory tokenIds, address debtAsset) internal {
    TestLoanData memory loanDataBeforeBorrow = getIsolateCollateralData(tsCommonPoolId, nftAsset, 0, debtAsset);

    uint256[] memory borrowAmounts = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      borrowAmounts[i] = loanDataBeforeBorrow.availableBorrow - (i + 1);
    }

    user.isolateBorrow(tsCommonPoolId, nftAsset, tokenIds, debtAsset, borrowAmounts, address(user), address(user));
  }

  function prepareAuction(TestUser user, address nftAsset, uint256[] memory tokenIds, address debtAsset) internal {
    user.approveERC20(debtAsset, type(uint256).max);

    uint256[] memory bidAmounts = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      TestLoanData memory loanDataBeforeAuction = getIsolateLoanData(tsCommonPoolId, nftAsset, tokenIds[i]);
      assertLt(loanDataBeforeAuction.healthFactor, 1e18, 'healthFactor not lt 1');
      bidAmounts[i] = (loanDataBeforeAuction.borrowAmount * 1011) / 1000;
    }

    user.isolateAuction(tsCommonPoolId, nftAsset, tokenIds, debtAsset, bidAmounts);
  }

  function test_Should_RedeemWETH() public {
    TestCaseLocalVars memory testVars;

    // deposit
    prepareWETH(tsDepositor1);
    uint256[] memory tokenIds = prepareIsolateBAYC(tsBorrower1);

    // borrow
    prepareBorrow(tsBorrower1, address(tsBAYC), tokenIds, address(tsWETH));

    // make some interest
    advanceTimes(365 days);

    // drop down nft price
    actionSetNftPrice(address(tsBAYC), 5000);

    // auction
    prepareAuction(tsLiquidator1, address(tsBAYC), tokenIds, address(tsWETH));

    uint256[] memory redeemAmounts = new uint256[](tokenIds.length);
    testVars.loanDataBefore = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      testVars.totalBidAmount += testVars.loanDataBefore[i].bidAmount;
      testVars.totalBidFine += testVars.loanDataBefore[i].bidFine;
      testVars.totalRedeemAmount += testVars.loanDataBefore[i].redeemAmount;
      redeemAmounts[i] = testVars.loanDataBefore[i].redeemAmount;
    }

    testVars.poolBalanceBefore = tsWETH.balanceOf(address(tsPoolManager));
    testVars.walletBalanceBefore1 = tsWETH.balanceOf(address(tsLiquidator1));
    testVars.walletBalanceBefore2 = tsWETH.balanceOf(address(tsBorrower1));

    // redeem
    tsBorrower1.approveERC20(address(tsWETH), type(uint256).max);
    tsBorrower1.isolateRedeem(tsCommonPoolId, address(tsBAYC), tokenIds, address(tsWETH), redeemAmounts);
    testVars.txAuctionTimestamp = block.timestamp;

    // check results
    testVars.loanDataAfter = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertEq(testVars.loanDataAfter[i].bidStartTimestamp, 0, 'bidStartTimestamp');
      assertEq(testVars.loanDataAfter[i].firstBidder, address(0), 'firstBidder');
      assertEq(testVars.loanDataAfter[i].lastBidder, address(0), 'lastBidder');
      assertEq(testVars.loanDataAfter[i].bidAmount, 0, 'bidAmount');
    }

    testVars.poolBalanceAfter = tsWETH.balanceOf(address(tsPoolManager));
    assertEq(
      testVars.poolBalanceAfter,
      testVars.poolBalanceBefore - testVars.totalBidAmount + testVars.totalRedeemAmount,
      'tsPoolManager balance'
    );

    testVars.walletBalanceAfter1 = tsWETH.balanceOf(address(tsLiquidator1));
    assertEq(
      testVars.walletBalanceAfter1,
      (testVars.walletBalanceBefore1 + testVars.totalBidAmount + testVars.totalBidFine),
      'tsLiquidator1 balance'
    );

    testVars.walletBalanceAfter2 = tsWETH.balanceOf(address(tsBorrower1));
    assertEq(
      testVars.walletBalanceAfter2,
      (testVars.walletBalanceBefore2 - testVars.totalRedeemAmount - testVars.totalBidFine),
      'tsBorrower1 balance'
    );
  }

  function test_Should_RedeemUSDT() public {
    TestCaseLocalVars memory testVars;

    // deposit
    prepareUSDT(tsDepositor1);
    uint256[] memory tokenIds = prepareIsolateBAYC(tsBorrower1);

    // borrow
    prepareBorrow(tsBorrower1, address(tsBAYC), tokenIds, address(tsUSDT));

    // make some interest
    advanceTimes(365 days);

    // drop down nft price
    actionSetNftPrice(address(tsBAYC), 5000);

    // auction
    prepareAuction(tsLiquidator1, address(tsBAYC), tokenIds, address(tsUSDT));

    uint256[] memory redeemAmounts = new uint256[](tokenIds.length);
    testVars.loanDataBefore = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      testVars.totalBidAmount += testVars.loanDataBefore[i].bidAmount;
      testVars.totalBidFine += testVars.loanDataBefore[i].bidFine;
      testVars.totalRedeemAmount += testVars.loanDataBefore[i].redeemAmount;
      redeemAmounts[i] = testVars.loanDataBefore[i].redeemAmount;
    }

    testVars.poolBalanceBefore = tsUSDT.balanceOf(address(tsPoolManager));
    testVars.walletBalanceBefore1 = tsUSDT.balanceOf(address(tsLiquidator1));
    testVars.walletBalanceBefore2 = tsUSDT.balanceOf(address(tsBorrower1));

    // redeem
    tsBorrower1.approveERC20(address(tsUSDT), type(uint256).max);
    tsBorrower1.isolateRedeem(tsCommonPoolId, address(tsBAYC), tokenIds, address(tsUSDT), redeemAmounts);
    testVars.txAuctionTimestamp = block.timestamp;

    // check results
    testVars.loanDataAfter = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertEq(testVars.loanDataAfter[i].bidStartTimestamp, 0, 'bidStartTimestamp');
      assertEq(testVars.loanDataAfter[i].firstBidder, address(0), 'firstBidder');
      assertEq(testVars.loanDataAfter[i].lastBidder, address(0), 'lastBidder');
      assertEq(testVars.loanDataAfter[i].bidAmount, 0, 'bidAmount');
    }

    testVars.poolBalanceAfter = tsUSDT.balanceOf(address(tsPoolManager));
    assertEq(
      testVars.poolBalanceAfter,
      testVars.poolBalanceBefore - testVars.totalBidAmount + testVars.totalRedeemAmount,
      'tsPoolManager balance'
    );

    testVars.walletBalanceAfter1 = tsUSDT.balanceOf(address(tsLiquidator1));
    assertEq(
      testVars.walletBalanceAfter1,
      (testVars.walletBalanceBefore1 + testVars.totalBidAmount + testVars.totalBidFine),
      'tsLiquidator1 balance'
    );

    testVars.walletBalanceAfter2 = tsUSDT.balanceOf(address(tsBorrower1));
    assertEq(
      testVars.walletBalanceAfter2,
      (testVars.walletBalanceBefore2 - testVars.totalRedeemAmount - testVars.totalBidFine),
      'tsBorrower1 balance'
    );
  }
}
