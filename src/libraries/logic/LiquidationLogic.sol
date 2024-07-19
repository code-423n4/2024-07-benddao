// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

import {IAddressProvider} from '../../interfaces/IAddressProvider.sol';
import {IPriceOracleGetter} from '../../interfaces/IPriceOracleGetter.sol';

import {Constants} from '../helpers/Constants.sol';
import {Errors} from '../helpers/Errors.sol';
import {Events} from '../helpers/Events.sol';

import {InputTypes} from '../types/InputTypes.sol';
import {DataTypes} from '../types/DataTypes.sol';
import {ResultTypes} from '../types/ResultTypes.sol';

import {WadRayMath} from '../math/WadRayMath.sol';
import {PercentageMath} from '../math/PercentageMath.sol';
import {KVSortUtils} from '../helpers/KVSortUtils.sol';

import {StorageSlot} from './StorageSlot.sol';
import {VaultLogic} from './VaultLogic.sol';
import {InterestLogic} from './InterestLogic.sol';
import {GenericLogic} from './GenericLogic.sol';
import {ValidateLogic} from './ValidateLogic.sol';

library LiquidationLogic {
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
  using WadRayMath for uint256;
  using PercentageMath for uint256;

  struct LiquidateERC20LocalVars {
    address priceOracle;
    uint256 gidx;
    uint256[] assetGroupIds;
    uint256 userCollateralBalance;
    uint256 userTotalDebt;
    uint256 actualDebtToLiquidate;
    uint256 remainDebtToLiquidate;
    uint256 actualCollateralToLiquidate;
    ResultTypes.UserAccountResult userAccountResult;
  }

  /**
   * @notice Function to liquidate a position if its Health Factor drops below 1. The caller (liquidator)
   * covers `debtToCover` amount of debt of the user getting liquidated, and receives
   * a proportional amount of the `collateralAsset` plus a bonus to cover market risk
   */
  function executeCrossLiquidateERC20(
    InputTypes.ExecuteCrossLiquidateERC20Params memory params
  ) internal returns (uint256, uint256) {
    LiquidateERC20LocalVars memory vars;

    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    vars.priceOracle = IAddressProvider(ps.addressProvider).getPriceOracle();

    DataTypes.PoolData storage poolData = ps.poolLookup[params.poolId];
    DataTypes.AssetData storage collateralAssetData = poolData.assetLookup[params.collateralAsset];
    DataTypes.AssetData storage debtAssetData = poolData.assetLookup[params.debtAsset];

    // make sure collateral asset's all index updated
    InterestLogic.updateInterestIndexs(poolData, collateralAssetData);

    // make sure debt asset's all index updated
    InterestLogic.updateInterestIndexs(poolData, debtAssetData);

    ValidateLogic.validateCrossLiquidateERC20(params, poolData, collateralAssetData, debtAssetData);

    // check the user account state
    vars.userAccountResult = GenericLogic.calculateUserAccountDataForLiquidate(
      poolData,
      params.borrower,
      params.collateralAsset,
      vars.priceOracle
    );

    require(
      vars.userAccountResult.healthFactor < Constants.HEALTH_FACTOR_LIQUIDATION_THRESHOLD,
      Errors.HEALTH_FACTOR_NOT_BELOW_LIQUIDATION_THRESHOLD
    );

    // calculate user's debt and collateral supply
    (vars.userTotalDebt, vars.actualDebtToLiquidate) = _calculateUserERC20Debt(
      poolData,
      debtAssetData,
      params,
      vars.userAccountResult.healthFactor
    );
    require(vars.userTotalDebt > 0, Errors.USER_DEBT_BORROWED_ZERO);

    vars.userCollateralBalance = VaultLogic.erc20GetUserCrossSupply(
      collateralAssetData,
      params.borrower,
      collateralAssetData.supplyIndex
    );
    require(vars.userCollateralBalance > 0, Errors.USER_COLLATERAL_SUPPLY_ZERO);

    (vars.actualCollateralToLiquidate, vars.actualDebtToLiquidate) = _calculateAvailableERC20CollateralToLiquidate(
      collateralAssetData,
      debtAssetData,
      vars.actualDebtToLiquidate,
      vars.userCollateralBalance,
      IPriceOracleGetter(vars.priceOracle)
    );
    require(vars.actualCollateralToLiquidate > 0, Errors.ACTUAL_COLLATERAL_TO_LIQUIDATE_ZERO);
    require(vars.actualDebtToLiquidate > 0, Errors.ACTUAL_DEBT_TO_LIQUIDATE_ZERO);

    vars.remainDebtToLiquidate = _repayUserERC20Debt(
      poolData,
      debtAssetData,
      params.borrower,
      vars.actualDebtToLiquidate
    );
    require(vars.remainDebtToLiquidate == 0, Errors.LIQUIDATE_REPAY_DEBT_FAILED);

    // If all the debt has being repaid we need clear the borrow flag
    VaultLogic.accountCheckAndSetBorrowedAsset(poolData, debtAssetData, params.borrower);

    // update rates before transer liquidator repaid debt asset
    InterestLogic.updateInterestRates(poolData, debtAssetData, vars.actualDebtToLiquidate, 0);

    // Transfers the debt asset being repaid to the vault, where the liquidity is kept
    VaultLogic.erc20TransferInLiquidity(debtAssetData, params.msgSender, vars.actualDebtToLiquidate);

    // Whether transfer the liquidated collateral or supplied as new collateral to liquidator
    if (params.supplyAsCollateral) {
      _supplyUserERC20CollateralToLiquidator(poolData, collateralAssetData, params, vars);
    } else {
      _transferUserERC20CollateralToLiquidator(poolData, collateralAssetData, params, vars);
    }

    // If user's all the collateral has being liquidated we need clear the supply flag
    VaultLogic.accountCheckAndSetSuppliedAsset(poolData, collateralAssetData, params.borrower);

    emit Events.CrossLiquidateERC20(
      params.msgSender,
      params.poolId,
      params.borrower,
      params.collateralAsset,
      params.debtAsset,
      vars.actualDebtToLiquidate,
      vars.actualCollateralToLiquidate,
      params.supplyAsCollateral
    );

    return (vars.actualCollateralToLiquidate, vars.actualDebtToLiquidate);
  }

  struct LiquidateERC721LocalVars {
    address priceOracle;
    uint256 gidx;
    uint256[] assetGroupIds;
    uint256 userCollateralBalance;
    uint256 actualCollateralToLiquidate;
    uint256 actualDebtToLiquidate;
    uint256 remainDebtToLiquidate;
    ResultTypes.UserAccountResult userAccountResult;
  }

  /**
   * @notice Function to liquidate a ERC721 collateral if its Health Factor drops below 1.
   */
  function executeCrossLiquidateERC721(
    InputTypes.ExecuteCrossLiquidateERC721Params memory params
  ) internal returns (uint256, uint256) {
    LiquidateERC721LocalVars memory vars;

    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    vars.priceOracle = IAddressProvider(ps.addressProvider).getPriceOracle();

    DataTypes.PoolData storage poolData = ps.poolLookup[params.poolId];
    DataTypes.AssetData storage collateralAssetData = poolData.assetLookup[params.collateralAsset];
    DataTypes.AssetData storage debtAssetData = poolData.assetLookup[params.debtAsset];

    // make sure coallteral asset's all index updated
    InterestLogic.updateInterestIndexs(poolData, collateralAssetData);

    // make sure debt asset's all index updated
    InterestLogic.updateInterestIndexs(poolData, debtAssetData);

    ValidateLogic.validateCrossLiquidateERC721(params, poolData, collateralAssetData, debtAssetData);

    vars.assetGroupIds = debtAssetData.groupList.values();

    vars.userAccountResult = GenericLogic.calculateUserAccountDataForLiquidate(
      poolData,
      params.borrower,
      params.collateralAsset,
      vars.priceOracle
    );

    require(
      vars.userAccountResult.healthFactor < Constants.HEALTH_FACTOR_LIQUIDATION_THRESHOLD,
      Errors.HEALTH_FACTOR_NOT_BELOW_LIQUIDATION_THRESHOLD
    );

    vars.userCollateralBalance = VaultLogic.erc721GetUserCrossSupply(collateralAssetData, params.borrower);
    require(vars.userCollateralBalance > 0, Errors.USER_COLLATERAL_SUPPLY_ZERO);

    // the liquidated debt amount will be decided by the liquidated collateral
    (vars.actualCollateralToLiquidate, vars.actualDebtToLiquidate) = _calculateDebtAmountFromERC721Collateral(
      collateralAssetData,
      debtAssetData,
      params,
      vars,
      IPriceOracleGetter(vars.priceOracle)
    );
    require(vars.actualCollateralToLiquidate > 0, Errors.ACTUAL_COLLATERAL_TO_LIQUIDATE_ZERO);
    require(vars.actualDebtToLiquidate > 0, Errors.ACTUAL_DEBT_TO_LIQUIDATE_ZERO);

    // try to repay debt for the user, the liquidated debt amount may less than user total debt
    vars.remainDebtToLiquidate = _repayUserERC20Debt(
      poolData,
      debtAssetData,
      params.borrower,
      vars.actualDebtToLiquidate
    );
    if (vars.remainDebtToLiquidate > 0) {
      // transfer the remain debt asset to the user as new supplied collateral
      VaultLogic.erc20IncreaseCrossSupply(debtAssetData, params.borrower, vars.remainDebtToLiquidate);

      // If the collateral is supplied at first we need set the supply flag
      VaultLogic.accountCheckAndSetSuppliedAsset(poolData, debtAssetData, params.borrower);
    }

    // If all the debt has being repaid we need to clear the borrow flag
    VaultLogic.accountCheckAndSetBorrowedAsset(poolData, debtAssetData, params.borrower);

    InterestLogic.updateInterestRates(poolData, debtAssetData, vars.actualDebtToLiquidate, 0);

    // Transfers the debt asset being repaid to the vault, where the liquidity is kept
    VaultLogic.erc20TransferInLiquidity(debtAssetData, params.msgSender, vars.actualDebtToLiquidate);

    // Whether transfer the liquidated collateral or supplied as new collateral to liquidator
    if (params.supplyAsCollateral) {
      _supplyUserERC721CollateralToLiquidator(poolData, collateralAssetData, params);
    } else {
      _transferUserERC721CollateralToLiquidator(collateralAssetData, params);
    }

    // If all the collateral has been liquidated we need clear the supply flag
    VaultLogic.accountCheckAndSetSuppliedAsset(poolData, collateralAssetData, params.borrower);

    emit Events.CrossLiquidateERC721(
      params.msgSender,
      params.poolId,
      params.borrower,
      params.collateralAsset,
      params.collateralTokenIds,
      params.debtAsset,
      vars.actualDebtToLiquidate,
      params.supplyAsCollateral
    );

    return (vars.actualCollateralToLiquidate, vars.actualDebtToLiquidate);
  }

  /**
   * @notice Transfers the underlying ERC20 to the liquidator.
   */
  function _transferUserERC20CollateralToLiquidator(
    DataTypes.PoolData storage poolData,
    DataTypes.AssetData storage collateralAssetData,
    InputTypes.ExecuteCrossLiquidateERC20Params memory params,
    LiquidateERC20LocalVars memory vars
  ) internal {
    // Burn the equivalent amount of collateral, sending the underlying to the liquidator
    VaultLogic.erc20DecreaseCrossSupply(collateralAssetData, params.borrower, vars.actualCollateralToLiquidate);

    // update rates before transfer out collateral to liquidator
    InterestLogic.updateInterestRates(poolData, collateralAssetData, 0, vars.actualCollateralToLiquidate);

    VaultLogic.erc20TransferOutLiquidity(collateralAssetData, params.msgSender, vars.actualCollateralToLiquidate);
  }

  /**
   * @notice Liquidates the user erc20 collateral by transferring them to the liquidator.
   */
  function _supplyUserERC20CollateralToLiquidator(
    DataTypes.PoolData storage poolData,
    DataTypes.AssetData storage collateralAssetData,
    InputTypes.ExecuteCrossLiquidateERC20Params memory params,
    LiquidateERC20LocalVars memory vars
  ) internal {
    // no need to update the interest rate, cos the total suplly not changed

    // transfer the equivalent amount between liquidator and borrower
    VaultLogic.erc20TransferCrossSupply(
      collateralAssetData,
      params.borrower,
      params.msgSender,
      vars.actualCollateralToLiquidate
    );

    // If the collateral is supplied at first we need set the supply flag
    VaultLogic.accountCheckAndSetSuppliedAsset(poolData, collateralAssetData, params.msgSender);
  }

  /**
   * @notice Burns the debt of the user up to the amount being repaid by the liquidator.
   */
  function _repayUserERC20Debt(
    DataTypes.PoolData storage /*poolData*/,
    DataTypes.AssetData storage debtAssetData,
    address user,
    uint256 actualDebtToLiquidate
  ) internal returns (uint256) {
    // sort group id from lowest interest rate to highest
    uint256[] memory assetGroupIds = debtAssetData.groupList.values();
    KVSortUtils.KeyValue[] memory groupRateList = new KVSortUtils.KeyValue[](assetGroupIds.length);
    for (uint256 i = 0; i < groupRateList.length; i++) {
      DataTypes.GroupData storage loopGroupData = debtAssetData.groupLookup[uint8(assetGroupIds[i])];
      groupRateList[i].key = assetGroupIds[i];
      groupRateList[i].val = loopGroupData.borrowRate;
    }
    KVSortUtils.sort(groupRateList);

    // repay group debt one by one, but from highest to lowest
    uint256 remainDebtToLiquidate = actualDebtToLiquidate;
    for (uint256 i = 0; i < groupRateList.length; i++) {
      uint256 reverseIdx = (groupRateList.length - 1) - i;
      DataTypes.GroupData storage loopGroupData = debtAssetData.groupLookup[uint8(groupRateList[reverseIdx].key)];

      uint256 curDebtRepayAmount = VaultLogic.erc20GetUserCrossBorrowInGroup(
        loopGroupData,
        user,
        loopGroupData.borrowIndex
      );
      // just ignore if no debt in the group
      if (curDebtRepayAmount == 0) {
        continue;
      }

      // only repaid the max actual debt in the group
      if (curDebtRepayAmount > remainDebtToLiquidate) {
        curDebtRepayAmount = remainDebtToLiquidate;
        remainDebtToLiquidate = 0;
      } else {
        remainDebtToLiquidate -= curDebtRepayAmount;
      }
      VaultLogic.erc20DecreaseCrossBorrow(loopGroupData, user, curDebtRepayAmount);

      if (remainDebtToLiquidate == 0) {
        break;
      }
    }

    return remainDebtToLiquidate;
  }

  /**
   * @notice Calculates the total debt of the user and the actual amount to liquidate depending on the health factor
   * and corresponding close factor.
   * @dev If the Health Factor is below CLOSE_FACTOR_HF_THRESHOLD, the close factor is increased to MAX_LIQUIDATION_CLOSE_FACTOR
   */
  function _calculateUserERC20Debt(
    DataTypes.PoolData storage poolData,
    DataTypes.AssetData storage debtAssetData,
    InputTypes.ExecuteCrossLiquidateERC20Params memory params,
    uint256 healthFactor
  ) internal view returns (uint256, uint256) {
    uint256 userTotalDebt = VaultLogic.erc20GetUserCrossBorrowInAsset(poolData, debtAssetData, params.borrower);

    // Whether 50% or 100% debt can be liquidated (covered)
    uint256 closeFactor = healthFactor > Constants.CLOSE_FACTOR_HF_THRESHOLD
      ? Constants.DEFAULT_LIQUIDATION_CLOSE_FACTOR
      : Constants.MAX_LIQUIDATION_CLOSE_FACTOR;

    uint256 maxLiquidatableDebt = userTotalDebt.percentMul(closeFactor);

    uint256 actualDebtToLiquidate = params.debtToCover > maxLiquidatableDebt ? maxLiquidatableDebt : params.debtToCover;

    return (userTotalDebt, actualDebtToLiquidate);
  }

  struct AvailableERC20CollateralToLiquidateLocalVars {
    uint256 collateralPrice;
    uint256 debtAssetPrice;
    uint256 maxCollateralToLiquidate;
    uint256 baseCollateral;
    uint256 bonusCollateral;
    uint256 collateralAssetUnit;
    uint256 debtAssetUnit;
    uint256 collateralAmount;
    uint256 debtAmountNeeded;
  }

  /**
   * @notice Calculates how much of a specific collateral can be liquidated, given a certain amount of debt asset.
   */
  function _calculateAvailableERC20CollateralToLiquidate(
    DataTypes.AssetData storage collateralAssetData,
    DataTypes.AssetData storage debtAssetData,
    uint256 debtToCover,
    uint256 userCollateralBalance,
    IPriceOracleGetter oracle
  ) internal view returns (uint256, uint256) {
    AvailableERC20CollateralToLiquidateLocalVars memory vars;

    vars.collateralPrice = oracle.getAssetPrice(collateralAssetData.underlyingAsset);
    vars.debtAssetPrice = oracle.getAssetPrice(debtAssetData.underlyingAsset);

    vars.collateralAssetUnit = 10 ** collateralAssetData.underlyingDecimals;
    vars.debtAssetUnit = 10 ** debtAssetData.underlyingDecimals;

    // This is the base collateral to liquidate based on the given debt to cover
    vars.baseCollateral =
      ((debtToCover * vars.debtAssetPrice * vars.collateralAssetUnit)) /
      (vars.debtAssetUnit * vars.collateralPrice);

    vars.maxCollateralToLiquidate = vars.baseCollateral.percentMul(
      PercentageMath.PERCENTAGE_FACTOR + collateralAssetData.liquidationBonus
    );

    if (vars.maxCollateralToLiquidate > userCollateralBalance) {
      vars.collateralAmount = userCollateralBalance;
      vars.debtAmountNeeded = ((vars.collateralAmount * vars.collateralPrice * vars.debtAssetUnit) /
        (vars.collateralAssetUnit * vars.debtAssetPrice)).percentDiv(
          PercentageMath.PERCENTAGE_FACTOR + collateralAssetData.liquidationBonus
        );
    } else {
      vars.collateralAmount = vars.maxCollateralToLiquidate;
      vars.debtAmountNeeded = debtToCover;
    }

    return (vars.collateralAmount, vars.debtAmountNeeded);
  }

  /**
   * @notice Transfers the underlying ERC721 to the liquidator.
   */
  function _transferUserERC721CollateralToLiquidator(
    DataTypes.AssetData storage collateralAssetData,
    InputTypes.ExecuteCrossLiquidateERC721Params memory params
  ) internal {
    // Burn the equivalent amount of collateral, sending the underlying to the liquidator
    VaultLogic.erc721DecreaseCrossSupply(collateralAssetData, params.borrower, params.collateralTokenIds);

    VaultLogic.erc721TransferOutLiquidity(collateralAssetData, params.msgSender, params.collateralTokenIds);
  }

  /**
   * @notice Liquidates the user erc721 collateral by transferring them to the liquidator.
   */
  function _supplyUserERC721CollateralToLiquidator(
    DataTypes.PoolData storage poolData,
    DataTypes.AssetData storage collateralAssetData,
    InputTypes.ExecuteCrossLiquidateERC721Params memory params
  ) internal {
    VaultLogic.erc721TransferCrossSupply(
      collateralAssetData,
      params.borrower,
      params.msgSender,
      params.collateralTokenIds
    );

    // If the collateral is supplied at first we need set the supply flag
    VaultLogic.accountCheckAndSetSuppliedAsset(poolData, collateralAssetData, params.msgSender);
  }

  struct CalculateDebtAmountFromERC721CollateralLocalVars {
    uint256 collateralPrice;
    uint256 collateralBonusPrice;
    uint256 collateralLiquidatePrice;
    uint256 collateralTotalValue;
    uint256 collateralTotalDebtToCover;
    uint256 collateralItemDebtToCover;
    uint256 debtAssetPrice;
    uint256 debtAssetUnit;
    uint256 debtAmountNeeded;
  }

  /**
   * @notice Calculates how much of a specific debt can be covered, given a certain amount of collateral asset.
   */
  function _calculateDebtAmountFromERC721Collateral(
    DataTypes.AssetData storage collateralAssetData,
    DataTypes.AssetData storage debtAssetData,
    InputTypes.ExecuteCrossLiquidateERC721Params memory params,
    LiquidateERC721LocalVars memory liqVars,
    IPriceOracleGetter oracle
  ) internal view returns (uint256, uint256) {
    CalculateDebtAmountFromERC721CollateralLocalVars memory vars;

    // in this function, all prices are in base currency

    vars.collateralPrice = oracle.getAssetPrice(params.collateralAsset);
    vars.collateralBonusPrice = vars.collateralPrice.percentMul(
      PercentageMath.PERCENTAGE_FACTOR - collateralAssetData.liquidationBonus
    );

    vars.debtAssetUnit = 10 ** debtAssetData.underlyingDecimals;
    vars.debtAssetPrice = oracle.getAssetPrice(params.debtAsset);

    // calculate the debt should be covered by the liquidated collateral of user
    vars.collateralTotalDebtToCover =
      (liqVars.userAccountResult.inputCollateralInBaseCurrency * liqVars.userAccountResult.totalDebtInBaseCurrency) /
      liqVars.userAccountResult.totalCollateralInBaseCurrency;
    vars.collateralItemDebtToCover = vars.collateralTotalDebtToCover / liqVars.userCollateralBalance;

    // using highest price as final liquidate price, all price and debt are based on base currency
    if (vars.collateralBonusPrice > vars.collateralItemDebtToCover) {
      vars.collateralLiquidatePrice = vars.collateralBonusPrice;
    } else {
      vars.collateralLiquidatePrice = vars.collateralItemDebtToCover;
    }

    vars.collateralTotalValue = vars.collateralLiquidatePrice * params.collateralTokenIds.length;
    vars.debtAmountNeeded = (vars.collateralTotalValue * vars.debtAssetUnit) / vars.debtAssetPrice;

    return (vars.collateralTotalValue, vars.debtAmountNeeded);
  }

  struct GetUserAccountLiquidationDataLocalVars {
    address priceOracle;
    uint256 userCollateralBalance;
    uint256 userTotalDebt;
    uint256 actualDebtToLiquidate;
    uint256 actualCollateralToLiquidate;
    ResultTypes.UserAccountResult userAccountResult;
  }

  /**
   * @notice Function to query user liquidate data if its Health Factor drops below 1.
   * @dev It's only used in FrontEnd UI, Do not use it in contract!
   */
  function viewGetUserCrossLiquidateData(
    InputTypes.ViewGetUserCrossLiquidateDataParams memory getDataParams
  ) internal view returns (uint256 actualCollateralToLiquidate, uint256 actualDebtToLiquidate) {
    GetUserAccountLiquidationDataLocalVars memory vars;

    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    vars.priceOracle = IAddressProvider(ps.addressProvider).getPriceOracle();

    DataTypes.PoolData storage poolData = ps.poolLookup[getDataParams.poolId];
    DataTypes.AssetData storage collateralAssetData = poolData.assetLookup[getDataParams.collateralAsset];
    DataTypes.AssetData storage debtAssetData = poolData.assetLookup[getDataParams.debtAsset];

    vars.userAccountResult = GenericLogic.calculateUserAccountDataForLiquidate(
      poolData,
      getDataParams.borrower,
      getDataParams.collateralAsset,
      vars.priceOracle
    );
    if (vars.userAccountResult.healthFactor >= Constants.HEALTH_FACTOR_LIQUIDATION_THRESHOLD) {
      return (0, 0);
    }

    if (collateralAssetData.assetType == Constants.ASSET_TYPE_ERC20) {
      InputTypes.ExecuteCrossLiquidateERC20Params memory erc20Params;
      erc20Params.borrower = getDataParams.borrower;
      erc20Params.debtToCover = getDataParams.debtAmount;

      (vars.userTotalDebt, vars.actualDebtToLiquidate) = _calculateUserERC20Debt(
        poolData,
        debtAssetData,
        erc20Params,
        vars.userAccountResult.healthFactor
      );

      vars.userCollateralBalance = VaultLogic.erc20GetUserCrossSupply(
        collateralAssetData,
        erc20Params.borrower,
        collateralAssetData.supplyIndex
      );

      (vars.actualCollateralToLiquidate, vars.actualDebtToLiquidate) = _calculateAvailableERC20CollateralToLiquidate(
        collateralAssetData,
        debtAssetData,
        vars.actualDebtToLiquidate,
        vars.userCollateralBalance,
        IPriceOracleGetter(vars.priceOracle)
      );
    } else if (collateralAssetData.assetType == Constants.ASSET_TYPE_ERC721) {
      InputTypes.ExecuteCrossLiquidateERC721Params memory erc721Params;
      erc721Params.borrower = getDataParams.borrower;
      erc721Params.collateralAsset = getDataParams.collateralAsset;
      erc721Params.collateralTokenIds = new uint256[](getDataParams.collateralAmount);
      erc721Params.debtAsset = getDataParams.debtAsset;

      vars.userCollateralBalance = VaultLogic.erc721GetUserCrossSupply(collateralAssetData, erc721Params.borrower);

      LiquidateERC721LocalVars memory liqVars;
      liqVars.userAccountResult = vars.userAccountResult;
      liqVars.userCollateralBalance = vars.userCollateralBalance;

      (vars.actualCollateralToLiquidate, vars.actualDebtToLiquidate) = _calculateDebtAmountFromERC721Collateral(
        collateralAssetData,
        debtAssetData,
        erc721Params,
        liqVars,
        IPriceOracleGetter(vars.priceOracle)
      );
    }

    return (vars.actualCollateralToLiquidate, vars.actualDebtToLiquidate);
  }
}
