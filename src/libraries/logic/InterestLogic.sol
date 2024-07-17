// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';
import {IERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';
import {SafeCastUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol';

import {IInterestRateModel} from '../../interfaces/IInterestRateModel.sol';

import {MathUtils} from '..//math/MathUtils.sol';
import {WadRayMath} from '../math/WadRayMath.sol';
import {PercentageMath} from '../math/PercentageMath.sol';

import {Constants} from '../helpers/Constants.sol';
import {Errors} from '../helpers/Errors.sol';
import {Events} from '../helpers/Events.sol';
import {DataTypes} from '../types/DataTypes.sol';
import {InputTypes} from '../types/InputTypes.sol';

/**
 * @title InterestLogic library
 * @notice Implements the logic to update the interest state
 */
library InterestLogic {
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
  using SafeCastUpgradeable for uint256;
  using WadRayMath for uint256;
  using PercentageMath for uint256;

  /**
   * @notice Initializes a asset.
   */
  function initAssetData(DataTypes.AssetData storage assetData) internal {
    require(assetData.supplyIndex == 0, Errors.ASSET_ALREADY_EXISTS);
    assetData.supplyIndex = uint128(WadRayMath.RAY);
  }

  function initGroupData(DataTypes.GroupData storage groupData) internal {
    require(groupData.borrowIndex == 0, Errors.GROUP_ALREADY_EXISTS);
    groupData.borrowIndex = uint128(WadRayMath.RAY);
  }

  /**
   * @notice Returns the ongoing normalized supply income for the asset.
   * @dev A value of 1e27 means there is no income. As time passes, the income is accrued
   * @dev A value of 2*1e27 means for each unit of asset one unit of income has been accrued
   */
  function getNormalizedSupplyIncome(DataTypes.AssetData storage assetData) internal view returns (uint256) {
    //solium-disable-next-line
    if (assetData.lastUpdateTimestamp == block.timestamp) {
      //if the index was updated in the same block, no need to perform any calculation
      return assetData.supplyIndex;
    } else {
      return
        MathUtils.calculateLinearInterest(assetData.supplyRate, assetData.lastUpdateTimestamp).rayMul(
          assetData.supplyIndex
        );
    }
  }

  /**
   * @notice Returns the ongoing normalized borrow debt for the reserve.
   * @dev A value of 1e27 means there is no debt. As time passes, the debt is accrued
   * @dev A value of 2*1e27 means that for each unit of debt, one unit worth of interest has been accumulated
   */
  function getNormalizedBorrowDebt(
    DataTypes.AssetData storage assetData,
    DataTypes.GroupData storage groupData
  ) internal view returns (uint256) {
    //solium-disable-next-line
    if (assetData.lastUpdateTimestamp == block.timestamp) {
      //if the index was updated in the same block, no need to perform any calculation
      return groupData.borrowIndex;
    } else {
      return
        MathUtils.calculateCompoundedInterest(groupData.borrowRate, assetData.lastUpdateTimestamp).rayMul(
          groupData.borrowIndex
        );
    }
  }

  struct UpdateInterestIndexsLocalVars {
    uint256 i;
    uint256[] assetGroupIds;
    uint8 loopGroupId;
    uint256 prevGroupBorrowIndex;
  }

  /**
   * @notice Updates the asset current borrow index and current supply index.
   */
  function updateInterestIndexs(
    DataTypes.PoolData storage /*poolData*/,
    DataTypes.AssetData storage assetData
  ) internal {
    // only update once time in every block
    if (assetData.lastUpdateTimestamp == uint40(block.timestamp)) {
      return;
    }

    UpdateInterestIndexsLocalVars memory vars;

    // updating supply index
    _updateSupplyIndex(assetData);

    // updating all groups borrow index
    vars.assetGroupIds = assetData.groupList.values();
    for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {
      vars.loopGroupId = uint8(vars.assetGroupIds[vars.i]);
      DataTypes.GroupData storage loopGroupData = assetData.groupLookup[vars.loopGroupId];
      vars.prevGroupBorrowIndex = loopGroupData.borrowIndex;
      _updateBorrowIndex(assetData, loopGroupData);
      _accrueFeeToTreasury(assetData, loopGroupData, vars.prevGroupBorrowIndex);
    }

    // save updating time
    assetData.lastUpdateTimestamp = uint40(block.timestamp);
  }

  struct UpdateInterestRatesLocalVars {
    uint256 i;
    uint256[] assetGroupIds;
    uint8 loopGroupId;
    uint256 loopGroupScaledDebt;
    uint256 loopGroupDebt;
    uint256[] allGroupDebtList;
    uint256 totalAssetScaledDebt;
    uint256 totalAssetDebt;
    uint256 availableLiquidityPlusDebt;
    uint256 assetUtilizationRate;
    uint256 nextGroupBorrowRate;
    uint256 nextAssetBorrowRate;
    uint256 nextAssetSupplyRate;
  }

  /**
   * @notice Updates the asset current borrow rate and current supply rate.
   */
  function updateInterestRates(
    DataTypes.PoolData storage poolData,
    DataTypes.AssetData storage assetData,
    uint256 liquidityAdded,
    uint256 liquidityTaken
  ) internal {
    UpdateInterestRatesLocalVars memory vars;

    vars.assetGroupIds = assetData.groupList.values();

    // calculate the total asset debt
    vars.allGroupDebtList = new uint256[](vars.assetGroupIds.length);
    for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {
      vars.loopGroupId = uint8(vars.assetGroupIds[vars.i]);
      DataTypes.GroupData storage loopGroupData = assetData.groupLookup[vars.loopGroupId];
      vars.loopGroupScaledDebt = loopGroupData.totalScaledCrossBorrow + loopGroupData.totalScaledIsolateBorrow;
      vars.loopGroupDebt = vars.loopGroupScaledDebt.rayMul(loopGroupData.borrowIndex);
      vars.allGroupDebtList[vars.i] = vars.loopGroupDebt;

      vars.totalAssetDebt += vars.loopGroupDebt;
    }

    // calculate the total asset supply
    vars.availableLiquidityPlusDebt =
      assetData.availableLiquidity +
      liquidityAdded -
      liquidityTaken +
      vars.totalAssetDebt;
    if (vars.availableLiquidityPlusDebt > 0) {
      vars.assetUtilizationRate = vars.totalAssetDebt.rayDiv(vars.availableLiquidityPlusDebt);
    }

    // calculate the group borrow rate
    for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {
      vars.loopGroupId = uint8(vars.assetGroupIds[vars.i]);
      DataTypes.GroupData storage loopGroupData = assetData.groupLookup[vars.loopGroupId];

      vars.nextGroupBorrowRate = IInterestRateModel(loopGroupData.rateModel).calculateGroupBorrowRate(
        vars.loopGroupId,
        vars.assetUtilizationRate
      );
      loopGroupData.borrowRate = vars.nextGroupBorrowRate.toUint128();

      // assetBorrowRate = SUM(groupBorrowRate * (groupDebt / assetDebt))
      if (vars.totalAssetDebt > 0) {
        vars.nextAssetBorrowRate += vars.nextGroupBorrowRate.rayMul(vars.allGroupDebtList[vars.i]).rayDiv(
          vars.totalAssetDebt
        );
      }

      emit Events.AssetInterestBorrowDataUpdated(
        poolData.poolId,
        assetData.underlyingAsset,
        vars.loopGroupId,
        vars.nextGroupBorrowRate,
        loopGroupData.borrowIndex
      );
    }

    // calculate the asset supply rate
    vars.nextAssetSupplyRate = vars.nextAssetBorrowRate.rayMul(vars.assetUtilizationRate);
    vars.nextAssetSupplyRate = vars.nextAssetSupplyRate.percentMul(
      PercentageMath.PERCENTAGE_FACTOR - assetData.feeFactor
    );
    assetData.supplyRate = vars.nextAssetSupplyRate.toUint128();

    emit Events.AssetInterestSupplyDataUpdated(
      poolData.poolId,
      assetData.underlyingAsset,
      vars.nextAssetSupplyRate,
      assetData.supplyIndex
    );
  }

  struct AccrueToTreasuryLocalVars {
    uint256 totalScaledBorrow;
    uint256 prevTotalBorrow;
    uint256 currTotalBorrow;
    uint256 totalDebtAccrued;
    uint256 amountToMint;
  }

  /**
   * @notice Mints part of the repaid interest to the treasury as a function of the fee factor for the
   * specific asset.
   */
  function _accrueFeeToTreasury(
    DataTypes.AssetData storage assetData,
    DataTypes.GroupData storage groupData,
    uint256 prevGroupBorrowIndex
  ) internal {
    AccrueToTreasuryLocalVars memory vars;

    if (assetData.feeFactor == 0) {
      return;
    }

    vars.totalScaledBorrow = groupData.totalScaledCrossBorrow + groupData.totalScaledIsolateBorrow;

    //calculate the total debt at moment of the last interaction
    vars.prevTotalBorrow = vars.totalScaledBorrow.rayMul(prevGroupBorrowIndex);

    //calculate the new total debt after accumulation of the interest on the index
    vars.currTotalBorrow = vars.totalScaledBorrow.rayMul(groupData.borrowIndex);

    //debt accrued is the sum of the current debt minus the sum of the debt at the last update
    vars.totalDebtAccrued = vars.currTotalBorrow - vars.prevTotalBorrow;

    vars.amountToMint = vars.totalDebtAccrued.percentMul(assetData.feeFactor);

    if (vars.amountToMint != 0) {
      assetData.accruedFee += vars.amountToMint.rayDiv(assetData.supplyIndex).toUint128();
    }
  }

  /**
   * @notice Updates the asset supply index and the timestamp of the update.
   */
  function _updateSupplyIndex(DataTypes.AssetData storage assetData) internal {
    // Only cumulating on the supply side if there is any income being produced
    // The case of Fee Factor 100% is not a problem (supplyRate == 0),
    // as liquidity index should not be updated
    if (assetData.supplyRate != 0) {
      uint256 cumulatedSupplyInterest = MathUtils.calculateLinearInterest(
        assetData.supplyRate,
        assetData.lastUpdateTimestamp
      );
      uint256 nextSupplyIndex = cumulatedSupplyInterest.rayMul(assetData.supplyIndex);
      assetData.supplyIndex = nextSupplyIndex.toUint128();
    }
  }

  /**
   * @notice Updates the group borrow index and the timestamp of the update.
   */
  function _updateBorrowIndex(DataTypes.AssetData storage assetData, DataTypes.GroupData storage groupData) internal {
    // borrow index only gets updated if there is any variable debt.
    // groupData.borrowRate != 0 is not a correct validation,
    // because a positive base variable rate can be stored on
    // groupData.borrowRate, but the index should not increase
    if ((groupData.totalScaledCrossBorrow != 0) || (groupData.totalScaledIsolateBorrow != 0)) {
      uint256 cumulatedBorrowInterest = MathUtils.calculateCompoundedInterest(
        groupData.borrowRate,
        assetData.lastUpdateTimestamp
      );
      uint256 nextBorrowIndex = cumulatedBorrowInterest.rayMul(groupData.borrowIndex);
      groupData.borrowIndex = nextBorrowIndex.toUint128();
    }
  }
}
