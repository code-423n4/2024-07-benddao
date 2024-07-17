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

import {TestWithPrepare} from './TestWithPrepare.sol';

import '@forge-std/Test.sol';

abstract contract TestWithBaseAction is TestWithPrepare {
  using WadRayMath for uint256;
  using PercentageMath for uint256;

  enum TestAction {
    DepositERC20,
    WithdrawERC20,
    DepositERC721,
    WithdrawERC721,
    CrossBorrowERC20,
    CrossRepayERC20,
    CrossLiquidateERC20,
    CrossLiquidateERC721,
    IsolateBorrow,
    IsolateRepay,
    IsolateAuction,
    IsolateRedeem,
    IsolateLiquidate
  }

  function onSetUp() public virtual override {
    super.onSetUp();
  }

  /****************************************************************************/
  /* Actions */
  /****************************************************************************/

  function actionSetNftPrice(address nftAsset, uint256 percentage) internal {
    uint256 oldPrice = tsBendNFTOracle.getAssetPrice(nftAsset);
    uint256 newPrice = (oldPrice * percentage) / 1e4;
    tsBendNFTOracle.setAssetPrice(nftAsset, newPrice);
  }

  // Supply

  function actionDepositERC20(
    address sender,
    uint32 poolId,
    address asset,
    uint256 amount,
    bytes memory revertMessage
  ) internal {
    if (_debugFlag) console.log('<<<<actionDepositERC20', 'begin');
    if (revertMessage.length > 0) {
      tsHEVM.expectRevert(revertMessage);
      tsHEVM.prank(sender);
      tsBVault.depositERC20(poolId, asset, amount, sender);
    } else {
      // fetch contract data
      TestContractData memory dataBefore = getContractData(sender, poolId, asset, Constants.ASSET_TYPE_ERC20);

      // send tx
      if (_debugFlag) console.log('actionDepositERC20', 'sendtx');
      tsHEVM.prank(sender);
      tsBVault.depositERC20(poolId, asset, amount, sender);
      uint256 txTimestamp = block.timestamp;

      // fetch contract data
      TestContractData memory dataAfter = getContractData(sender, poolId, asset, Constants.ASSET_TYPE_ERC20);

      // calc expected data
      TestContractData memory dataExpected;
      calcExpectedAssetDataAfterDepositERC20(dataBefore, dataAfter, dataExpected, amount, txTimestamp);
      calcExpectedUserDataAfterDepositERC20(dataBefore, dataAfter, dataExpected, amount, txTimestamp);

      // check the results
      checkAssetData(TestAction.DepositERC20, dataAfter.assetData, dataExpected.assetData);
      checkUserAssetData(TestAction.DepositERC20, dataAfter.userAssetData, dataExpected.userAssetData);
    }
    if (_debugFlag) console.log('>>>>actionDepositERC20', 'end');
  }

  function actionWithdrawERC20(
    address sender,
    uint32 poolId,
    address asset,
    uint256 amount,
    bytes memory revertMessage
  ) internal {
    if (_debugFlag) console.log('actionWithdrawERC20', 'begin');
    if (revertMessage.length > 0) {
      vm.expectRevert(revertMessage);
      tsHEVM.prank(sender);
      tsBVault.withdrawERC20(poolId, asset, amount, sender, sender);
    } else {
      // fetch contract data
      TestContractData memory dataBefore = getContractData(sender, poolId, asset, Constants.ASSET_TYPE_ERC20);

      // send tx
      if (_debugFlag) console.log('actionWithdrawERC20', 'sendtx');
      tsHEVM.prank(sender);
      tsBVault.withdrawERC20(poolId, asset, amount, sender, sender);
      uint256 txTimestamp = block.timestamp;

      // fetch contract data
      TestContractData memory dataAfter = getContractData(sender, poolId, asset, Constants.ASSET_TYPE_ERC20);

      // calc expected data
      TestContractData memory dataExpected;
      calcExpectedAssetDataAfterWithdrawERC20(dataBefore, dataAfter, dataExpected, amount, txTimestamp);
      calcExpectedUserDataAfterWithdrawERC20(dataBefore, dataAfter, dataExpected, amount, txTimestamp);

      // check the results
      checkAssetData(TestAction.WithdrawERC20, dataAfter.assetData, dataExpected.assetData);
      checkUserAssetData(TestAction.WithdrawERC20, dataAfter.userAssetData, dataExpected.userAssetData);
    }
    if (_debugFlag) console.log('actionWithdrawERC20', 'end');
  }

  function actionDepositERC721(
    address sender,
    uint32 poolId,
    address asset,
    uint256[] memory tokenIds,
    uint8 supplyMode,
    bytes memory revertMessage
  ) internal {
    if (_debugFlag) console.log('actionDepositERC721', 'sendtx');
    if (revertMessage.length > 0) {
      vm.expectRevert(revertMessage);
      tsHEVM.prank(sender);
      tsBVault.depositERC721(poolId, asset, tokenIds, supplyMode, sender);
    } else {
      // fetch contract data
      TestContractData memory dataBefore = getContractData(sender, poolId, asset, Constants.ASSET_TYPE_ERC721);

      // send tx
      if (_debugFlag) console.log('actionDepositERC721', 'sendtx');
      tsHEVM.prank(sender);
      tsBVault.depositERC721(poolId, asset, tokenIds, supplyMode, sender);
      uint256 txTimestamp = block.timestamp;

      // fetch contract data
      TestContractData memory dataAfter = getContractData(sender, poolId, asset, Constants.ASSET_TYPE_ERC721);

      // calc expected data
      TestContractData memory dataExpected;
      calcExpectedAssetDataAfterDepositERC721(
        dataBefore,
        dataAfter,
        dataExpected,
        tokenIds.length,
        supplyMode,
        txTimestamp
      );
      calcExpectedUserDataAfterDepositERC721(
        dataBefore,
        dataAfter,
        dataExpected,
        tokenIds.length,
        supplyMode,
        txTimestamp
      );

      // check the results
      checkAssetData(TestAction.DepositERC721, dataAfter.assetData, dataExpected.assetData);
      checkUserAssetData(TestAction.DepositERC721, dataAfter.userAssetData, dataExpected.userAssetData);
    }
    if (_debugFlag) console.log('actionDepositERC721', 'end');
  }

  function actionWithdrawERC721(
    address sender,
    uint32 poolId,
    address asset,
    uint256[] memory tokenIds,
    uint8 supplyMode,
    bytes memory revertMessage
  ) internal {
    if (_debugFlag) console.log('actionWithdrawERC721', 'begin');
    if (revertMessage.length > 0) {
      vm.expectRevert(revertMessage);
      tsHEVM.prank(sender);
      tsBVault.withdrawERC721(poolId, asset, tokenIds, supplyMode, sender, sender);
    } else {
      // fetch contract data
      TestContractData memory dataBefore = getContractData(sender, poolId, asset, Constants.ASSET_TYPE_ERC721);

      // send tx
      if (_debugFlag) console.log('actionWithdrawERC721', 'sendtx');
      tsHEVM.prank(sender);
      tsBVault.withdrawERC721(poolId, asset, tokenIds, supplyMode, sender, sender);
      uint256 txTimestamp = block.timestamp;

      // fetch contract data
      TestContractData memory dataAfter = getContractData(sender, poolId, asset, Constants.ASSET_TYPE_ERC721);

      // calc expected data
      TestContractData memory dataExpected;
      calcExpectedAssetDataAfterWithdrawERC721(
        dataBefore,
        dataAfter,
        dataExpected,
        tokenIds.length,
        supplyMode,
        txTimestamp
      );
      calcExpectedUserDataAfterWithdrawERC721(
        dataBefore,
        dataAfter,
        dataExpected,
        tokenIds.length,
        supplyMode,
        txTimestamp
      );

      // check the results
      checkAssetData(TestAction.WithdrawERC721, dataAfter.assetData, dataExpected.assetData);
      checkUserAssetData(TestAction.WithdrawERC721, dataAfter.userAssetData, dataExpected.userAssetData);
    }
    if (_debugFlag) console.log('actionWithdrawERC721', 'end');
  }

  /****************************************************************************/
  /* Checks */
  /****************************************************************************/
  function checkAssetData(
    TestAction /*action*/,
    TestAssetData memory afterAssetData,
    TestAssetData memory expectedAssetData
  ) internal {
    if (_debugFlag) console.log('checkAssetData', 'begin');
    testEquality(afterAssetData.totalCrossSupply, expectedAssetData.totalCrossSupply, 'AD:totalCrossSupply');
    testEquality(afterAssetData.totalIsolateSupply, expectedAssetData.totalIsolateSupply, 'AD:totalIsolateSupply');
    testEquality(afterAssetData.availableSupply, expectedAssetData.availableSupply, 'AD:availableSupply');
    assertEq(afterAssetData.utilizationRate, expectedAssetData.utilizationRate, 'AD:utilizationRate');

    assertEq(afterAssetData.supplyRate, expectedAssetData.supplyRate, 'AD:supplyRate');
    assertEq(afterAssetData.supplyIndex, expectedAssetData.supplyIndex, 'AD:supplyIndex');

    for (uint256 i = 0; i < afterAssetData.groupsData.length; i++) {
      if (_debugFlag) console.log('checkAssetData', 'group', i);
      TestGroupData memory afterGroupData = afterAssetData.groupsData[i];
      TestGroupData memory expectedGroupData = expectedAssetData.groupsData[i];

      testEquality(afterGroupData.totalCrossBorrow, expectedGroupData.totalCrossBorrow, 'AD:totalCrossBorrow');
      testEquality(afterGroupData.totalIsolateBorrow, expectedGroupData.totalIsolateBorrow, 'AD:totalIsolateBorrow');

      assertEq(afterGroupData.borrowRate, expectedGroupData.borrowRate, 'AD:borrowRate');
      assertEq(afterGroupData.borrowIndex, expectedGroupData.borrowIndex, 'AD:borrowIndex');
    }
    if (_debugFlag) console.log('checkAssetData', 'end');
  }

  function checkUserAssetData(
    TestAction /*action*/,
    TestUserAssetData memory afterUserData,
    TestUserAssetData memory expectedUserData
  ) internal {
    if (_debugFlag) console.log('checkUserAssetData', 'begin');
    testEquality(afterUserData.walletBalance, expectedUserData.walletBalance, 'UAD:walletBalance');

    testEquality(afterUserData.totalCrossSupply, expectedUserData.totalCrossSupply, 'UAD:totalCrossSupply');
    testEquality(afterUserData.totalIsolateSupply, expectedUserData.totalIsolateSupply, 'UAD:walletBalance');

    for (uint256 i = 0; i < afterUserData.groupsData.length; i++) {
      if (_debugFlag) console.log('checkUserAssetData', 'group', i);
      TestUserGroupData memory afterGroupData = afterUserData.groupsData[i];
      TestUserGroupData memory expectedGroupData = expectedUserData.groupsData[i];

      testEquality(afterGroupData.totalCrossBorrow, expectedGroupData.totalCrossBorrow, 'UAD:totalCrossBorrow');
      testEquality(afterGroupData.totalIsolateBorrow, expectedGroupData.totalIsolateBorrow, 'UAD:totalIsolateBorrow');
    }
    if (_debugFlag) console.log('checkUserAssetData', 'end');
  }

  function checkLoanData(
    TestAction /*action*/,
    TestLoanData[] memory afterLoansData,
    TestLoanData[] memory expectedLoansData
  ) internal {
    if (_debugFlag) console.log('checkLoanData', 'begin');

    for (uint256 i = 0; i < expectedLoansData.length; i++) {
      if (_debugFlag) console.log('checkLoanData-token', expectedLoansData[i].nftTokenId);

      assertEq(afterLoansData[i].reserveAsset, expectedLoansData[i].reserveAsset, 'LD:reserveAsset');
      testEquality(afterLoansData[i].scaledAmount, expectedLoansData[i].scaledAmount, 'LD:scaledAmount');
      testEquality(afterLoansData[i].borrowAmount, expectedLoansData[i].borrowAmount, 'LD:borrowAmount');
      assertEq(afterLoansData[i].reserveGroup, expectedLoansData[i].reserveGroup, 'LD:reserveGroup');
      assertEq(afterLoansData[i].loanStatus, expectedLoansData[i].loanStatus, 'LD:loanStatus');

      assertEq(afterLoansData[i].bidStartTimestamp, expectedLoansData[i].bidStartTimestamp, 'LD:bidStartTimestamp');
      //assertEq(afterLoansData[i].bidEndTimestamp, expectedLoansData[i].bidEndTimestamp, 'LD:bidEndTimestamp');
      assertEq(afterLoansData[i].firstBidder, expectedLoansData[i].firstBidder, 'LD:firstBidder');
      assertEq(afterLoansData[i].lastBidder, expectedLoansData[i].lastBidder, 'LD:lastBidder');
      assertEq(afterLoansData[i].bidAmount, expectedLoansData[i].bidAmount, 'LD:bidAmount');
    }

    if (_debugFlag) console.log('checkLoanData', 'end');
  }

  /****************************************************************************/
  /* Calculations */
  /****************************************************************************/

  /* DepositERC20 */
  function calcExpectedAssetDataAfterDepositERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 amountDeposited,
    uint256 txTimestamp
  ) internal view {
    if (_debugFlag) console.log('calcExpectedAssetDataAfterDepositERC20', 'begin');
    TestAssetData memory expectedAssetData = copyAssetData(dataBefore.assetData);
    dataExpected.assetData = expectedAssetData;

    // index
    calcExpectedInterestIndexs(dataBefore.assetData, expectedAssetData, txTimestamp);

    // balances
    calcExpectedAssetBalances(dataBefore.assetData, expectedAssetData);

    // supply
    expectedAssetData.totalCrossSupply = dataBefore.assetData.totalCrossSupply + amountDeposited;
    expectedAssetData.availableSupply = dataBefore.assetData.availableSupply + amountDeposited;

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
    if (_debugFlag) console.log('calcExpectedAssetDataAfterDepositERC20', 'end');
  }

  function calcExpectedUserDataAfterDepositERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 amountDeposited,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedUserDataAfterDepositERC20', 'begin');
    TestUserAssetData memory expectedUserData = copyUserAssetData(dataBefore.userAssetData);
    dataExpected.userAssetData = expectedUserData;

    // balances
    calcExpectedUserAssetBalances(dataExpected.assetData, dataBefore.userAssetData, dataExpected.userAssetData);

    // wallet
    expectedUserData.walletBalance = dataBefore.userAssetData.walletBalance - amountDeposited;

    // supply
    expectedUserData.totalCrossSupply = dataBefore.userAssetData.totalCrossSupply + amountDeposited;

    // borrow

    if (_debugFlag) console.log('calcExpectedUserDataAfterDepositERC20', 'end');
  }

  /* WithdrawERC20 */

  function calcExpectedAssetDataAfterWithdrawERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 amountWithdrawn,
    uint256 txTimestamp
  ) internal view {
    if (_debugFlag) console.log('calcExpectedAssetDataAfterWithdrawERC20', 'begin');
    TestAssetData memory expectedAssetData = copyAssetData(dataBefore.assetData);
    dataExpected.assetData = expectedAssetData;

    // index
    calcExpectedInterestIndexs(dataBefore.assetData, expectedAssetData, txTimestamp);

    // balances
    calcExpectedAssetBalances(dataExpected.assetData, dataExpected.assetData);

    // supply
    expectedAssetData.totalCrossSupply = dataBefore.assetData.totalCrossSupply - amountWithdrawn;
    expectedAssetData.availableSupply = dataBefore.assetData.availableSupply - amountWithdrawn;

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
    if (_debugFlag) console.log('calcExpectedAssetDataAfterWithdrawERC20', 'end');
  }

  function calcExpectedUserDataAfterWithdrawERC20(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 amountWithdrawn,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedUserDataAfterWithdrawERC20', 'begin');
    TestUserAssetData memory expectedUserData = copyUserAssetData(dataBefore.userAssetData);
    dataExpected.userAssetData = expectedUserData;

    // balances
    calcExpectedUserAssetBalances(dataExpected.assetData, dataBefore.userAssetData, dataExpected.userAssetData);

    // wallet
    expectedUserData.walletBalance = dataBefore.userAssetData.walletBalance + amountWithdrawn;

    // supply

    expectedUserData.totalCrossSupply = dataBefore.userAssetData.totalCrossSupply - amountWithdrawn;

    // borrow

    if (_debugFlag) console.log('calcExpectedUserDataAfterWithdrawERC20', 'end');
  }

  /* DepositERC721 */

  function calcExpectedAssetDataAfterDepositERC721(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 amountDeposited,
    uint8 supplyMode,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedAssetDataAfterDepositERC721', 'begin');
    TestAssetData memory expectedAssetData = copyAssetData(dataBefore.assetData);
    dataExpected.assetData = expectedAssetData;

    // index, no need for erc721

    // supply
    if (supplyMode == Constants.SUPPLY_MODE_CROSS) {
      expectedAssetData.totalCrossSupply = dataBefore.assetData.totalCrossSupply + amountDeposited;
    } else if (supplyMode == Constants.SUPPLY_MODE_ISOLATE) {
      expectedAssetData.totalIsolateSupply = dataBefore.assetData.totalIsolateSupply + amountDeposited;
    }
    expectedAssetData.availableSupply = dataBefore.assetData.availableSupply + amountDeposited;

    // borrow

    expectedAssetData.totalLiquidity =
      expectedAssetData.totalCrossBorrow +
      expectedAssetData.totalIsolateBorrow +
      expectedAssetData.availableSupply;

    // rate, no need for erc721

    if (_debugFlag) console.log('calcExpectedAssetDataAfterDepositERC721', 'end');
  }

  function calcExpectedUserDataAfterDepositERC721(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 amountDeposited,
    uint8 supplyMode,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedUserDataAfterDepositERC721', 'begin');
    TestUserAssetData memory expectedUserData = copyUserAssetData(dataBefore.userAssetData);
    dataExpected.userAssetData = expectedUserData;

    // balances

    // wallet
    expectedUserData.walletBalance = dataBefore.userAssetData.walletBalance - amountDeposited;

    // supply
    if (supplyMode == Constants.SUPPLY_MODE_CROSS) {
      expectedUserData.totalCrossSupply = dataBefore.userAssetData.totalCrossSupply + amountDeposited;
    } else if (supplyMode == Constants.SUPPLY_MODE_ISOLATE) {
      expectedUserData.totalIsolateSupply = dataBefore.userAssetData.totalIsolateSupply + amountDeposited;
    }

    // borrow

    if (_debugFlag) console.log('calcExpectedUserDataAfterDepositERC721', 'end');
  }

  /* WithdrawERC721 */

  function calcExpectedAssetDataAfterWithdrawERC721(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 amountWithdrawn,
    uint8 supplyMode,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedAssetDataAfterWithdrawERC721', 'begin');
    TestAssetData memory expectedAssetData = copyAssetData(dataBefore.assetData);
    dataExpected.assetData = expectedAssetData;

    // index, no need for erc721

    // supply
    if (supplyMode == Constants.SUPPLY_MODE_CROSS) {
      expectedAssetData.totalCrossSupply = dataBefore.assetData.totalCrossSupply - amountWithdrawn;
    } else if (supplyMode == Constants.SUPPLY_MODE_ISOLATE) {
      expectedAssetData.totalIsolateSupply = dataBefore.assetData.totalIsolateSupply - amountWithdrawn;
    }

    expectedAssetData.availableSupply = dataBefore.assetData.availableSupply - amountWithdrawn;
    expectedAssetData.totalLiquidity = expectedAssetData.totalLiquidity - amountWithdrawn;

    // borrow

    // rate, no need for erc721

    if (_debugFlag) console.log('calcExpectedAssetDataAfterWithdrawERC721', 'end');
  }

  function calcExpectedUserDataAfterWithdrawERC721(
    TestContractData memory dataBefore,
    TestContractData memory /*dataAfter*/,
    TestContractData memory dataExpected,
    uint256 amountWithdrawn,
    uint8 supplyMode,
    uint256 /*txTimestamp*/
  ) internal view {
    if (_debugFlag) console.log('calcExpectedUserDataAfterWithdrawERC721', 'begin');
    TestUserAssetData memory expectedUserData = copyUserAssetData(dataBefore.userAssetData);
    dataExpected.userAssetData = expectedUserData;

    // balances

    // wallet

    // supply
    expectedUserData.walletBalance = dataBefore.userAssetData.walletBalance + amountWithdrawn;

    if (supplyMode == Constants.SUPPLY_MODE_CROSS) {
      expectedUserData.totalCrossSupply = dataBefore.userAssetData.totalCrossSupply - amountWithdrawn;
    } else if (supplyMode == Constants.SUPPLY_MODE_ISOLATE) {
      expectedUserData.totalIsolateSupply = dataBefore.userAssetData.totalIsolateSupply - amountWithdrawn;
    }

    // borrow

    if (_debugFlag) console.log('calcExpectedUserDataAfterWithdrawERC721', 'end');
  }

  /****************************************************************************/
  /* Helpers for Calculations */
  /****************************************************************************/
  function sortGroupIdByRates(TestAssetData memory assetData) internal pure returns (uint8[] memory) {
    // sort group id from lowest interest rate to highest
    KVSortUtils.KeyValue[] memory groupRateList = new KVSortUtils.KeyValue[](assetData.groupsData.length);
    for (uint256 i = 0; i < assetData.groupsData.length; i++) {
      groupRateList[i].key = assetData.groupsData[i].groupId;
      groupRateList[i].val = assetData.groupsData[i].borrowRate;
    }

    KVSortUtils.sort(groupRateList);

    uint8[] memory groupIdList = new uint8[](groupRateList.length);
    for (uint256 i = 0; i < assetData.groupsData.length; i++) {
      groupIdList[i] = uint8(groupRateList[i].key);
    }
    return groupIdList;
  }

  function calcExpectedInterestIndexs(
    TestAssetData memory beforeAssetData,
    TestAssetData memory expectedAssetData,
    uint256 txTimestamp
  ) internal view {
    if (_debugFlag) console.log('calcExpectedInterestIndexs', 'begin');

    require(beforeAssetData.assetType == Constants.ASSET_TYPE_ERC20, 'asset not erc20');

    expectedAssetData.supplyIndex = calcExpectedSupplyIndex(
      beforeAssetData.utilizationRate,
      beforeAssetData.supplyRate,
      beforeAssetData.supplyIndex,
      beforeAssetData.lastUpdateTimestamp,
      txTimestamp
    );

    if (_debugFlag)
      console.log('calcExpectedInterestIndexs-supplyIndex', beforeAssetData.supplyIndex, expectedAssetData.supplyIndex);

    for (uint256 i = 0; i < expectedAssetData.groupsData.length; i++) {
      TestGroupData memory expectedGroupData = expectedAssetData.groupsData[i];
      TestGroupData memory beforeGroupData = beforeAssetData.groupsData[i];

      expectedGroupData.borrowIndex = calcExpectedBorrowIndex(
        beforeGroupData.totalCrossBorrow + beforeGroupData.totalIsolateBorrow,
        beforeGroupData.borrowRate,
        beforeGroupData.borrowIndex,
        beforeAssetData.lastUpdateTimestamp,
        txTimestamp
      );

      if (_debugFlag)
        console.log(
          'calcExpectedInterestIndexs-borrowIndex',
          i,
          beforeGroupData.borrowIndex,
          expectedGroupData.borrowIndex
        );
    }

    if (_debugFlag) console.log('calcExpectedInterestIndexs', 'end');
  }

  function calcExpectedAssetBalances(
    TestAssetData memory beforeAssetData,
    TestAssetData memory expectedAssetData
  ) internal view {
    if (_debugFlag) console.log('calcExpectedAssetBalances', 'begin');

    require(beforeAssetData.assetType == Constants.ASSET_TYPE_ERC20, 'asset not erc20');

    expectedAssetData.totalCrossSupply = beforeAssetData.totalScaledCrossSupply.rayMul(expectedAssetData.supplyIndex);
    expectedAssetData.totalIsolateSupply = beforeAssetData.totalScaledIsolateSupply.rayMul(
      expectedAssetData.supplyIndex
    );

    expectedAssetData.totalCrossBorrow = 0;
    expectedAssetData.totalIsolateBorrow = 0;

    for (uint256 i = 0; i < beforeAssetData.groupsData.length; i++) {
      TestGroupData memory expectedGroupData = expectedAssetData.groupsData[i];
      TestGroupData memory beforeGroupData = beforeAssetData.groupsData[i];

      expectedGroupData.totalCrossBorrow = beforeGroupData.totalScaledCrossBorrow.rayMul(expectedGroupData.borrowIndex);
      expectedGroupData.totalIsolateBorrow = beforeGroupData.totalScaledIsolateBorrow.rayMul(
        expectedGroupData.borrowIndex
      );

      expectedAssetData.totalCrossBorrow += expectedGroupData.totalCrossBorrow;
      expectedAssetData.totalIsolateBorrow += expectedGroupData.totalIsolateBorrow;
    }

    expectedAssetData.totalLiquidity =
      expectedAssetData.totalCrossBorrow +
      expectedAssetData.totalIsolateBorrow +
      beforeAssetData.availableSupply;
    if (expectedAssetData.totalLiquidity > 0) {
      expectedAssetData.utilizationRate = (expectedAssetData.totalCrossBorrow + expectedAssetData.totalIsolateBorrow)
        .rayDiv(expectedAssetData.totalLiquidity);
    }

    if (_debugFlag) console.log('calcExpectedAssetBalances', 'end');
  }

  function calcExpectedUserAssetBalances(
    TestAssetData memory expectedAssetData,
    TestUserAssetData memory beforeUserAssetData,
    TestUserAssetData memory expectedUserAssetData
  ) internal view {
    if (_debugFlag) console.log('calcExpectedUserAssetBalances', 'begin');

    require(expectedAssetData.assetType == Constants.ASSET_TYPE_ERC20, 'asset not erc20');

    expectedUserAssetData.totalCrossSupply = beforeUserAssetData.totalScaledCrossSupply.rayMul(
      expectedAssetData.supplyIndex
    );
    expectedUserAssetData.totalIsolateSupply = beforeUserAssetData.totalScaledIsolateSupply.rayMul(
      expectedAssetData.supplyIndex
    );

    expectedUserAssetData.totalCrossBorrow = 0;
    expectedUserAssetData.totalIsolateBorrow = 0;

    for (uint256 i = 0; i < beforeUserAssetData.groupsData.length; i++) {
      TestGroupData memory expectedGroupData = expectedAssetData.groupsData[i];
      TestUserGroupData memory expectedUserGroupData = expectedUserAssetData.groupsData[i];
      TestUserGroupData memory beforeUserGroupData = beforeUserAssetData.groupsData[i];

      expectedUserGroupData.totalCrossBorrow = beforeUserGroupData.totalScaledCrossBorrow.rayMul(
        expectedGroupData.borrowIndex
      );
      expectedUserGroupData.totalIsolateBorrow = beforeUserGroupData.totalScaledIsolateBorrow.rayMul(
        expectedGroupData.borrowIndex
      );

      expectedUserAssetData.totalCrossBorrow += expectedUserGroupData.totalCrossBorrow;
      expectedUserAssetData.totalIsolateBorrow += expectedUserGroupData.totalIsolateBorrow;
    }

    if (_debugFlag) console.log('calcExpectedUserAssetBalances', 'end');
  }

  function calcExpectedInterestRates(TestAssetData memory expectedAssetData) internal view {
    if (_debugFlag) console.log('calcExpectedInterestRates', 'begin');

    require(expectedAssetData.assetType == Constants.ASSET_TYPE_ERC20, 'asset not erc20');

    uint256 totalBorrowRate;
    uint256 totalBorrowInAsset = expectedAssetData.totalCrossBorrow + expectedAssetData.totalIsolateBorrow;
    for (uint256 i = 0; i < expectedAssetData.groupsData.length; i++) {
      TestGroupData memory groupData = expectedAssetData.groupsData[i];
      if ((groupData.totalCrossBorrow + groupData.totalIsolateBorrow) > 0) {
        require(groupData.rateModel != address(0), 'invalid rate model address');
      }

      if (groupData.rateModel == address(0)) {
        groupData.borrowRate = 0;
        continue;
      }

      groupData.borrowRate = IInterestRateModel(groupData.rateModel).calculateGroupBorrowRate(
        i,
        expectedAssetData.utilizationRate
      );
      if (_debugFlag) console.log('calcExpectedInterestRates-borrowRate', i, groupData.borrowRate);

      if (totalBorrowInAsset > 0) {
        totalBorrowRate += (groupData.borrowRate.rayMul(groupData.totalCrossBorrow + groupData.totalIsolateBorrow))
          .rayDiv(totalBorrowInAsset);
      }
    }

    expectedAssetData.supplyRate = totalBorrowRate.rayMul(expectedAssetData.utilizationRate);
    expectedAssetData.supplyRate = expectedAssetData.supplyRate.percentMul(
      PercentageMath.PERCENTAGE_FACTOR - expectedAssetData.config.feeFactor
    );

    if (_debugFlag) console.log('calcExpectedInterestRates-supplyRate', expectedAssetData.supplyRate);

    if (_debugFlag) console.log('calcExpectedInterestRates', 'end');
  }

  function calcExpectedUtilizationRate(uint256 totalBorrow, uint256 totalSupply) internal pure returns (uint256) {
    if (totalBorrow == 0) return 0;
    return totalBorrow.rayDiv(totalSupply);
  }

  function calcExpectedTotalSupply(uint256 scaledSupply, uint256 expectedIndex) internal pure returns (uint256) {
    return scaledSupply.rayMul(expectedIndex);
  }

  function calcExpectedTotalBorrow(uint256 scaledBorrow, uint256 expectedIndex) internal pure returns (uint256) {
    return scaledBorrow.rayMul(expectedIndex);
  }

  function calcExpectedNormalizedIncome(
    uint256 supplyRate,
    uint256 supplyIndex,
    uint256 lastUpdateTimestamp,
    uint256 currentTimestamp
  ) internal pure returns (uint256) {
    if (supplyRate == 0) return supplyIndex;

    uint256 cumulatedInterest = calcLinearInterest(supplyRate, lastUpdateTimestamp, currentTimestamp);
    return cumulatedInterest.rayMul(supplyIndex);
  }

  function calcExpectedNormalizedDebt(
    uint256 borrowRate,
    uint256 borrowIndex,
    uint256 lastUpdateTimestamp,
    uint256 currentTimestamp
  ) internal pure returns (uint256) {
    if (borrowRate == 0) return borrowIndex;

    uint256 cumulatedInterest = calcCompoundedInterest(borrowRate, lastUpdateTimestamp, currentTimestamp);
    return cumulatedInterest.rayMul(borrowIndex);
  }

  function calcExpectedSupplyIndex(
    uint256 utilizationRate,
    uint256 supplyRate,
    uint256 supplyIndex,
    uint256 lastUpdateTimestamp,
    uint256 currentTimestamp
  ) internal pure returns (uint256) {
    if (utilizationRate == 0) return supplyIndex;

    return calcExpectedNormalizedIncome(supplyRate, supplyIndex, lastUpdateTimestamp, currentTimestamp);
  }

  function calcExpectedBorrowIndex(
    uint256 totalBorrow,
    uint256 borrowRate,
    uint256 borrowIndex,
    uint256 lastUpdateTimestamp,
    uint256 currentTimestamp
  ) internal pure returns (uint256) {
    if (totalBorrow == 0) return borrowIndex;

    return calcExpectedNormalizedDebt(borrowRate, borrowIndex, lastUpdateTimestamp, currentTimestamp);
  }

  function calcLinearInterest(
    uint256 rate,
    uint256 lastUpdateTimestamp,
    uint256 currentTimestamp
  ) internal pure returns (uint256) {
    return MathUtils.calculateLinearInterest(rate, lastUpdateTimestamp, currentTimestamp);
  }

  function calcCompoundedInterest(
    uint256 rate,
    uint256 lastUpdateTimestamp,
    uint256 currentTimestamp
  ) internal pure returns (uint256) {
    return MathUtils.calculateCompoundedInterest(rate, lastUpdateTimestamp, currentTimestamp);
  }
}
