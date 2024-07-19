// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';

import 'test/helpers/TestUser.sol';
import 'test/setup/TestWithCrossAction.sol';

contract TestIntCrossLiquidateERC20 is TestWithCrossAction {
  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function prepareUSDT(TestUser user) internal override {
    uint256 depositAmount = 100_000 * (10 ** tsUSDT.decimals());
    prepareERC20(user, address(tsUSDT), depositAmount);
  }

  function prepareWETH(TestUser user) internal override {
    uint256 depositAmount = 10 ether;
    prepareERC20(user, address(tsWETH), depositAmount);
  }

  function test_Should_LiquidateUSDT_HasWETH() public {
    prepareUSDT(tsDepositor1);

    prepareWETH(tsBorrower1);

    TestUserAccountData memory accountDataBeforeBorrow = getUserAccountData(address(tsBorrower1), tsCommonPoolId);

    // borrow some eth
    uint8[] memory borrowGroups = new uint8[](1);
    borrowGroups[0] = tsLowRateGroupId;

    uint256[] memory borrowAmounts = new uint256[](1);
    uint256 usdtCurPrice = tsPriceOracle.getAssetPrice(address(tsUSDT));
    borrowAmounts[0] = (accountDataBeforeBorrow.availableBorrowInBase * (10 ** tsUSDT.decimals())) / usdtCurPrice;

    actionCrossBorrowERC20(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsUSDT),
      borrowGroups,
      borrowAmounts,
      new bytes(0)
    );

    // make some interest
    advanceTimes(365 days);

    // drop down eth price to lower heath factor
    uint256 wethCurPrice = tsPriceOracle.getAssetPrice(address(tsWETH));
    uint256 wethNewPrice = (wethCurPrice * 80) / 100;
    tsCLAggregatorWETH.updateAnswer(int256(wethNewPrice));

    TestUserAccountData memory accountDataAfterBorrow = getUserAccountData(address(tsBorrower1), tsCommonPoolId);
    assertLt(accountDataAfterBorrow.healthFactor, 1e18, 'ACC:healthFactor');

    (uint256 actualCollateralToLiquidate, uint256 actualDebtToLiquidate) = tsPoolLens.getUserCrossLiquidateData(
      tsCommonPoolId,
      address(tsBorrower1),
      address(tsWETH),
      0,
      address(tsUSDT),
      borrowAmounts[0]
    );
    assertGt(actualDebtToLiquidate, 0, 'actualDebtToLiquidate');
    assertGt(actualCollateralToLiquidate, 0, 'actualCollateralToLiquidate');

    // liquidate some eth
    tsLiquidator1.approveERC20(address(tsUSDT), type(uint256).max);

    actionCrossLiquidateERC20(
      address(tsLiquidator1),
      tsCommonPoolId,
      address(tsBorrower1),
      address(tsWETH),
      address(tsUSDT),
      borrowAmounts[0],
      false,
      new bytes(0)
    );
  }

  function test_Should_LiquidateUSDT_HasWETH_SupplyAsCollateral() public {
    prepareUSDT(tsDepositor1);

    prepareWETH(tsBorrower1);

    TestUserAccountData memory accountDataBeforeBorrow = getUserAccountData(address(tsBorrower1), tsCommonPoolId);

    // borrow some eth
    uint8[] memory borrowGroups = new uint8[](1);
    borrowGroups[0] = tsLowRateGroupId;

    uint256[] memory borrowAmounts = new uint256[](1);
    uint256 usdtCurPrice = tsPriceOracle.getAssetPrice(address(tsUSDT));
    borrowAmounts[0] = (accountDataBeforeBorrow.availableBorrowInBase * (10 ** tsUSDT.decimals())) / usdtCurPrice;

    actionCrossBorrowERC20(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsUSDT),
      borrowGroups,
      borrowAmounts,
      new bytes(0)
    );

    // make some interest
    advanceTimes(365 days);

    // drop down eth price to lower heath factor
    uint256 wethCurPrice = tsPriceOracle.getAssetPrice(address(tsWETH));
    uint256 wethNewPrice = (wethCurPrice * 80) / 100;
    tsCLAggregatorWETH.updateAnswer(int256(wethNewPrice));

    TestUserAccountData memory accountDataAfterBorrow = getUserAccountData(address(tsBorrower1), tsCommonPoolId);
    assertLt(accountDataAfterBorrow.healthFactor, 1e18, 'ACC:healthFactor');

    TestUserAssetData memory borrowerUADBeforeLiq = getUserAssetData(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );

    // liquidate some eth
    tsLiquidator1.approveERC20(address(tsUSDT), type(uint256).max);

    tsHEVM.prank(address(tsLiquidator1));
    tsCrossLiquidation.crossLiquidateERC20(
      tsCommonPoolId,
      address(tsBorrower1),
      address(tsWETH),
      address(tsUSDT),
      borrowAmounts[0],
      true
    );

    TestUserAssetData memory borrowerUADAfterLiq = getUserAssetData(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );

    TestUserAssetData memory liquidatorUADAfterLiq = getUserAssetData(
      address(tsLiquidator1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    assertEq(
      liquidatorUADAfterLiq.totalCrossSupply,
      (borrowerUADBeforeLiq.totalCrossSupply - borrowerUADAfterLiq.totalCrossSupply),
      'UAD:totalCrossSupply'
    );
  }
}
