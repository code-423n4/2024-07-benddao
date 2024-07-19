// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';

import 'test/setup/TestWithPrepare.sol';

contract TestPoolLens is TestWithPrepare {
  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  struct GetUserAccountDataForSupplyAssetTestVars {
    uint256 totalCollateralInBase;
    uint256 totalBorrowInBase;
    uint256 availableBorrowInBase;
    uint256 avgLtv;
    uint256 avgLiquidationThreshold;
    uint256 healthFactor;
  }

  function test_Should_GetUserAccountDataForCalculation_Supply() public {
    tsDepositor1.approveERC20(address(tsWETH), type(uint256).max);

    uint256 amount1 = 100 ether;
    tsDepositor1.depositERC20(tsCommonPoolId, address(tsWETH), amount1, address(tsDepositor1));

    GetUserAccountDataForSupplyAssetTestVars memory vars1;
    (
      vars1.totalCollateralInBase,
      vars1.totalBorrowInBase,
      vars1.availableBorrowInBase,
      vars1.avgLtv,
      vars1.avgLiquidationThreshold,
      vars1.healthFactor
    ) = tsPoolLens.getUserAccountDataForCalculation(address(tsDepositor1), tsCommonPoolId, 1, address(tsWETH), 0);

    uint256 amount2 = 50 ether;
    GetUserAccountDataForSupplyAssetTestVars memory vars2;
    (
      vars2.totalCollateralInBase,
      vars2.totalBorrowInBase,
      vars2.availableBorrowInBase,
      vars2.avgLtv,
      vars2.avgLiquidationThreshold,
      vars2.healthFactor
    ) = tsPoolLens.getUserAccountDataForCalculation(address(tsDepositor1), tsCommonPoolId, 1, address(tsWETH), amount2);

    assertGt(vars2.totalCollateralInBase, vars1.totalCollateralInBase, 'vars2.totalCollateralInBase not gt');
    assertGt(vars2.availableBorrowInBase, vars1.availableBorrowInBase, 'vars2.availableBorrowInBase not gt');
    assertEq(vars2.avgLtv, vars1.avgLtv, 'vars2.avgLtv not eq');
    assertEq(vars2.avgLiquidationThreshold, vars1.avgLiquidationThreshold, 'vars2.avgLiquidationThreshold not eq');

    GetUserAccountDataForSupplyAssetTestVars memory vars3;
    (
      vars3.totalCollateralInBase,
      vars3.totalBorrowInBase,
      vars3.availableBorrowInBase,
      vars3.avgLtv,
      vars3.avgLiquidationThreshold,
      vars3.healthFactor
    ) = tsPoolLens.getUserAccountDataForCalculation(address(tsDepositor1), tsCommonPoolId, 2, address(tsWETH), amount2);

    assertLt(vars3.totalCollateralInBase, vars1.totalCollateralInBase, 'vars3.totalCollateralInBase not lt');
    assertLt(vars3.availableBorrowInBase, vars1.availableBorrowInBase, 'vars3.availableBorrowInBase not lt');
    assertEq(vars3.avgLtv, vars1.avgLtv, 'vars3.avgLtv not eq');
    assertEq(vars3.avgLiquidationThreshold, vars1.avgLiquidationThreshold, 'vars3.avgLiquidationThreshold not eq');
  }

  function test_Should_GetUserAccountDataForCalculation_Borrow() public {
    prepareUSDT(tsDepositor1);

    prepareWETH(tsBorrower1);

    uint8[] memory borrowGroups = new uint8[](1);
    borrowGroups[0] = tsLowRateGroupId;

    uint256[] memory borrowAmounts = new uint256[](1);
    borrowAmounts[0] = 1000 * (10 ** tsUSDT.decimals());
    tsBorrower1.crossBorrowERC20(
      tsCommonPoolId,
      address(tsUSDT),
      borrowGroups,
      borrowAmounts,
      address(tsBorrower1),
      address(tsBorrower1)
    );

    GetUserAccountDataForSupplyAssetTestVars memory vars1;
    (
      vars1.totalCollateralInBase,
      vars1.totalBorrowInBase,
      vars1.availableBorrowInBase,
      vars1.avgLtv,
      vars1.avgLiquidationThreshold,
      vars1.healthFactor
    ) = tsPoolLens.getUserAccountDataForCalculation(address(tsBorrower1), tsCommonPoolId, 3, address(tsUSDT), 0);

    uint256 amount2 = 500 * (10 ** tsUSDT.decimals());
    GetUserAccountDataForSupplyAssetTestVars memory vars2;
    (
      vars2.totalCollateralInBase,
      vars2.totalBorrowInBase,
      vars2.availableBorrowInBase,
      vars2.avgLtv,
      vars2.avgLiquidationThreshold,
      vars2.healthFactor
    ) = tsPoolLens.getUserAccountDataForCalculation(address(tsBorrower1), tsCommonPoolId, 3, address(tsUSDT), amount2);

    assertEq(vars2.totalCollateralInBase, vars1.totalCollateralInBase, 'vars2.totalCollateralInBase not eq');
    assertLt(vars2.availableBorrowInBase, vars1.availableBorrowInBase, 'vars2.availableBorrowInBase not lt');
    assertEq(vars2.avgLtv, vars1.avgLtv, 'vars2.avgLtv not eq');
    assertEq(vars2.avgLiquidationThreshold, vars1.avgLiquidationThreshold, 'vars2.avgLiquidationThreshold not eq');
    assertLt(vars2.healthFactor, vars1.healthFactor, 'vars3.healthFactor not lt');

    GetUserAccountDataForSupplyAssetTestVars memory vars3;
    (
      vars3.totalCollateralInBase,
      vars3.totalBorrowInBase,
      vars3.availableBorrowInBase,
      vars3.avgLtv,
      vars3.avgLiquidationThreshold,
      vars3.healthFactor
    ) = tsPoolLens.getUserAccountDataForCalculation(address(tsBorrower1), tsCommonPoolId, 4, address(tsUSDT), amount2);

    assertEq(vars3.totalCollateralInBase, vars1.totalCollateralInBase, 'vars3.totalCollateralInBase not eq');
    assertGt(vars3.availableBorrowInBase, vars1.availableBorrowInBase, 'vars3.availableBorrowInBase not gt');
    assertEq(vars3.avgLtv, vars1.avgLtv, 'vars3.avgLtv not eq');
    assertEq(vars3.avgLiquidationThreshold, vars1.avgLiquidationThreshold, 'vars3.avgLiquidationThreshold not eq');
    assertGt(vars3.healthFactor, vars1.healthFactor, 'vars3.healthFactor not gt');
  }

  function test_Should_GetIsolateDataList() public {
    prepareWETH(tsDepositor1);

    uint256[] memory tokenIds = prepareIsolateBAYC(tsBorrower1);

    address[] memory nftAssets = new address[](tokenIds.length);
    address[] memory debtAssets = new address[](tokenIds.length);

    for (uint256 i = 0; i < tokenIds.length; i++) {
      nftAssets[i] = address(tsBAYC);
      debtAssets[i] = address(tsWETH);
    }

    (
      ,
      ,
      /*uint256[] memory totalCollaterals*/ /*uint256[] memory totalBorrows*/ uint256[]
        memory availableBorrows /*uint256[] memory healthFactors*/,

    ) = tsPoolLens.getIsolateCollateralDataList(tsCommonPoolId, nftAssets, tokenIds, debtAssets);

    uint256[] memory borrowAmounts = new uint256[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      borrowAmounts[i] = availableBorrows[i] - (i + 1);
    }

    tsBorrower1.isolateBorrow(
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      address(tsWETH),
      borrowAmounts,
      address(tsBorrower1),
      address(tsBorrower1)
    );

    tsPoolLens.getIsolateLoanDataList(tsCommonPoolId, nftAssets, tokenIds);

    tsPoolLens.getIsolateAuctionDataList(tsCommonPoolId, nftAssets, tokenIds);

    tsPoolLens.getERC721TokenDataList(tsCommonPoolId, nftAssets, tokenIds);
  }
}
