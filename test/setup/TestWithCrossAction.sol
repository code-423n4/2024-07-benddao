// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {ERC721} from '@openzeppelin/contracts/token/ERC721/ERC721.sol';

import {WadRayMath} from 'src/libraries/math/WadRayMath.sol';
import {MathUtils} from 'src/libraries/math/MathUtils.sol';
import {PercentageMath} from 'src/libraries/math/PercentageMath.sol';

import {Constants} from 'src/libraries/helpers/Constants.sol';
import {KVSortUtils} from 'src/libraries/helpers/KVSortUtils.sol';

import {IInterestRateModel} from 'src/interfaces/IInterestRateModel.sol';

import {TestWithBaseAction} from './TestWithBaseAction.sol';

import '@forge-std/Test.sol';

abstract contract TestWithCrossAction is TestWithBaseAction {
  using WadRayMath for uint256;
  using PercentageMath for uint256;

  function onSetUp() public virtual override {
    super.onSetUp();
  }

  /****************************************************************************/
  /* Actions */
  /****************************************************************************/

  function actionCrossBorrowERC20(
    address sender,
    uint32 poolId,
    address asset,
    uint8[] memory groups,
    uint256[] memory amounts,
    bytes memory revertMessage
  ) internal {
    if (_debugFlag) console.log('<<<<actionCrossBorrowERC20', 'begin');
    if (revertMessage.length > 0) {
      vm.expectRevert(revertMessage);
      tsHEVM.prank(sender);
      tsCrossLending.crossBorrowERC20(poolId, asset, groups, amounts, sender, sender);
    } else {
      // fetch contract data
      TestContractData memory dataBefore = getContractData(sender, poolId, asset, Constants.ASSET_TYPE_ERC20);

      // send tx
      if (_debugFlag) console.log('actionCrossBorrowERC20', 'sendtx');
      tsHEVM.prank(sender);
      tsCrossLending.crossBorrowERC20(poolId, asset, groups, amounts, sender, sender);
      uint256 txTimestamp = block.timestamp;

      // fetch contract data
      TestContractData memory dataAfter = getContractData(sender, poolId, asset, Constants.ASSET_TYPE_ERC20);

      // calc expected data
      TestContractData memory dataExpected;
      calcExpectedAssetDataAfterCrossBorrowERC20(dataBefore, dataAfter, dataExpected, groups, amounts, txTimestamp);
      calcExpectedUserDataAfterCrossBorrowERC20(dataBefore, dataAfter, dataExpected, groups, amounts, txTimestamp);

      // check the results
      checkAssetData(TestAction.CrossBorrowERC20, dataAfter.assetData, dataExpected.assetData);
      checkUserAssetData(TestAction.CrossBorrowERC20, dataAfter.userAssetData, dataExpected.userAssetData);
    }
    if (_debugFlag) console.log('>>>>actionCrossBorrowERC20', 'end');
  }

  function actionCrossRepayERC20(
    address sender,
    uint32 poolId,
    address asset,
    uint8[] memory groups,
    uint256[] memory amounts,
    bytes memory revertMessage
  ) internal {
    if (_debugFlag) console.log('<<<<actionCrossRepayERC20', 'begin');
    if (revertMessage.length > 0) {
      vm.expectRevert(revertMessage);
      tsHEVM.prank(sender);
      tsCrossLending.crossRepayERC20(poolId, asset, groups, amounts, sender);
    } else {
      // fetch contract data
      TestContractData memory dataBefore = getContractData(sender, poolId, asset, Constants.ASSET_TYPE_ERC20);

      // send tx
      if (_debugFlag) console.log('actionCrossRepayERC20', 'sendtx');
      tsHEVM.prank(sender);
      tsCrossLending.crossRepayERC20(poolId, asset, groups, amounts, sender);
      uint256 txTimestamp = block.timestamp;

      // fetch contract data
      TestContractData memory dataAfter = getContractData(sender, poolId, asset, Constants.ASSET_TYPE_ERC20);

      // calc expected data
      TestContractData memory dataExpected;

      calcExpectedAssetDataAfterCrossRepayERC20(dataBefore, dataAfter, dataExpected, groups, amounts, txTimestamp);
      calcExpectedUserDataAfterCrossRepayERC20(dataBefore, dataAfter, dataExpected, groups, amounts, txTimestamp);

      // check the results
      checkAssetData(TestAction.CrossRepayERC20, dataAfter.assetData, dataExpected.assetData);
      checkUserAssetData(TestAction.CrossRepayERC20, dataAfter.userAssetData, dataExpected.userAssetData);
    }
    if (_debugFlag) console.log('>>>>actionCrossRepayERC20', 'end');
  }

  function actionCrossLiquidateERC20(
    address sender,
    uint32 poolId,
    address borrower,
    address collateralAsset,
    address debtAsset,
    uint256 debtToCover,
    bool supplyAsCollateral,
    bytes memory revertMessage
  ) internal {
    if (_debugFlag) console.log('<<<<actionCrossLiquidateERC20', 'begin');
    if (revertMessage.length > 0) {
      vm.expectRevert(revertMessage);
      tsHEVM.prank(sender);
      tsCrossLiquidation.crossLiquidateERC20(
        poolId,
        borrower,
        collateralAsset,
        debtAsset,
        debtToCover,
        supplyAsCollateral
      );
    } else {
      // fetch contract data
      // liquidator & collateral
      TestContractData memory dataBefore = getContractData(sender, poolId, collateralAsset, Constants.ASSET_TYPE_ERC20);

      // liquidator & debt
      dataBefore.assetData2 = getAssetData(poolId, debtAsset, Constants.ASSET_TYPE_ERC20);
      dataBefore.userAssetData2 = getUserAssetData(sender, poolId, debtAsset, Constants.ASSET_TYPE_ERC20);

      // borrower & collateral
      dataBefore.userAssetData3 = getUserAssetData(borrower, poolId, collateralAsset, Constants.ASSET_TYPE_ERC20);

      // borrower & debt
      dataBefore.userAssetData4 = getUserAssetData(borrower, poolId, debtAsset, Constants.ASSET_TYPE_ERC20);

      // send tx
      if (_debugFlag) console.log('actionCrossLiquidateERC20', 'sendtx');
      tsHEVM.prank(sender);
      tsCrossLiquidation.crossLiquidateERC20(
        poolId,
        borrower,
        collateralAsset,
        debtAsset,
        debtToCover,
        supplyAsCollateral
      );
      uint256 txTimestamp = block.timestamp;

      // fetch contract data
      // liquidator & collateral
      TestContractData memory dataAfter = getContractData(sender, poolId, collateralAsset, Constants.ASSET_TYPE_ERC20);

      // liquidator & debt
      dataAfter.assetData2 = getAssetData(poolId, debtAsset, Constants.ASSET_TYPE_ERC20);
      dataAfter.userAssetData2 = getUserAssetData(sender, poolId, debtAsset, Constants.ASSET_TYPE_ERC20);

      // borrower & collateral
      dataAfter.userAssetData3 = getUserAssetData(borrower, poolId, collateralAsset, Constants.ASSET_TYPE_ERC20);

      // borrower & debt
      dataAfter.userAssetData4 = getUserAssetData(borrower, poolId, debtAsset, Constants.ASSET_TYPE_ERC20);

      // calc expected data
      TestContractData memory dataExpected;

      uint256 colToLiq = calcExpectedCollateralFromDebtToCover(
        dataBefore.assetData,
        dataBefore.assetData2,
        dataBefore.userAssetData3,
        debtToCover
      );

      debtToCover = calcExpectedDebtToCoverFromERC20(dataBefore.assetData, dataBefore.assetData2, colToLiq);

      calcExpectedCollateralAssetDataAfterCrossLiquidateERC20(
        dataBefore,
        dataAfter,
        dataExpected,
        colToLiq,
        txTimestamp
      );
      calcExpectedDebtAssetDataAfterCrossLiquidateERC20(dataBefore, dataAfter, dataExpected, debtToCover, txTimestamp);

      calcExpectedLiquidatorColUserDataAfterCrossLiquidateERC20(
        dataBefore,
        dataAfter,
        dataExpected,
        colToLiq,
        txTimestamp
      );
      calcExpectedLiquidatorDebtUserDataAfterCrossLiquidateERC20(
        dataBefore,
        dataAfter,
        dataExpected,
        debtToCover,
        txTimestamp
      );

      calcExpectedBorrowerColUserDataAfterCrossLiquidateERC20(
        dataBefore,
        dataAfter,
        dataExpected,
        colToLiq,
        txTimestamp
      );
      calcExpectedBorrowerDebtUserDataAfterCrossLiquidateERC20(
        dataBefore,
        dataAfter,
        dataExpected,
        debtToCover,
        txTimestamp
      );

      // check the results
      // liquidator & collateral
      if (_debugFlag) console.log('actionCrossLiquidateERC20', 'check: liquidator & collateral');
      checkAssetData(TestAction.CrossLiquidateERC20, dataAfter.assetData, dataExpected.assetData);
      checkUserAssetData(TestAction.CrossLiquidateERC20, dataAfter.userAssetData, dataExpected.userAssetData);

      // liquidator & debt
      if (_debugFlag) console.log('actionCrossLiquidateERC20', 'check: liquidator & debt');
      checkAssetData(TestAction.CrossLiquidateERC20, dataAfter.assetData2, dataExpected.assetData2);
      checkUserAssetData(TestAction.CrossLiquidateERC20, dataAfter.userAssetData2, dataExpected.userAssetData2);

      // borrower & collateral
      if (_debugFlag) console.log('actionCrossLiquidateERC20', 'check: borrower & collateral');
      checkUserAssetData(TestAction.CrossLiquidateERC20, dataAfter.userAssetData3, dataExpected.userAssetData3);

      // borrower & debt
      if (_debugFlag) console.log('actionCrossLiquidateERC20', 'check: borrower & debt');
      checkUserAssetData(TestAction.CrossLiquidateERC20, dataAfter.userAssetData4, dataExpected.userAssetData4);
    }
    if (_debugFlag) console.log('>>>>actionCrossLiquidateERC20', 'end');
  }

  function actionCrossLiquidateERC721(
    address sender,
    uint32 poolId,
    address borrower,
    address collateralAsset,
    uint256[] memory tokenIds,
    address debtAsset,
    bool supplyAsCollateral,
    bytes memory revertMessage
  ) internal {
    if (_debugFlag) console.log('<<<<actionCrossLiquidateERC721', 'begin');
    if (revertMessage.length > 0) {
      vm.expectRevert(revertMessage);
      tsHEVM.prank(sender);
      tsCrossLiquidation.crossLiquidateERC721(
        poolId,
        borrower,
        collateralAsset,
        tokenIds,
        debtAsset,
        supplyAsCollateral
      );
    } else {
      // fetch contract data
      // liquidator & collateral
      TestContractData memory dataBefore = getContractData(
        sender,
        poolId,
        collateralAsset,
        Constants.ASSET_TYPE_ERC721
      );

      // liquidator & debt
      dataBefore.assetData2 = getAssetData(poolId, debtAsset, Constants.ASSET_TYPE_ERC20);
      dataBefore.userAssetData2 = getUserAssetData(sender, poolId, debtAsset, Constants.ASSET_TYPE_ERC20);

      // borrower & collateral
      dataBefore.userAssetData3 = getUserAssetData(borrower, poolId, collateralAsset, Constants.ASSET_TYPE_ERC721);

      // borrower & debt
      dataBefore.userAssetData4 = getUserAssetData(borrower, poolId, debtAsset, Constants.ASSET_TYPE_ERC20);

      // send tx
      if (_debugFlag) console.log('actionCrossLiquidateERC721', 'sendtx');
      tsHEVM.prank(sender);
      tsCrossLiquidation.crossLiquidateERC721(
        poolId,
        borrower,
        collateralAsset,
        tokenIds,
        debtAsset,
        supplyAsCollateral
      );
      uint256 txTimestamp = block.timestamp;

      // fetch contract data
      // liquidator & collateral
      TestContractData memory dataAfter = getContractData(sender, poolId, collateralAsset, Constants.ASSET_TYPE_ERC721);

      // liquidator & debt
      dataAfter.assetData2 = getAssetData(poolId, debtAsset, Constants.ASSET_TYPE_ERC20);
      dataAfter.userAssetData2 = getUserAssetData(sender, poolId, debtAsset, Constants.ASSET_TYPE_ERC20);

      // borrower & collateral
      dataAfter.userAssetData3 = getUserAssetData(borrower, poolId, collateralAsset, Constants.ASSET_TYPE_ERC721);

      // borrower & debt
      dataAfter.userAssetData4 = getUserAssetData(borrower, poolId, debtAsset, Constants.ASSET_TYPE_ERC20);

      // calc expected data
      TestContractData memory dataExpected;

      uint256 colToLiq = tokenIds.length;
      uint256 debtToCover = calcExpectedDebtToCoverFromERC721(dataBefore.assetData, dataBefore.assetData2, colToLiq);

      calcExpectedCollateralAssetDataAfterCrossLiquidateERC721(
        dataBefore,
        dataAfter,
        dataExpected,
        colToLiq,
        txTimestamp
      );
      calcExpectedDebtAssetDataAfterCrossLiquidateERC721(dataBefore, dataAfter, dataExpected, debtToCover, txTimestamp);

      calcExpectedLiquidatorColUserDataAfterCrossLiquidateERC721(
        dataBefore,
        dataAfter,
        dataExpected,
        colToLiq,
        txTimestamp
      );
      calcExpectedLiquidatorDebtUserDataAfterCrossLiquidateERC721(
        dataBefore,
        dataAfter,
        dataExpected,
        debtToCover,
        txTimestamp
      );

      calcExpectedBorrowerColUserDataAfterCrossLiquidateERC721(
        dataBefore,
        dataAfter,
        dataExpected,
        colToLiq,
        txTimestamp
      );
      calcExpectedBorrowerDebtUserDataAfterCrossLiquidateERC721(
        dataBefore,
        dataAfter,
        dataExpected,
        debtToCover,
        txTimestamp
      );

      // check the results
      // liquidator & collateral
      if (_debugFlag) console.log('actionCrossLiquidateERC721', 'check: liquidator & collateral');
      checkAssetData(TestAction.CrossLiquidateERC721, dataAfter.assetData, dataExpected.assetData);
      checkUserAssetData(TestAction.CrossLiquidateERC721, dataAfter.userAssetData, dataExpected.userAssetData);

      // liquidator & debt
      if (_debugFlag) console.log('actionCrossLiquidateERC721', 'check: liquidator & debt');
      checkAssetData(TestAction.CrossLiquidateERC721, dataAfter.assetData2, dataExpected.assetData2);
      checkUserAssetData(TestAction.CrossLiquidateERC721, dataAfter.userAssetData2, dataExpected.userAssetData2);

      // borrower & collateral
      if (_debugFlag) console.log('actionCrossLiquidateERC721', 'check: borrower & collateral');
      checkUserAssetData(TestAction.CrossLiquidateERC721, dataAfter.userAssetData3, dataExpected.userAssetData3);

      // borrower & debt
      if (_debugFlag) console.log('actionCrossLiquidateERC721', 'check: borrower & debt');
      checkUserAssetData(TestAction.CrossLiquidateERC721, dataAfter.userAssetData4, dataExpected.userAssetData4);
    }
    if (_debugFlag) console.log('>>>>actionCrossLiquidateERC721', 'end');
  }

  /****************************************************************************/
  /* Calculations */
  /****************************************************************************/

  /* CrossBorrowERC20 */

  function calcExpectedAssetDataAfterCrossBorrowERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint8[] memory groups,
    uint256[] memory amounts,
    uint256 txTimestamp
  ) internal view {
    if (_debugFlag) console.log('calcExpectedAssetDataAfterCrossBorrowERC20', 'begin');
    TestAssetData memory expectedAssetData = copyAssetData(dataBefore.assetData);
    dataExpected.assetData = expectedAssetData;

    uint256 totalAmountBorrowed;
    for (uint256 i = 0; i < amounts.length; i++) {
      totalAmountBorrowed += amounts[i];
    }

    // index
    calcExpectedInterestIndexs(dataBefore.assetData, expectedAssetData, txTimestamp);

    // balances
    calcExpectedAssetBalances(dataExpected.assetData, dataExpected.assetData);

    // supply
    expectedAssetData.availableSupply = dataBefore.assetData.availableSupply - totalAmountBorrowed;

    // borrow
    expectedAssetData.totalCrossBorrow = dataBefore.assetData.totalCrossBorrow + totalAmountBorrowed;

    expectedAssetData.totalLiquidity =
      expectedAssetData.totalCrossBorrow +
      expectedAssetData.totalIsolateBorrow +
      expectedAssetData.availableSupply;
    expectedAssetData.utilizationRate = calcExpectedUtilizationRate(
      expectedAssetData.totalCrossBorrow + expectedAssetData.totalIsolateBorrow,
      expectedAssetData.totalLiquidity
    );

    for (uint256 i = 0; i < groups.length; i++) {
      TestGroupData memory expectedGroupData = expectedAssetData.groupsData[groups[i]];
      expectedGroupData.totalCrossBorrow += amounts[i];
    }

    // rate
    calcExpectedInterestRates(expectedAssetData);

    if (_debugFlag) console.log('calcExpectedAssetDataAfterCrossBorrowERC20', 'end');
  }

  function calcExpectedUserDataAfterCrossBorrowERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint8[] memory groups,
    uint256[] memory amounts,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedUserDataAfterCrossBorrowERC20', 'begin');
    TestUserAssetData memory expectedUserData = copyUserAssetData(dataBefore.userAssetData);
    dataExpected.userAssetData = expectedUserData;

    uint256 totalAmountBorrowed;
    for (uint256 i = 0; i < amounts.length; i++) {
      totalAmountBorrowed += amounts[i];
    }

    // balances
    calcExpectedUserAssetBalances(dataExpected.assetData, dataBefore.userAssetData, dataExpected.userAssetData);

    // wallet
    expectedUserData.walletBalance = dataBefore.userAssetData.walletBalance + totalAmountBorrowed;

    // supply

    // borrow
    expectedUserData.totalCrossBorrow = dataBefore.userAssetData.totalCrossBorrow + totalAmountBorrowed;

    for (uint256 i = 0; i < groups.length; i++) {
      TestUserGroupData memory expectedGroupData = expectedUserData.groupsData[groups[i]];
      expectedGroupData.totalCrossBorrow += amounts[i];
    }
    if (_debugFlag) console.log('calcExpectedUserDataAfterCrossBorrowERC20', 'end');
  }

  /* CrossRepayERC20 */

  function calcExpectedAssetDataAfterCrossRepayERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint8[] memory groups,
    uint256[] memory amounts,
    uint256 txTimestamp
  ) internal view {
    if (_debugFlag) console.log('calcExpectedAssetDataAfterCrossRepayERC20', 'begin');
    TestAssetData memory expectedAssetData = copyAssetData(dataBefore.assetData);
    dataExpected.assetData = expectedAssetData;

    uint256 totalAmountRepaid;
    for (uint256 i = 0; i < amounts.length; i++) {
      totalAmountRepaid += amounts[i];
    }

    // index
    calcExpectedInterestIndexs(dataBefore.assetData, expectedAssetData, txTimestamp);

    // balances
    calcExpectedAssetBalances(dataExpected.assetData, dataExpected.assetData);

    // supply
    expectedAssetData.availableSupply = dataBefore.assetData.availableSupply + totalAmountRepaid;

    // borrow
    expectedAssetData.totalCrossBorrow = dataBefore.assetData.totalCrossBorrow - totalAmountRepaid;

    expectedAssetData.totalLiquidity =
      expectedAssetData.totalCrossBorrow +
      expectedAssetData.totalIsolateBorrow +
      expectedAssetData.availableSupply;
    expectedAssetData.utilizationRate = calcExpectedUtilizationRate(
      expectedAssetData.totalCrossBorrow + expectedAssetData.totalIsolateBorrow,
      expectedAssetData.totalLiquidity
    );

    for (uint256 i = 0; i < groups.length; i++) {
      TestGroupData memory expectedGroupData = expectedAssetData.groupsData[groups[i]];
      expectedGroupData.totalCrossBorrow -= amounts[i];
    }

    // rate
    calcExpectedInterestRates(expectedAssetData);

    if (_debugFlag) console.log('calcExpectedAssetDataAfterCrossRepayERC20', 'end');
  }

  function calcExpectedUserDataAfterCrossRepayERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint8[] memory groups,
    uint256[] memory amounts,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedUserDataAfterRepayBorrowERC20', 'begin');
    TestUserAssetData memory expectedUserAssetData = copyUserAssetData(dataBefore.userAssetData);
    dataExpected.userAssetData = expectedUserAssetData;

    uint256 totalAmountRepaid;
    for (uint256 i = 0; i < amounts.length; i++) {
      totalAmountRepaid += amounts[i];
    }

    // balances
    calcExpectedUserAssetBalances(dataExpected.assetData, dataBefore.userAssetData, dataExpected.userAssetData);

    // wallet

    // supply
    expectedUserAssetData.walletBalance = dataBefore.userAssetData.walletBalance - totalAmountRepaid;

    // borrow
    for (uint256 i = 0; i < groups.length; i++) {
      TestGroupData memory expectedAssetGroupData = dataExpected.assetData.groupsData[groups[i]];
      TestUserGroupData memory expectedUserGroupData = expectedUserAssetData.groupsData[groups[i]];
      TestUserGroupData memory beforeUserGroupData = dataBefore.userAssetData.groupsData[groups[i]];

      expectedUserGroupData.totalCrossBorrow = calcExpectedTotalBorrow(
        beforeUserGroupData.totalScaledCrossBorrow,
        expectedAssetGroupData.borrowIndex
      );
      expectedUserGroupData.totalCrossBorrow -= amounts[i];
    }
    expectedUserAssetData.totalCrossBorrow = dataBefore.userAssetData.totalCrossBorrow - totalAmountRepaid;

    if (_debugFlag) console.log('calcExpectedUserDataAfterRepayBorrowERC20', 'end');
  }

  // CrossLiquidateERC20

  function calcExpectedCollateralFromDebtToCover(
    TestAssetData memory collateralAssetData,
    TestAssetData memory debtAssetData,
    TestUserAssetData memory borrowerAssetData,
    uint256 debtToCover
  ) internal view returns (uint256 colAmount) {
    uint256 colPrice = tsPriceOracle.getAssetPrice(collateralAssetData.asset);
    uint256 debtPrice = tsPriceOracle.getAssetPrice(debtAssetData.asset);

    colAmount =
      (debtToCover * debtPrice * (10 ** collateralAssetData.config.decimals)) /
      ((10 ** debtAssetData.config.decimals) * colPrice);
    colAmount = colAmount.percentMul(PercentageMath.PERCENTAGE_FACTOR + collateralAssetData.config.liquidationBonus);
    if (colAmount > borrowerAssetData.totalCrossSupply) {
      colAmount = borrowerAssetData.totalCrossSupply;
    }

    if (_debugFlag) console.log('calcExpectedCollateralERC20FromDebtToCover', colAmount);
  }

  function calcExpectedDebtToCoverFromERC20(
    TestAssetData memory collateralAssetData,
    TestAssetData memory debtAssetData,
    uint256 colAmount
  ) internal view returns (uint256 debtToCover) {
    uint256 colPrice = tsPriceOracle.getAssetPrice(collateralAssetData.asset);
    uint256 debtPrice = tsPriceOracle.getAssetPrice(debtAssetData.asset);

    debtToCover =
      (colAmount * colPrice * (10 ** debtAssetData.config.decimals)) /
      ((10 ** collateralAssetData.config.decimals) * debtPrice);
    debtToCover = debtToCover.percentDiv(
      PercentageMath.PERCENTAGE_FACTOR + collateralAssetData.config.liquidationBonus
    );

    if (_debugFlag) console.log('calcExpectedDebtToCoverFromERC20', debtToCover);
  }

  function calcExpectedCollateralAssetDataAfterCrossLiquidateERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 colToLiq,
    uint256 txTimestamp
  ) internal view {
    if (_debugFlag) console.log('calcExpectedCollateralAssetDataAfterCrossLiquidateERC20', 'begin');
    TestAssetData memory expectedAssetData = copyAssetData(dataBefore.assetData);
    dataExpected.assetData = expectedAssetData;

    // index
    calcExpectedInterestIndexs(dataBefore.assetData, expectedAssetData, txTimestamp);

    // balances
    calcExpectedAssetBalances(dataExpected.assetData, dataExpected.assetData);

    // supply
    expectedAssetData.totalCrossSupply = dataBefore.assetData.totalCrossSupply - colToLiq;
    expectedAssetData.availableSupply = dataBefore.assetData.availableSupply - colToLiq;

    // borrow

    expectedAssetData.totalLiquidity =
      expectedAssetData.totalCrossBorrow +
      expectedAssetData.totalIsolateBorrow +
      expectedAssetData.availableSupply;
    expectedAssetData.utilizationRate = calcExpectedUtilizationRate(
      expectedAssetData.totalCrossBorrow + expectedAssetData.totalIsolateBorrow,
      expectedAssetData.totalLiquidity
    );

    // rate
    calcExpectedInterestRates(expectedAssetData);

    if (_debugFlag) console.log('calcExpectedCollateralAssetDataAfterCrossLiquidateERC20', 'end');
  }

  function calcExpectedDebtAssetDataAfterCrossLiquidateERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 debtToCover,
    uint256 txTimestamp
  ) internal view {
    if (_debugFlag) console.log('calcExpectedDebtAssetDataAfterCrossLiquidateERC20', 'begin');
    TestAssetData memory expectedAssetData = copyAssetData(dataBefore.assetData2);
    dataExpected.assetData2 = expectedAssetData;

    // index
    calcExpectedInterestIndexs(dataBefore.assetData2, expectedAssetData, txTimestamp);

    // balances
    calcExpectedAssetBalances(dataExpected.assetData2, dataExpected.assetData2);

    // supply
    expectedAssetData.availableSupply = dataBefore.assetData2.availableSupply + debtToCover;

    // borrow
    expectedAssetData.totalCrossBorrow = dataBefore.assetData2.totalCrossBorrow - debtToCover;

    expectedAssetData.totalLiquidity =
      expectedAssetData.totalCrossBorrow +
      expectedAssetData.totalIsolateBorrow +
      expectedAssetData.availableSupply;
    expectedAssetData.utilizationRate = calcExpectedUtilizationRate(
      expectedAssetData.totalCrossBorrow + expectedAssetData.totalIsolateBorrow,
      expectedAssetData.totalLiquidity
    );

    uint8[] memory sortedGroupIds = sortGroupIdByRates(dataBefore.assetData2);
    uint256 remainDebt = debtToCover;
    for (uint256 i = 0; i < sortedGroupIds.length; i++) {
      TestGroupData memory expectedGroupData = expectedAssetData.groupsData[sortedGroupIds[i]];
      if (expectedGroupData.totalCrossBorrow > remainDebt) {
        expectedGroupData.totalCrossBorrow -= remainDebt;
        remainDebt = 0;
      } else {
        remainDebt -= expectedGroupData.totalCrossBorrow;
        expectedGroupData.totalCrossBorrow = 0;
      }

      if (remainDebt == 0) {
        break;
      }
    }

    // rate
    calcExpectedInterestRates(expectedAssetData);

    if (_debugFlag) console.log('calcExpectedDebtAssetDataAfterCrossLiquidateERC20', 'end');
  }

  function calcExpectedLiquidatorColUserDataAfterCrossLiquidateERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 colToLiq,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedCollateralUserDataAfterCrossLiquidateERC20', 'begin');
    TestUserAssetData memory expectedUserAssetData = copyUserAssetData(dataBefore.userAssetData);
    dataExpected.userAssetData = expectedUserAssetData;

    // balances
    calcExpectedUserAssetBalances(dataExpected.assetData, dataBefore.userAssetData, dataExpected.userAssetData);

    // wallet
    expectedUserAssetData.walletBalance = dataBefore.userAssetData.walletBalance + colToLiq;

    // supply

    // borrow

    if (_debugFlag) console.log('calcExpectedCollateralUserDataAfterCrossLiquidateERC20', 'end');
  }

  function calcExpectedLiquidatorDebtUserDataAfterCrossLiquidateERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 debtToCover,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedDebtUserDataAfterCrossLiquidateERC20', 'begin');
    TestUserAssetData memory expectedUserAssetData = copyUserAssetData(dataBefore.userAssetData2);
    dataExpected.userAssetData2 = expectedUserAssetData;

    // balances
    calcExpectedUserAssetBalances(dataExpected.assetData, dataBefore.userAssetData, dataExpected.userAssetData);

    // wallet
    expectedUserAssetData.walletBalance = dataBefore.userAssetData2.walletBalance - debtToCover;

    // supply

    // borrow

    if (_debugFlag) console.log('calcExpectedDebtUserDataAfterCrossLiquidateERC20', 'end');
  }

  function calcExpectedBorrowerColUserDataAfterCrossLiquidateERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 colToLiq,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedBorrowerColUserDataAfterCrossLiquidateERC20', 'begin');
    TestUserAssetData memory expectedUserAssetData = copyUserAssetData(dataBefore.userAssetData3);
    dataExpected.userAssetData3 = expectedUserAssetData;

    // balances
    calcExpectedUserAssetBalances(dataExpected.assetData, dataBefore.userAssetData, dataExpected.userAssetData);

    // wallet

    // supply
    expectedUserAssetData.totalCrossSupply = dataBefore.userAssetData3.totalCrossSupply - colToLiq;

    // borrow

    if (_debugFlag) console.log('calcExpectedBorrowerColUserDataAfterCrossLiquidateERC20', 'end');
  }

  function calcExpectedBorrowerDebtUserDataAfterCrossLiquidateERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 debtToCover,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedBorrowerDebtUserDataAfterCrossLiquidateERC20', 'begin');
    TestUserAssetData memory expectedUserAssetData = copyUserAssetData(dataBefore.userAssetData4);
    dataExpected.userAssetData4 = expectedUserAssetData;

    // balances
    calcExpectedUserAssetBalances(dataExpected.assetData, dataBefore.userAssetData, dataExpected.userAssetData);

    // wallet

    // supply

    // borrow
    expectedUserAssetData.totalCrossBorrow = dataBefore.userAssetData4.totalCrossBorrow - debtToCover;

    uint8[] memory sortedGroupIds = sortGroupIdByRates(dataBefore.assetData2);
    uint256 remainDebt = debtToCover;
    for (uint256 i = 0; i < sortedGroupIds.length; i++) {
      TestUserGroupData memory expectedGroupData = expectedUserAssetData.groupsData[sortedGroupIds[i]];
      if (expectedGroupData.totalCrossBorrow == 0) {
        continue;
      }

      if (expectedGroupData.totalCrossBorrow > remainDebt) {
        expectedGroupData.totalCrossBorrow -= remainDebt;
        remainDebt = 0;
      } else {
        remainDebt -= expectedGroupData.totalCrossBorrow;
        expectedGroupData.totalCrossBorrow = 0;
      }

      if (remainDebt == 0) {
        break;
      }
    }

    if (_debugFlag) console.log('calcExpectedBorrowerDebtUserDataAfterCrossLiquidateERC20', 'end');
  }

  // CrossLiquidateERC721

  function calcExpectedDebtToCoverFromERC721(
    TestAssetData memory collateralAssetData,
    TestAssetData memory debtAssetData,
    uint256 colAmount
  ) internal view returns (uint256 debtToCover) {
    uint256 colPrice = tsPriceOracle.getAssetPrice(collateralAssetData.asset);
    uint256 debtPrice = tsPriceOracle.getAssetPrice(debtAssetData.asset);

    colPrice = colPrice.percentMul(PercentageMath.PERCENTAGE_FACTOR - collateralAssetData.config.liquidationBonus);

    // no decimals for erc721
    debtToCover = (colAmount * colPrice * (10 ** debtAssetData.config.decimals)) / (debtPrice);

    if (_debugFlag) console.log('calcExpectedDebtToCoverFromERC721', debtToCover);
  }

  function calcExpectedCollateralAssetDataAfterCrossLiquidateERC721(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 colToLiq,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedCollateralAssetDataAfterCrossLiquidateERC721', 'begin');
    TestAssetData memory expectedAssetData = copyAssetData(dataBefore.assetData);
    dataExpected.assetData = expectedAssetData;

    // index, no need for erc721

    // supply
    expectedAssetData.totalCrossSupply = dataBefore.assetData.totalCrossSupply - colToLiq;
    expectedAssetData.availableSupply = dataBefore.assetData.availableSupply - colToLiq;

    // borrow

    // rate, no need for erc721

    if (_debugFlag) console.log('calcExpectedCollateralAssetDataAfterCrossLiquidateERC721', 'end');
  }

  function calcExpectedDebtAssetDataAfterCrossLiquidateERC721(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 debtToCover,
    uint256 txTimestamp
  ) internal view {
    if (_debugFlag) console.log('calcExpectedDebtAssetDataAfterCrossLiquidateERC721', 'begin');
    TestAssetData memory expectedAssetData = copyAssetData(dataBefore.assetData2);
    dataExpected.assetData2 = expectedAssetData;

    // index
    calcExpectedInterestIndexs(dataBefore.assetData2, expectedAssetData, txTimestamp);

    // balances
    calcExpectedAssetBalances(dataExpected.assetData2, dataExpected.assetData2);

    // supply
    expectedAssetData.availableSupply = dataBefore.assetData2.availableSupply + debtToCover;

    // borrow
    expectedAssetData.totalCrossBorrow = 0;

    uint8[] memory sortedGroupIds = sortGroupIdByRates(dataBefore.assetData2);
    uint256 remainDebt = debtToCover;
    for (uint256 i = 0; i < sortedGroupIds.length; i++) {
      TestGroupData memory expectedGroupData = expectedAssetData.groupsData[sortedGroupIds[i]];
      if (expectedGroupData.totalScaledCrossBorrow == 0) {
        continue;
      }
      uint256 totalBorrow = expectedGroupData.totalScaledCrossBorrow.rayMul(expectedGroupData.borrowIndex);
      uint256 curRepayAmount;
      if (totalBorrow > remainDebt) {
        curRepayAmount = remainDebt;
        remainDebt = 0;
      } else {
        curRepayAmount = totalBorrow;
        remainDebt -= curRepayAmount;
      }
      expectedGroupData.totalScaledCrossBorrow -= curRepayAmount.rayDiv(expectedGroupData.borrowIndex);
      expectedGroupData.totalCrossBorrow = expectedGroupData.totalScaledCrossBorrow.rayMul(
        expectedGroupData.borrowIndex
      );

      expectedAssetData.totalCrossBorrow += expectedGroupData.totalCrossBorrow;

      if (remainDebt == 0) {
        break;
      }
    }

    expectedAssetData.totalLiquidity =
      expectedAssetData.totalCrossBorrow +
      expectedAssetData.totalIsolateBorrow +
      expectedAssetData.availableSupply;

    expectedAssetData.utilizationRate = calcExpectedUtilizationRate(
      expectedAssetData.totalCrossBorrow + expectedAssetData.totalIsolateBorrow,
      expectedAssetData.totalLiquidity
    );

    // rate
    calcExpectedInterestRates(expectedAssetData);

    if (_debugFlag) console.log('calcExpectedDebtAssetDataAfterCrossLiquidateERC721', 'end');
  }

  function calcExpectedLiquidatorColUserDataAfterCrossLiquidateERC721(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 colToLiq,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedLiquidatorColUserDataAfterCrossLiquidateERC721', 'begin');
    TestUserAssetData memory expectedUserAssetData = copyUserAssetData(dataBefore.userAssetData);
    dataExpected.userAssetData = expectedUserAssetData;

    // balances

    // wallet
    expectedUserAssetData.walletBalance = dataBefore.userAssetData.walletBalance + colToLiq;

    // supply

    // borrow

    if (_debugFlag) console.log('calcExpectedLiquidatorColUserDataAfterCrossLiquidateERC721', 'end');
  }

  function calcExpectedLiquidatorDebtUserDataAfterCrossLiquidateERC721(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 debtToCover,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedLiquidatorDebtUserDataAfterCrossLiquidateERC721', 'begin');
    TestUserAssetData memory expectedUserAssetData = copyUserAssetData(dataBefore.userAssetData2);
    dataExpected.userAssetData2 = expectedUserAssetData;

    // balances
    calcExpectedUserAssetBalances(dataExpected.assetData2, dataBefore.userAssetData2, dataExpected.userAssetData2);

    // wallet
    expectedUserAssetData.walletBalance = dataBefore.userAssetData2.walletBalance - debtToCover;

    // supply

    // borrow

    if (_debugFlag) console.log('calcExpectedLiquidatorDebtUserDataAfterCrossLiquidateERC721', 'end');
  }

  function calcExpectedBorrowerColUserDataAfterCrossLiquidateERC721(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 colToLiq,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedBorrowerColUserDataAfterCrossLiquidateERC721', 'begin');
    TestUserAssetData memory expectedUserAssetData = copyUserAssetData(dataBefore.userAssetData3);
    dataExpected.userAssetData3 = expectedUserAssetData;

    // balances

    // wallet

    // supply
    expectedUserAssetData.totalCrossSupply = dataBefore.userAssetData3.totalCrossSupply - colToLiq;

    // borrow

    if (_debugFlag) console.log('calcExpectedBorrowerColUserDataAfterCrossLiquidateERC721', 'end');
  }

  function calcExpectedBorrowerDebtUserDataAfterCrossLiquidateERC721(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 debtToCover,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedBorrowerDebtUserDataAfterCrossLiquidateERC721', 'begin');
    TestUserAssetData memory expectedUserAssetData = copyUserAssetData(dataBefore.userAssetData4);
    dataExpected.userAssetData4 = expectedUserAssetData;

    // balances
    calcExpectedUserAssetBalances(dataExpected.assetData2, dataBefore.userAssetData4, dataExpected.userAssetData4);

    // wallet

    // supply

    // borrow
    expectedUserAssetData.totalCrossBorrow = 0;

    uint8[] memory sortedGroupIds = sortGroupIdByRates(dataBefore.assetData2);
    uint256 remainDebt = debtToCover;
    for (uint256 i = 0; i < sortedGroupIds.length; i++) {
      TestGroupData memory expectedGroupData = dataExpected.assetData2.groupsData[sortedGroupIds[i]];
      TestUserGroupData memory expectedUserGroupData = expectedUserAssetData.groupsData[sortedGroupIds[i]];
      if (expectedUserGroupData.totalScaledCrossBorrow == 0) {
        continue;
      }

      uint256 totalBorrow = expectedUserGroupData.totalScaledCrossBorrow.rayMul(expectedGroupData.borrowIndex);
      uint256 curRepayAmount;
      if (totalBorrow > remainDebt) {
        curRepayAmount = remainDebt;
        remainDebt = 0;
      } else {
        curRepayAmount = totalBorrow;
        remainDebt -= curRepayAmount;
      }
      expectedUserGroupData.totalScaledCrossBorrow -= curRepayAmount.rayDiv(expectedGroupData.borrowIndex);
      expectedUserGroupData.totalCrossBorrow = expectedUserGroupData.totalScaledCrossBorrow.rayMul(
        expectedGroupData.borrowIndex
      );

      expectedUserAssetData.totalCrossBorrow += expectedUserGroupData.totalCrossBorrow;

      if (remainDebt == 0) {
        break;
      }
    }

    // excessive debt supplied as new collateral to borrower
    expectedUserAssetData.totalCrossSupply = dataBefore.userAssetData4.totalCrossSupply + remainDebt;

    if (_debugFlag) console.log('calcExpectedBorrowerDebtUserDataAfterCrossLiquidateERC721', 'end');
  }

  /****************************************************************************/
  /* Helpers for Calculations */
  /****************************************************************************/
}
