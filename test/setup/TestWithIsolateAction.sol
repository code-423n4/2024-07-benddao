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

abstract contract TestWithIsolateAction is TestWithBaseAction {
  using WadRayMath for uint256;
  using PercentageMath for uint256;

  function onSetUp() public virtual override {
    super.onSetUp();
  }

  /****************************************************************************/
  /* Actions */
  /****************************************************************************/

  // Isolate Lending

  function actionIsolateBorrow(
    address sender,
    uint32 poolId,
    address nftAsset,
    uint256[] memory nftTokenIds,
    address debtAsset,
    uint256[] memory amounts,
    bytes memory revertMessage
  ) internal {
    if (_debugFlag) console.log('<<<<actionIsolateBorrow', 'begin');
    if (revertMessage.length > 0) {
      vm.expectRevert(revertMessage);
      tsHEVM.prank(sender);
      tsIsolateLending.isolateBorrow(poolId, nftAsset, nftTokenIds, debtAsset, amounts, sender, sender);
    } else {
      // fetch contract data
      TestContractData memory dataBefore = getContractData(sender, poolId, nftAsset, Constants.ASSET_TYPE_ERC721);
      dataBefore.loansData = getIsolateLoanData(poolId, nftAsset, nftTokenIds);

      dataBefore.assetData2 = getAssetData(poolId, debtAsset, Constants.ASSET_TYPE_ERC20);
      dataBefore.userAssetData2 = getUserAssetData(sender, poolId, debtAsset, Constants.ASSET_TYPE_ERC20);

      // send tx
      if (_debugFlag) console.log('actionIsolateBorrow', 'sendtx');
      tsHEVM.prank(sender);
      tsIsolateLending.isolateBorrow(poolId, nftAsset, nftTokenIds, debtAsset, amounts, sender, sender);
      uint256 txTimestamp = block.timestamp;

      // fetch contract data
      TestContractData memory dataAfter = getContractData(sender, poolId, nftAsset, Constants.ASSET_TYPE_ERC721);
      dataAfter.loansData = getIsolateLoanData(poolId, nftAsset, nftTokenIds);

      dataAfter.assetData2 = getAssetData(poolId, debtAsset, Constants.ASSET_TYPE_ERC20);
      dataAfter.userAssetData2 = getUserAssetData(sender, poolId, debtAsset, Constants.ASSET_TYPE_ERC20);

      // calc expected data
      TestContractData memory dataExpected;
      calcExpectedNftAssetDataAfterIsolateBorrow(
        dataBefore,
        dataAfter,
        dataExpected,
        nftTokenIds,
        amounts,
        txTimestamp
      );
      calcExpectedDebtAssetDataAfterIsolateBorrow(
        dataBefore,
        dataAfter,
        dataExpected,
        nftTokenIds,
        amounts,
        txTimestamp
      );

      calcExpectedNftUserDataAfterIsolateBorrow(dataBefore, dataAfter, dataExpected, nftTokenIds, amounts, txTimestamp);
      calcExpectedDebtUserDataAfterIsolateBorrow(
        dataBefore,
        dataAfter,
        dataExpected,
        nftTokenIds,
        amounts,
        txTimestamp
      );

      calcExpectedLoanDataAfterIsolateBorrow(dataBefore, dataAfter, dataExpected, nftTokenIds, amounts, txTimestamp);

      // check the results
      if (_debugFlag) console.log('actionIsolateBorrow', 'check borrower & nft');
      checkAssetData(TestAction.IsolateBorrow, dataAfter.assetData, dataExpected.assetData);
      checkUserAssetData(TestAction.IsolateBorrow, dataAfter.userAssetData, dataExpected.userAssetData);

      if (_debugFlag) console.log('actionIsolateBorrow', 'check borrower & debt');
      checkAssetData(TestAction.IsolateBorrow, dataAfter.assetData2, dataExpected.assetData2);
      checkUserAssetData(TestAction.IsolateBorrow, dataAfter.userAssetData2, dataExpected.userAssetData2);

      checkLoanData(TestAction.IsolateBorrow, dataAfter.loansData, dataExpected.loansData);
    }
    if (_debugFlag) console.log('>>>>actionIsolateBorrow', 'end');
  }

  function actionIsolateRepay(
    address sender,
    uint32 poolId,
    address nftAsset,
    uint256[] memory nftTokenIds,
    address debtAsset,
    uint256[] memory amounts,
    bytes memory revertMessage
  ) internal {
    if (_debugFlag) console.log('<<<<actionIsolateRepay', 'begin');
    if (revertMessage.length > 0) {
      vm.expectRevert(revertMessage);
      tsHEVM.prank(sender);
      tsIsolateLending.isolateRepay(poolId, nftAsset, nftTokenIds, debtAsset, amounts, sender);
    } else {
      // fetch contract data
      TestContractData memory dataBefore = getContractData(sender, poolId, nftAsset, Constants.ASSET_TYPE_ERC721);
      dataBefore.loansData = getIsolateLoanData(poolId, nftAsset, nftTokenIds);

      dataBefore.assetData2 = getAssetData(poolId, debtAsset, Constants.ASSET_TYPE_ERC20);
      dataBefore.userAssetData2 = getUserAssetData(sender, poolId, debtAsset, Constants.ASSET_TYPE_ERC20);

      // send tx
      if (_debugFlag) console.log('actionIsolateRepay', 'sendtx');
      tsHEVM.prank(sender);
      tsIsolateLending.isolateRepay(poolId, nftAsset, nftTokenIds, debtAsset, amounts, sender);
      uint256 txTimestamp = block.timestamp;

      // fetch contract data
      TestContractData memory dataAfter = getContractData(sender, poolId, nftAsset, Constants.ASSET_TYPE_ERC721);
      dataAfter.loansData = getIsolateLoanData(poolId, nftAsset, nftTokenIds);

      dataAfter.assetData2 = getAssetData(poolId, debtAsset, Constants.ASSET_TYPE_ERC20);
      dataAfter.userAssetData2 = getUserAssetData(sender, poolId, debtAsset, Constants.ASSET_TYPE_ERC20);

      // calc expected data
      TestContractData memory dataExpected;
      calcExpectedNftAssetDataAfterIsolateRepay(dataBefore, dataAfter, dataExpected, nftTokenIds, amounts, txTimestamp);
      calcExpectedDebtAssetDataAfterIsolateRepay(
        dataBefore,
        dataAfter,
        dataExpected,
        nftTokenIds,
        amounts,
        txTimestamp
      );

      calcExpectedNftUserDataAfterIsolateRepay(dataBefore, dataAfter, dataExpected, nftTokenIds, amounts, txTimestamp);
      calcExpectedDebtUserDataAfterIsolateRepay(dataBefore, dataAfter, dataExpected, nftTokenIds, amounts, txTimestamp);

      calcExpectedLoanDataAfterIsolateRepay(dataBefore, dataAfter, dataExpected, nftTokenIds, amounts, txTimestamp);

      // check the results
      if (_debugFlag) console.log('actionIsolateRepay', 'check borrower & nft');
      checkAssetData(TestAction.IsolateBorrow, dataAfter.assetData, dataExpected.assetData);
      checkUserAssetData(TestAction.IsolateBorrow, dataAfter.userAssetData, dataExpected.userAssetData);

      if (_debugFlag) console.log('actionIsolateRepay', 'check borrower & debt');
      checkAssetData(TestAction.IsolateBorrow, dataAfter.assetData2, dataExpected.assetData2);
      checkUserAssetData(TestAction.IsolateBorrow, dataAfter.userAssetData2, dataExpected.userAssetData2);

      checkLoanData(TestAction.IsolateBorrow, dataAfter.loansData, dataExpected.loansData);
    }
    if (_debugFlag) console.log('>>>>actionIsolateRepay', 'end');
  }

  /****************************************************************************/
  /* Calculations */
  /****************************************************************************/

  /* IsolateBorrow */

  function calcExpectedLoanDataAfterIsolateBorrow(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256[] memory tokenIds,
    uint256[] memory amounts,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedLoanDataAfterIsolateBorrow', 'begin');
    TestLoanData[] memory expectedLoansData = copyLoanData(dataBefore.loansData);
    dataExpected.loansData = expectedLoansData;

    TestGroupData memory groupData = dataBefore.assetData2.groupsData[dataBefore.assetData.config.classGroup];

    for (uint256 i = 0; i < tokenIds.length; i++) {
      if (_debugFlag) console.log('calcExpectedLoanDataAfterIsolateBorrow-loan', tokenIds[i]);

      expectedLoansData[i].loanStatus = Constants.LOAN_STATUS_ACTIVE;
      expectedLoansData[i].reserveAsset = dataBefore.assetData2.asset;
      expectedLoansData[i].reserveGroup = dataBefore.assetData2.config.classGroup;

      expectedLoansData[i].scaledAmount =
        dataBefore.loansData[i].scaledAmount +
        amounts[i].rayDiv(groupData.borrowIndex);
      expectedLoansData[i].borrowAmount =
        dataBefore.loansData[i].scaledAmount.rayMul(groupData.borrowIndex) +
        amounts[i];
    }

    if (_debugFlag) console.log('calcExpectedLoanDataAfterIsolateBorrow', 'end');
  }

  function calcExpectedNftAssetDataAfterIsolateBorrow(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256[] memory /*tokenIds*/,
    uint256[] memory /*amounts*/,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedNftAssetDataAfterIsolateBorrow', 'begin');

    TestAssetData memory beforeAssetData = dataBefore.assetData;
    TestAssetData memory expectedAssetData = copyAssetData(beforeAssetData);
    dataExpected.assetData = expectedAssetData;

    // nothing need to update for the nft asset

    if (_debugFlag) console.log('calcExpectedNftAssetDataAfterIsolateBorrow', 'end');
  }

  function calcExpectedDebtAssetDataAfterIsolateBorrow(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256[] memory /*tokenIds*/,
    uint256[] memory amounts,
    uint256 txTimestamp
  ) internal view {
    if (_debugFlag) console.log('calcExpectedDebtAssetDataAfterIsolateBorrow', 'begin');

    TestAssetData memory beforeAssetData = dataBefore.assetData2;
    TestAssetData memory expectedAssetData = copyAssetData(beforeAssetData);
    dataExpected.assetData2 = expectedAssetData;

    uint256 totalAmountBorrowed;
    for (uint256 i = 0; i < amounts.length; i++) {
      totalAmountBorrowed += amounts[i];
    }

    // index
    calcExpectedInterestIndexs(beforeAssetData, expectedAssetData, txTimestamp);

    // balances
    calcExpectedAssetBalances(beforeAssetData, expectedAssetData);

    // supply
    expectedAssetData.availableSupply = beforeAssetData.availableSupply - totalAmountBorrowed;

    // borrow
    expectedAssetData.totalIsolateBorrow = expectedAssetData.totalIsolateBorrow + totalAmountBorrowed;

    expectedAssetData.totalLiquidity =
      expectedAssetData.totalCrossBorrow +
      expectedAssetData.totalIsolateBorrow +
      expectedAssetData.availableSupply;
    expectedAssetData.utilizationRate = calcExpectedUtilizationRate(
      expectedAssetData.totalCrossBorrow + expectedAssetData.totalIsolateBorrow,
      expectedAssetData.totalLiquidity
    );

    TestGroupData memory expectedGroupData = expectedAssetData.groupsData[beforeAssetData.config.classGroup];
    expectedGroupData.totalIsolateBorrow = expectedGroupData.totalIsolateBorrow + totalAmountBorrowed;

    // rate
    calcExpectedInterestRates(expectedAssetData);

    if (_debugFlag) console.log('calcExpectedDebtAssetDataAfterIsolateBorrow', 'end');
  }

  function calcExpectedNftUserDataAfterIsolateBorrow(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256[] memory /*tokenIds*/,
    uint256[] memory /*amounts*/,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedNftUserDataAfterIsolateBorrow', 'begin');
    TestUserAssetData memory expectedUserData = copyUserAssetData(dataBefore.userAssetData);
    dataExpected.userAssetData = expectedUserData;

    // nothing need to update for the nft asset

    if (_debugFlag) console.log('calcExpectedNftUserDataAfterIsolateBorrow', 'end');
  }

  function calcExpectedDebtUserDataAfterIsolateBorrow(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256[] memory /*tokenIds*/,
    uint256[] memory amounts,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedDebtUserDataAfterIsolateBorrow', 'begin');
    TestUserAssetData memory beforeUserData = dataBefore.userAssetData2;
    TestUserAssetData memory expectedUserData = copyUserAssetData(beforeUserData);
    dataExpected.userAssetData2 = expectedUserData;

    uint256 totalAmountBorrowed;
    for (uint256 i = 0; i < amounts.length; i++) {
      totalAmountBorrowed += amounts[i];
    }

    // balances
    calcExpectedUserAssetBalances(dataExpected.assetData2, beforeUserData, expectedUserData);

    // wallet
    expectedUserData.walletBalance = beforeUserData.walletBalance + totalAmountBorrowed;

    // supply

    // borrow
    expectedUserData.totalIsolateBorrow = expectedUserData.totalIsolateBorrow + totalAmountBorrowed;

    TestUserGroupData memory expectedGroupData = expectedUserData.groupsData[dataBefore.assetData2.config.classGroup];
    expectedGroupData.totalIsolateBorrow = expectedGroupData.totalIsolateBorrow + totalAmountBorrowed;

    if (_debugFlag) console.log('calcExpectedDebtUserDataAfterIsolateBorrow', 'end');
  }

  /* IsolateRepay */

  function calcExpectedLoanDataAfterIsolateRepay(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256[] memory tokenIds,
    uint256[] memory amounts,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedLoanDataAfterIsolateRepay', 'begin');
    TestLoanData[] memory expectedLoansData = copyLoanData(dataBefore.loansData);
    dataExpected.loansData = expectedLoansData;

    TestGroupData memory expectedGroupData = dataExpected.assetData2.groupsData[dataBefore.assetData.config.classGroup];

    for (uint256 i = 0; i < tokenIds.length; i++) {
      if (_debugFlag) console.log('calcExpectedLoanDataAfterIsolateRepay-loan', tokenIds[i]);

      expectedLoansData[i].loanStatus = Constants.LOAN_STATUS_ACTIVE;
      expectedLoansData[i].reserveAsset = dataBefore.assetData2.asset;
      expectedLoansData[i].reserveGroup = dataBefore.assetData2.config.classGroup;

      expectedLoansData[i].scaledAmount =
        dataBefore.loansData[i].scaledAmount -
        amounts[i].rayDiv(expectedGroupData.borrowIndex);
      expectedLoansData[i].borrowAmount =
        dataBefore.loansData[i].scaledAmount.rayMul(expectedGroupData.borrowIndex) -
        amounts[i];

      if (expectedLoansData[i].scaledAmount == 0) {
        expectedLoansData[i].loanStatus = 0;
        expectedLoansData[i].reserveAsset = address(0);
        expectedLoansData[i].reserveGroup = 0;
      }
    }

    if (_debugFlag) console.log('calcExpectedLoanDataAfterIsolateRepay', 'end');
  }

  function calcExpectedNftAssetDataAfterIsolateRepay(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256[] memory /*tokenIds*/,
    uint256[] memory /*amounts*/,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedNftAssetDataAfterIsolateRepay', 'begin');

    TestAssetData memory beforeAssetData = dataBefore.assetData;
    TestAssetData memory expectedAssetData = copyAssetData(beforeAssetData);
    dataExpected.assetData = expectedAssetData;

    // nothing need to update for the nft asset

    if (_debugFlag) console.log('calcExpectedNftAssetDataAfterIsolateRepay', 'end');
  }

  function calcExpectedDebtAssetDataAfterIsolateRepay(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256[] memory /*tokenIds*/,
    uint256[] memory amounts,
    uint256 txTimestamp
  ) internal view {
    if (_debugFlag) console.log('calcExpectedDebtAssetDataAfterIsolateRepay', 'begin');

    TestAssetData memory beforeAssetData = dataBefore.assetData2;
    TestAssetData memory expectedAssetData = copyAssetData(beforeAssetData);
    dataExpected.assetData2 = expectedAssetData;

    uint256 totalAmountRepaid;
    for (uint256 i = 0; i < amounts.length; i++) {
      totalAmountRepaid += amounts[i];
    }

    // index
    calcExpectedInterestIndexs(beforeAssetData, expectedAssetData, txTimestamp);

    // balances
    calcExpectedAssetBalances(beforeAssetData, expectedAssetData);

    // supply
    expectedAssetData.availableSupply = beforeAssetData.availableSupply + totalAmountRepaid;

    // borrow
    expectedAssetData.totalIsolateBorrow = approxMinus(expectedAssetData.totalIsolateBorrow, totalAmountRepaid, 1);

    expectedAssetData.totalLiquidity =
      expectedAssetData.totalCrossBorrow +
      expectedAssetData.totalIsolateBorrow +
      expectedAssetData.availableSupply;
    expectedAssetData.utilizationRate = calcExpectedUtilizationRate(
      expectedAssetData.totalCrossBorrow + expectedAssetData.totalIsolateBorrow,
      expectedAssetData.totalLiquidity
    );

    TestGroupData memory expectedGroupData = expectedAssetData.groupsData[beforeAssetData.config.classGroup];
    expectedGroupData.totalIsolateBorrow = approxMinus(expectedGroupData.totalIsolateBorrow, totalAmountRepaid, 1);

    // rate
    calcExpectedInterestRates(expectedAssetData);

    if (_debugFlag) console.log('calcExpectedDebtAssetDataAfterIsolateRepay', 'end');
  }

  function calcExpectedNftUserDataAfterIsolateRepay(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256[] memory /*tokenIds*/,
    uint256[] memory /*amounts*/,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedNftUserDataAfterIsolateRepay', 'begin');
    TestUserAssetData memory expectedUserData = copyUserAssetData(dataBefore.userAssetData);
    dataExpected.userAssetData = expectedUserData;

    // nothing need to update for the nft asset

    if (_debugFlag) console.log('calcExpectedNftUserDataAfterIsolateRepay', 'end');
  }

  function calcExpectedDebtUserDataAfterIsolateRepay(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256[] memory /*tokenIds*/,
    uint256[] memory amounts,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedDebtUserDataAfterIsolateRepay', 'begin');
    TestUserAssetData memory beforeUserData = dataBefore.userAssetData2;
    TestUserAssetData memory expectedUserData = copyUserAssetData(beforeUserData);
    dataExpected.userAssetData2 = expectedUserData;

    uint256 totalAmountRepaid;
    for (uint256 i = 0; i < amounts.length; i++) {
      totalAmountRepaid += amounts[i];
    }

    // balances
    calcExpectedUserAssetBalances(dataExpected.assetData2, beforeUserData, expectedUserData);

    // wallet
    expectedUserData.walletBalance = beforeUserData.walletBalance - totalAmountRepaid;

    // supply

    // borrow
    expectedUserData.totalIsolateBorrow = approxMinus(expectedUserData.totalIsolateBorrow, totalAmountRepaid, 1);

    TestUserGroupData memory expectedGroupData = expectedUserData.groupsData[dataBefore.assetData2.config.classGroup];
    expectedGroupData.totalIsolateBorrow = approxMinus(expectedGroupData.totalIsolateBorrow, totalAmountRepaid, 1);

    if (_debugFlag) console.log('calcExpectedDebtUserDataAfterIsolateRepay', 'end');
  }

  /****************************************************************************/
  /* Helpers for Calculations */
  /****************************************************************************/
}
