// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';

import 'test/helpers/TestUser.sol';
import 'test/setup/TestWithIsolateAction.sol';

contract TestIntIsolateAuction is TestWithIsolateAction {
  struct TestCaseLocalVars {
    uint256 walletBalanceBefore1;
    uint256 walletBalanceBefore2;
    uint256 walletBalanceBefore3;
    uint256 walletBalanceAfter1;
    uint256 walletBalanceAfter2;
    uint256 walletBalanceAfter3;
    TestLoanData[] loanDataBefore1;
    TestLoanData[] loanDataAfter1;
    TestLoanData[] loanDataAfter2;
    TestLoanData[] loanDataAfter3;
    uint256 txAuctionTimestamp1;
    uint256[] bidAmounts1;
    uint256[] bidAmounts2;
    uint256[] bidAmounts3;
    uint256 totalBidAmount1;
    uint256 totalBidAmount2;
    uint256 totalBidAmount3;
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

  function test_RevertIf_AuctionUSDT_InvalidHF() public {
    prepareUSDT(tsDepositor1);
    uint256[] memory tokenIds = prepareIsolateBAYC(tsBorrower1);

    prepareBorrow(tsBorrower1, address(tsBAYC), tokenIds, address(tsUSDT));

    // make some interest
    advanceTimes(365 days);

    // auction at first
    TestLoanData[] memory loanDataBeforeAuction = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertGt(loanDataBeforeAuction[i].healthFactor, 1e18, 'healthFactor GT 1');
    }

    uint256[] memory bidAmounts = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      bidAmounts[i] = loanDataBeforeAuction[i].borrowAmount;
    }

    tsHEVM.expectRevert(bytes(Errors.ISOLATE_BORROW_NOT_EXCEED_LIQUIDATION_THRESHOLD));
    tsLiquidator1.isolateAuction(tsCommonPoolId, address(tsBAYC), tokenIds, address(tsUSDT), bidAmounts);
  }

  function test_RevertIf_AuctionWETH_InvalidHF() public {
    prepareWETH(tsDepositor1);
    uint256[] memory tokenIds = prepareIsolateBAYC(tsBorrower1);

    prepareBorrow(tsBorrower1, address(tsBAYC), tokenIds, address(tsWETH));

    // make some interest
    advanceTimes(365 days);

    // auction at first
    TestLoanData[] memory loanDataBeforeAuction = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertGt(loanDataBeforeAuction[i].healthFactor, 1e18, 'healthFactor GT 1');
    }

    uint256[] memory bidAmounts = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      bidAmounts[i] = loanDataBeforeAuction[i].borrowAmount;
    }

    tsHEVM.expectRevert(bytes(Errors.ISOLATE_BORROW_NOT_EXCEED_LIQUIDATION_THRESHOLD));
    tsLiquidator1.isolateAuction(tsCommonPoolId, address(tsBAYC), tokenIds, address(tsWETH), bidAmounts);
  }

  function test_Should_AuctionUSDT() public {
    TestCaseLocalVars memory testVars;

    prepareUSDT(tsDepositor1);
    uint256[] memory tokenIds = prepareIsolateBAYC(tsBorrower1);
    prepareBorrow(tsBorrower1, address(tsBAYC), tokenIds, address(tsUSDT));

    // make some interest
    advanceTimes(365 days);

    // drop down nft price
    actionSetNftPrice(address(tsBAYC), 5000);

    testVars.loanDataBefore1 = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertLt(testVars.loanDataBefore1[i].healthFactor, 1e18, 'healthFactor not lt 1');
    }

    // auction at first
    if (_debugFlag) console.log('<<<<isolateAuction-1st-begin');
    testVars.walletBalanceBefore1 = tsUSDT.balanceOf(address(tsLiquidator1));

    testVars.bidAmounts1 = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      testVars.bidAmounts1[i] = testVars.loanDataBefore1[i].borrowAmount;
      testVars.totalBidAmount1 += testVars.bidAmounts1[i];
    }

    tsLiquidator1.approveERC20(address(tsUSDT), type(uint256).max);
    tsLiquidator1.isolateAuction(tsCommonPoolId, address(tsBAYC), tokenIds, address(tsUSDT), testVars.bidAmounts1);
    testVars.txAuctionTimestamp1 = block.timestamp;

    testVars.loanDataAfter1 = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertEq(testVars.loanDataAfter1[i].bidStartTimestamp, testVars.txAuctionTimestamp1, 'bidStartTimestamp');
      assertEq(testVars.loanDataAfter1[i].firstBidder, address(tsLiquidator1), 'firstBidder');
      assertEq(testVars.loanDataAfter1[i].lastBidder, address(tsLiquidator1), 'lastBidder');
      assertEq(testVars.loanDataAfter1[i].bidAmount, testVars.bidAmounts1[i], 'bidAmount');
    }
    testVars.walletBalanceAfter1 = tsUSDT.balanceOf(address(tsLiquidator1));
    assertEq(
      testVars.walletBalanceAfter1,
      (testVars.walletBalanceBefore1 - testVars.totalBidAmount1),
      'tsLiquidator1 balance'
    );

    if (_debugFlag) console.log('>>>>isolateAuction-1st-end');

    // auction at second
    if (_debugFlag) console.log('<<<<isolateAuction-2nd-begin');
    testVars.walletBalanceBefore1 = tsUSDT.balanceOf(address(tsLiquidator1));
    testVars.walletBalanceBefore2 = tsUSDT.balanceOf(address(tsLiquidator2));

    testVars.bidAmounts2 = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      testVars.bidAmounts2[i] = (testVars.loanDataAfter1[i].bidAmount * 1011) / 1000; // plus 1.1%
      testVars.totalBidAmount2 += testVars.bidAmounts2[i];
    }

    tsLiquidator2.approveERC20(address(tsUSDT), type(uint256).max);
    tsLiquidator2.isolateAuction(tsCommonPoolId, address(tsBAYC), tokenIds, address(tsUSDT), testVars.bidAmounts2);

    testVars.loanDataAfter2 = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertEq(testVars.loanDataAfter2[i].bidStartTimestamp, testVars.txAuctionTimestamp1, 'bidStartTimestamp');
      assertEq(testVars.loanDataAfter2[i].firstBidder, address(tsLiquidator1), 'firstBidder');
      assertEq(testVars.loanDataAfter2[i].lastBidder, address(tsLiquidator2), 'lastBidder');
      assertEq(testVars.loanDataAfter2[i].bidAmount, testVars.bidAmounts2[i], 'bidAmount');
    }

    testVars.walletBalanceAfter1 = tsUSDT.balanceOf(address(tsLiquidator1));
    assertEq(
      testVars.walletBalanceAfter1,
      (testVars.walletBalanceBefore1 + testVars.totalBidAmount1),
      'tsLiquidator1 balance'
    );

    testVars.walletBalanceAfter2 = tsUSDT.balanceOf(address(tsLiquidator2));
    assertEq(
      testVars.walletBalanceAfter2,
      (testVars.walletBalanceBefore2 - testVars.totalBidAmount2),
      'tsLiquidator2 balance'
    );

    if (_debugFlag) console.log('>>>>isolateAuction-2nd-end');

    // auction at third
    if (_debugFlag) console.log('<<<<isolateAuction-3rd-begin');
    testVars.walletBalanceBefore2 = tsUSDT.balanceOf(address(tsLiquidator2));
    testVars.walletBalanceBefore3 = tsUSDT.balanceOf(address(tsLiquidator3));

    testVars.bidAmounts3 = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      testVars.bidAmounts3[i] = (testVars.loanDataAfter2[i].bidAmount * 1011) / 1000; // plus 1.1%
      testVars.totalBidAmount3 += testVars.bidAmounts3[i];
    }

    tsLiquidator3.approveERC20(address(tsUSDT), type(uint256).max);
    tsLiquidator3.isolateAuction(tsCommonPoolId, address(tsBAYC), tokenIds, address(tsUSDT), testVars.bidAmounts3);

    testVars.loanDataAfter3 = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertEq(testVars.loanDataAfter3[i].bidStartTimestamp, testVars.txAuctionTimestamp1, 'bidStartTimestamp');
      assertEq(testVars.loanDataAfter3[i].firstBidder, address(tsLiquidator1), 'firstBidder');
      assertEq(testVars.loanDataAfter3[i].lastBidder, address(tsLiquidator3), 'lastBidder');
      assertEq(testVars.loanDataAfter3[i].bidAmount, testVars.bidAmounts3[i], 'bidAmount');
    }

    testVars.walletBalanceAfter2 = tsUSDT.balanceOf(address(tsLiquidator2));
    assertEq(
      testVars.walletBalanceAfter2,
      (testVars.walletBalanceBefore2 + testVars.totalBidAmount2),
      'tsLiquidator2 balance'
    );

    testVars.walletBalanceAfter3 = tsUSDT.balanceOf(address(tsLiquidator3));
    assertEq(
      testVars.walletBalanceAfter3,
      (testVars.walletBalanceBefore3 - testVars.totalBidAmount3),
      'tsLiquidator3 balance'
    );

    if (_debugFlag) console.log('>>>>isolateAuction-3rd-end');
  }

  function test_Should_AuctionWETH() public {
    TestCaseLocalVars memory testVars;

    prepareWETH(tsDepositor1);
    uint256[] memory tokenIds = prepareIsolateBAYC(tsBorrower1);
    prepareBorrow(tsBorrower1, address(tsBAYC), tokenIds, address(tsWETH));

    // make some interest
    advanceTimes(365 days);

    // drop down nft price
    actionSetNftPrice(address(tsBAYC), 5000);

    testVars.loanDataBefore1 = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertLt(testVars.loanDataBefore1[i].healthFactor, 1e18, 'healthFactor not lt 1');
    }

    // auction at first
    if (_debugFlag) console.log('<<<<isolateAuction-1st-begin');
    testVars.walletBalanceBefore1 = tsWETH.balanceOf(address(tsLiquidator1));

    testVars.bidAmounts1 = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      testVars.bidAmounts1[i] = testVars.loanDataBefore1[i].borrowAmount;
      testVars.totalBidAmount1 += testVars.bidAmounts1[i];
    }

    tsLiquidator1.approveERC20(address(tsWETH), type(uint256).max);
    tsLiquidator1.isolateAuction(tsCommonPoolId, address(tsBAYC), tokenIds, address(tsWETH), testVars.bidAmounts1);
    testVars.txAuctionTimestamp1 = block.timestamp;

    testVars.loanDataAfter1 = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertEq(testVars.loanDataAfter1[i].bidStartTimestamp, testVars.txAuctionTimestamp1, 'bidStartTimestamp');
      assertEq(testVars.loanDataAfter1[i].firstBidder, address(tsLiquidator1), 'firstBidder');
      assertEq(testVars.loanDataAfter1[i].lastBidder, address(tsLiquidator1), 'lastBidder');
      assertEq(testVars.loanDataAfter1[i].bidAmount, testVars.bidAmounts1[i], 'bidAmount');
    }
    testVars.walletBalanceAfter1 = tsWETH.balanceOf(address(tsLiquidator1));
    assertEq(
      testVars.walletBalanceAfter1,
      (testVars.walletBalanceBefore1 - testVars.totalBidAmount1),
      'tsLiquidator1 balance'
    );

    if (_debugFlag) console.log('>>>>isolateAuction-1st-end');

    // auction at second
    if (_debugFlag) console.log('<<<<isolateAuction-2nd-begin');
    testVars.walletBalanceBefore1 = tsWETH.balanceOf(address(tsLiquidator1));
    testVars.walletBalanceBefore2 = tsWETH.balanceOf(address(tsLiquidator2));

    testVars.bidAmounts2 = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      testVars.bidAmounts2[i] = (testVars.loanDataAfter1[i].bidAmount * 1011) / 1000; // plus 1.1%
      testVars.totalBidAmount2 += testVars.bidAmounts2[i];
    }

    tsLiquidator2.approveERC20(address(tsWETH), type(uint256).max);
    tsLiquidator2.isolateAuction(tsCommonPoolId, address(tsBAYC), tokenIds, address(tsWETH), testVars.bidAmounts2);

    testVars.loanDataAfter2 = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertEq(testVars.loanDataAfter2[i].bidStartTimestamp, testVars.txAuctionTimestamp1, 'bidStartTimestamp');
      assertEq(testVars.loanDataAfter2[i].firstBidder, address(tsLiquidator1), 'firstBidder');
      assertEq(testVars.loanDataAfter2[i].lastBidder, address(tsLiquidator2), 'lastBidder');
      assertEq(testVars.loanDataAfter2[i].bidAmount, testVars.bidAmounts2[i], 'bidAmount');
    }

    testVars.walletBalanceAfter1 = tsWETH.balanceOf(address(tsLiquidator1));
    assertEq(
      testVars.walletBalanceAfter1,
      (testVars.walletBalanceBefore1 + testVars.totalBidAmount1),
      'tsLiquidator1 balance'
    );

    testVars.walletBalanceAfter2 = tsWETH.balanceOf(address(tsLiquidator2));
    assertEq(
      testVars.walletBalanceAfter2,
      (testVars.walletBalanceBefore2 - testVars.totalBidAmount2),
      'tsLiquidator2 balance'
    );

    if (_debugFlag) console.log('>>>>isolateAuction-2nd-end');

    // auction at third
    if (_debugFlag) console.log('<<<<isolateAuction-3rd-begin');
    testVars.walletBalanceBefore2 = tsWETH.balanceOf(address(tsLiquidator2));
    testVars.walletBalanceBefore3 = tsWETH.balanceOf(address(tsLiquidator3));

    testVars.bidAmounts3 = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      testVars.bidAmounts3[i] = (testVars.loanDataAfter2[i].bidAmount * 1011) / 1000; // plus 1.1%
      testVars.totalBidAmount3 += testVars.bidAmounts3[i];
    }

    tsLiquidator3.approveERC20(address(tsWETH), type(uint256).max);
    tsLiquidator3.isolateAuction(tsCommonPoolId, address(tsBAYC), tokenIds, address(tsWETH), testVars.bidAmounts3);

    testVars.loanDataAfter3 = getIsolateLoanData(tsCommonPoolId, address(tsBAYC), tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertEq(testVars.loanDataAfter3[i].bidStartTimestamp, testVars.txAuctionTimestamp1, 'bidStartTimestamp');
      assertEq(testVars.loanDataAfter3[i].firstBidder, address(tsLiquidator1), 'firstBidder');
      assertEq(testVars.loanDataAfter3[i].lastBidder, address(tsLiquidator3), 'lastBidder');
      assertEq(testVars.loanDataAfter3[i].bidAmount, testVars.bidAmounts3[i], 'bidAmount');
    }

    testVars.walletBalanceAfter2 = tsWETH.balanceOf(address(tsLiquidator2));
    assertEq(
      testVars.walletBalanceAfter2,
      (testVars.walletBalanceBefore2 + testVars.totalBidAmount2),
      'tsLiquidator2 balance'
    );

    testVars.walletBalanceAfter3 = tsWETH.balanceOf(address(tsLiquidator3));
    assertEq(
      testVars.walletBalanceAfter3,
      (testVars.walletBalanceBefore3 - testVars.totalBidAmount3),
      'tsLiquidator3 balance'
    );

    if (_debugFlag) console.log('>>>>isolateAuction-3rd-end');
  }
}
