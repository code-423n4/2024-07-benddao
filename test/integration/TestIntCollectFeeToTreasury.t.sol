// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';
import 'src/libraries/math/PercentageMath.sol';

import 'test/setup/TestWithPrepare.sol';

contract TestIntCollectFeeToTreasury is TestWithPrepare {
  struct TestCaseLocalVars {
    // results
    uint256 feeFactor;
    uint256 normAccruedFeeBefore;
    uint256 normAccruedFeeAfter;
    uint256 treasuryBalanceBefore;
    uint256 treasuryBalanceAfter;
  }

  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_Should_CollectFeeToTreasury() public {
    TestCaseLocalVars memory testVars;

    prepareUSDT(tsDepositor1);

    uint256 depositAmount = 10 * (10 ** IERC20Metadata(tsWETH).decimals());
    prepareERC20(tsBorrower1, address(tsWETH), depositAmount);

    // borrow
    TestUserAccountData memory accountDataBeforeBorrow1 = getUserAccountData(address(tsBorrower1), tsCommonPoolId);

    uint8[] memory borrowGroups1 = new uint8[](1);
    borrowGroups1[0] = tsLowRateGroupId;

    uint256[] memory borrowAmounts1 = new uint256[](1);
    borrowAmounts1[0] =
      (accountDataBeforeBorrow1.availableBorrowInBase * (10 ** tsUSDT.decimals())) /
      tsPriceOracle.getAssetPrice(address(tsUSDT));

    tsBorrower1.crossBorrowERC20(
      tsCommonPoolId,
      address(tsUSDT),
      borrowGroups1,
      borrowAmounts1,
      address(tsBorrower1),
      address(tsBorrower1)
    );

    // accure some interest
    advanceTimes(365 days);

    // repay
    (testVars.feeFactor, , ) = tsPoolLens.getAssetFeeData(tsCommonPoolId, address(tsUSDT));

    tsBorrower1.approveERC20(address(tsUSDT), type(uint256).max);

    uint8[] memory repayGroups2 = new uint8[](1);
    repayGroups2[0] = tsLowRateGroupId;

    uint256[] memory repayAmounts = new uint256[](1);
    (, repayAmounts[0], , ) = tsPoolLens.getUserAssetGroupData(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsUSDT),
      uint8(tsLowRateGroupId)
    );

    tsBorrower1.crossRepayERC20(tsCommonPoolId, address(tsUSDT), repayGroups2, repayAmounts, address(tsBorrower1));

    (, , testVars.normAccruedFeeAfter) = tsPoolLens.getAssetFeeData(tsCommonPoolId, address(tsUSDT));

    // collect
    (testVars.treasuryBalanceBefore, , , ) = tsPoolLens.getUserAssetData(tsTreasury, tsCommonPoolId, address(tsUSDT));

    address[] memory feeAssets = new address[](1);
    feeAssets[0] = address(tsUSDT);
    tsHEVM.prank(tsPoolAdmin);
    tsBVault.collectFeeToTreasury(tsCommonPoolId, feeAssets);

    (testVars.treasuryBalanceAfter, , , ) = tsPoolLens.getUserAssetData(tsTreasury, tsCommonPoolId, address(tsUSDT));

    assertEq(
      testVars.treasuryBalanceAfter,
      (testVars.treasuryBalanceBefore + testVars.normAccruedFeeAfter),
      'treasuryBalanceAfter not eq'
    );
  }
}
