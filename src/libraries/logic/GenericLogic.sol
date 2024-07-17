// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

import {IPriceOracleGetter} from '../../interfaces/IPriceOracleGetter.sol';

import {PercentageMath} from '../math/PercentageMath.sol';
import {WadRayMath} from '../math/WadRayMath.sol';
import {DataTypes} from '../types/DataTypes.sol';
import {ResultTypes} from '../types/ResultTypes.sol';
import {Constants} from '../helpers/Constants.sol';
import {Errors} from '../helpers/Errors.sol';

import {VaultLogic} from './VaultLogic.sol';
import {InterestLogic} from './InterestLogic.sol';

/**
 * @title GenericLogic library
 * @notice Implements protocol-level logic to calculate and validate the state of a user
 */
library GenericLogic {
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
  using WadRayMath for uint256;
  using PercentageMath for uint256;

  function calculateUserAccountDataForHeathFactor(
    DataTypes.PoolData storage poolData,
    address userAccount,
    address oracle
  ) internal view returns (ResultTypes.UserAccountResult memory result) {
    result = calculateUserAccountData(poolData, userAccount, address(0), oracle);
  }

  function calculateUserAccountDataForBorrow(
    DataTypes.PoolData storage poolData,
    address userAccount,
    address oracle
  ) internal view returns (ResultTypes.UserAccountResult memory result) {
    result = calculateUserAccountData(poolData, userAccount, address(0), oracle);
  }

  function calculateUserAccountDataForLiquidate(
    DataTypes.PoolData storage poolData,
    address userAccount,
    address liquidateCollateral,
    address oracle
  ) internal view returns (ResultTypes.UserAccountResult memory result) {
    result = calculateUserAccountData(poolData, userAccount, liquidateCollateral, oracle);
  }

  struct CalculateUserAccountDataVars {
    address[] userSuppliedAssets;
    address[] userBorrowedAssets;
    uint256 assetIndex;
    address currentAssetAddress;
    uint256[] assetGroupIds;
    uint256 groupIndex;
    uint8 currentGroupId;
    uint256 assetPrice;
    uint256 userBalanceInBaseCurrency;
    uint256 userAssetDebtInBaseCurrency;
    uint256 userGroupDebtInBaseCurrency;
    uint256 liquidateCollateralInBaseCurrency;
  }

  /**
   * @notice Calculates the user data across the reserves.
   * @dev It includes the total liquidity/collateral/borrow balances in the base currency used by the price feed,
   * the average Loan To Value, the average Liquidation Ratio, and the Health factor.
   */
  function calculateUserAccountData(
    DataTypes.PoolData storage poolData,
    address userAccount,
    address collateralAsset,
    address oracle
  ) internal view returns (ResultTypes.UserAccountResult memory result) {
    CalculateUserAccountDataVars memory vars;
    DataTypes.AccountData storage accountData = poolData.accountLookup[userAccount];

    result.allGroupsCollateralInBaseCurrency = new uint256[](Constants.MAX_NUMBER_OF_GROUP);
    result.allGroupsDebtInBaseCurrency = new uint256[](Constants.MAX_NUMBER_OF_GROUP);
    result.allGroupsAvgLtv = new uint256[](Constants.MAX_NUMBER_OF_GROUP);
    result.allGroupsAvgLiquidationThreshold = new uint256[](Constants.MAX_NUMBER_OF_GROUP);

    // calculate the sum of all the collateral balance denominated in the base currency
    vars.userSuppliedAssets = VaultLogic.accountGetSuppliedAssets(accountData);
    for (vars.assetIndex = 0; vars.assetIndex < vars.userSuppliedAssets.length; vars.assetIndex++) {
      vars.currentAssetAddress = vars.userSuppliedAssets[vars.assetIndex];
      if (vars.currentAssetAddress == address(0)) {
        continue;
      }

      DataTypes.AssetData storage currentAssetData = poolData.assetLookup[vars.currentAssetAddress];

      vars.assetPrice = IPriceOracleGetter(oracle).getAssetPrice(vars.currentAssetAddress);

      if (currentAssetData.liquidationThreshold != 0) {
        if (currentAssetData.assetType == Constants.ASSET_TYPE_ERC20) {
          vars.userBalanceInBaseCurrency = _getUserERC20BalanceInBaseCurrency(
            userAccount,
            currentAssetData,
            vars.assetPrice
          );
        } else if (currentAssetData.assetType == Constants.ASSET_TYPE_ERC721) {
          vars.userBalanceInBaseCurrency = _getUserERC721BalanceInBaseCurrency(
            userAccount,
            currentAssetData,
            vars.assetPrice
          );
        } else {
          revert(Errors.INVALID_ASSET_TYPE);
        }

        result.totalCollateralInBaseCurrency += vars.userBalanceInBaseCurrency;

        if (collateralAsset == vars.currentAssetAddress) {
          result.inputCollateralInBaseCurrency += vars.userBalanceInBaseCurrency;
        }

        result.allGroupsCollateralInBaseCurrency[currentAssetData.classGroup] += vars.userBalanceInBaseCurrency;

        if (currentAssetData.collateralFactor != 0) {
          result.avgLtv += vars.userBalanceInBaseCurrency * currentAssetData.collateralFactor;

          result.allGroupsAvgLtv[currentAssetData.classGroup] +=
            vars.userBalanceInBaseCurrency *
            currentAssetData.collateralFactor;
        }

        result.avgLiquidationThreshold += vars.userBalanceInBaseCurrency * currentAssetData.liquidationThreshold;

        result.allGroupsAvgLiquidationThreshold[currentAssetData.classGroup] +=
          vars.userBalanceInBaseCurrency *
          currentAssetData.liquidationThreshold;
      }
    }

    // calculate the sum of all the debt balance denominated in the base currency
    vars.userBorrowedAssets = VaultLogic.accountGetBorrowedAssets(accountData);
    for (vars.assetIndex = 0; vars.assetIndex < vars.userBorrowedAssets.length; vars.assetIndex++) {
      vars.currentAssetAddress = vars.userBorrowedAssets[vars.assetIndex];
      if (vars.currentAssetAddress == address(0)) {
        continue;
      }

      DataTypes.AssetData storage currentAssetData = poolData.assetLookup[vars.currentAssetAddress];
      require(currentAssetData.assetType == Constants.ASSET_TYPE_ERC20, Errors.ASSET_TYPE_NOT_ERC20);
      vars.assetGroupIds = currentAssetData.groupList.values();

      vars.assetPrice = IPriceOracleGetter(oracle).getAssetPrice(vars.currentAssetAddress);

      // same debt can be borrowed in different groups by different collaterals
      // e.g. BAYC borrow ETH in group 1, MAYC borrow ETH in group 2
      vars.userAssetDebtInBaseCurrency = 0;
      for (vars.groupIndex = 0; vars.groupIndex < vars.assetGroupIds.length; vars.groupIndex++) {
        vars.currentGroupId = uint8(vars.assetGroupIds[vars.groupIndex]);
        DataTypes.GroupData storage currentGroupData = currentAssetData.groupLookup[vars.currentGroupId];

        vars.userGroupDebtInBaseCurrency = _getUserERC20DebtInBaseCurrency(
          userAccount,
          currentAssetData,
          currentGroupData,
          vars.assetPrice
        );

        vars.userAssetDebtInBaseCurrency += vars.userGroupDebtInBaseCurrency;

        result.allGroupsDebtInBaseCurrency[vars.currentGroupId] += vars.userGroupDebtInBaseCurrency;
      }

      result.totalDebtInBaseCurrency += vars.userAssetDebtInBaseCurrency;
      if (vars.userAssetDebtInBaseCurrency > result.highestDebtInBaseCurrency) {
        result.highestDebtInBaseCurrency = vars.userAssetDebtInBaseCurrency;
        result.highestDebtAsset = vars.currentAssetAddress;
      }
    }

    // calculate the average LTV and Liquidation threshold based on the account
    if (result.totalCollateralInBaseCurrency != 0) {
      result.avgLtv = result.avgLtv / result.totalCollateralInBaseCurrency;
      result.avgLiquidationThreshold = result.avgLiquidationThreshold / result.totalCollateralInBaseCurrency;
    } else {
      result.avgLtv = 0;
      result.avgLiquidationThreshold = 0;
    }

    // calculate the average LTV and Liquidation threshold based on the group
    for (vars.groupIndex = 0; vars.groupIndex < Constants.MAX_NUMBER_OF_GROUP; vars.groupIndex++) {
      if (result.allGroupsCollateralInBaseCurrency[vars.groupIndex] != 0) {
        result.allGroupsAvgLtv[vars.groupIndex] =
          result.allGroupsAvgLtv[vars.groupIndex] /
          result.allGroupsCollateralInBaseCurrency[vars.groupIndex];

        result.allGroupsAvgLiquidationThreshold[vars.groupIndex] =
          result.allGroupsAvgLiquidationThreshold[vars.groupIndex] /
          result.allGroupsCollateralInBaseCurrency[vars.groupIndex];
      } else {
        result.allGroupsAvgLtv[vars.groupIndex] = 0;
        result.allGroupsAvgLiquidationThreshold[vars.groupIndex] = 0;
      }
    }

    // calculate the health factor
    result.healthFactor = calculateHealthFactorFromBalances(
      result.totalCollateralInBaseCurrency,
      result.totalDebtInBaseCurrency,
      result.avgLiquidationThreshold
    );
  }

  /**
   * @dev Calculates the nft loan data.
   **/
  function calculateNftLoanData(
    DataTypes.AssetData storage debtAssetData,
    DataTypes.GroupData storage debtGroupData,
    DataTypes.AssetData storage nftAssetData,
    DataTypes.IsolateLoanData storage nftLoanData,
    address oracle
  ) internal view returns (ResultTypes.NftLoanResult memory result) {
    // query debt asset and nft price fromo oracle
    result.debtAssetPriceInBaseCurrency = IPriceOracleGetter(oracle).getAssetPrice(debtAssetData.underlyingAsset);
    result.nftAssetPriceInBaseCurrency = IPriceOracleGetter(oracle).getAssetPrice(nftAssetData.underlyingAsset);

    // calculate total collateral balance for the nft
    result.totalCollateralInBaseCurrency = result.nftAssetPriceInBaseCurrency;

    // calculate total borrow balance for the loan
    result.totalDebtInBaseCurrency = _getNftLoanDebtInBaseCurrency(
      debtAssetData,
      debtGroupData,
      nftLoanData,
      result.debtAssetPriceInBaseCurrency
    );

    // calculate health by borrow and collateral
    result.healthFactor = calculateHealthFactorFromBalances(
      result.totalCollateralInBaseCurrency,
      result.totalDebtInBaseCurrency,
      nftAssetData.liquidationThreshold
    );
  }

  struct CaculateNftLoanLiquidatePriceVars {
    uint256 nftAssetPriceInBaseCurrency;
    uint256 debtAssetPriceInBaseCurrency;
    uint256 normalizedIndex;
    uint256 borrowAmount;
    uint256 thresholdPrice;
    uint256 liquidatePrice;
  }

  function calculateNftLoanLiquidatePrice(
    DataTypes.AssetData storage debtAssetData,
    DataTypes.GroupData storage debtGroupData,
    DataTypes.AssetData storage nftAssetData,
    DataTypes.IsolateLoanData storage nftLoanData,
    address oracle
  ) internal view returns (uint256, uint256, uint256) {
    CaculateNftLoanLiquidatePriceVars memory vars;

    /*
     * 0                   CR                  LH                  100
     * |___________________|___________________|___________________|
     *  <       Borrowing with Interest        <
     * CR: Callteral Ratio;
     * LH: Liquidate Threshold;
     * Liquidate Trigger: Borrowing with Interest > thresholdPrice;
     * Liquidate Price: (100% - BonusRatio) * NFT Price;
     */

    // query debt asset and nft price fromo oracle
    vars.debtAssetPriceInBaseCurrency = IPriceOracleGetter(oracle).getAssetPrice(debtAssetData.underlyingAsset);
    vars.nftAssetPriceInBaseCurrency = IPriceOracleGetter(oracle).getAssetPrice(nftAssetData.underlyingAsset);

    vars.normalizedIndex = InterestLogic.getNormalizedBorrowDebt(debtAssetData, debtGroupData);
    vars.borrowAmount = nftLoanData.scaledAmount.rayMul(vars.normalizedIndex);

    vars.thresholdPrice = vars.nftAssetPriceInBaseCurrency.percentMul(nftAssetData.liquidationThreshold);
    vars.thresholdPrice =
      (vars.thresholdPrice * (10 ** debtAssetData.underlyingDecimals)) /
      vars.debtAssetPriceInBaseCurrency;

    if (nftAssetData.liquidationBonus < PercentageMath.PERCENTAGE_FACTOR) {
      vars.liquidatePrice = vars.nftAssetPriceInBaseCurrency.percentMul(
        PercentageMath.PERCENTAGE_FACTOR - nftAssetData.liquidationBonus
      );
      vars.liquidatePrice =
        (vars.liquidatePrice * (10 ** debtAssetData.underlyingDecimals)) /
        vars.debtAssetPriceInBaseCurrency;
    }

    if (vars.liquidatePrice < vars.borrowAmount) {
      vars.liquidatePrice = vars.borrowAmount;
    }

    return (vars.borrowAmount, vars.thresholdPrice, vars.liquidatePrice);
  }

  struct CalculateNftLoanBidFineVars {
    uint256 nftBaseCurrencyPriceInBaseCurrency;
    uint256 minBidFineInBaseCurrency;
    uint256 minBidFineAmount;
    uint256 debtAssetPriceInBaseCurrency;
    uint256 normalizedIndex;
    uint256 borrowAmount;
    uint256 bidFineAmount;
  }

  function calculateNftLoanBidFine(
    DataTypes.AssetData storage debtAssetData,
    DataTypes.GroupData storage debtGroupData,
    DataTypes.AssetData storage nftAssetData,
    DataTypes.IsolateLoanData storage nftLoanData,
    address oracle
  ) internal view returns (uint256, uint256) {
    CalculateNftLoanBidFineVars memory vars;

    // query debt asset and nft price fromo oracle
    vars.debtAssetPriceInBaseCurrency = IPriceOracleGetter(oracle).getAssetPrice(debtAssetData.underlyingAsset);

    // calculate the min bid fine based on the base currency, e.g. ETH
    vars.nftBaseCurrencyPriceInBaseCurrency = IPriceOracleGetter(oracle).getAssetPrice(
      IPriceOracleGetter(oracle).NFT_BASE_CURRENCY()
    );
    vars.minBidFineInBaseCurrency = vars.nftBaseCurrencyPriceInBaseCurrency.percentMul(nftAssetData.minBidFineFactor);
    vars.minBidFineAmount =
      (vars.minBidFineInBaseCurrency * (10 ** debtAssetData.underlyingDecimals)) /
      vars.debtAssetPriceInBaseCurrency;

    // calculate the bid fine based on the borrow amount
    vars.normalizedIndex = InterestLogic.getNormalizedBorrowDebt(debtAssetData, debtGroupData);
    vars.borrowAmount = nftLoanData.scaledAmount.rayMul(vars.normalizedIndex);
    vars.bidFineAmount = vars.borrowAmount.percentMul(nftAssetData.bidFineFactor);

    if (vars.bidFineAmount < vars.minBidFineAmount) {
      vars.bidFineAmount = vars.minBidFineAmount;
    }

    return (vars.minBidFineAmount, vars.bidFineAmount);
  }

  /**
   * @dev Calculates the health factor from the corresponding balances
   **/
  function calculateHealthFactorFromBalances(
    uint256 totalCollateral,
    uint256 totalDebt,
    uint256 liquidationThreshold
  ) internal pure returns (uint256) {
    if (totalDebt == 0) return type(uint256).max;

    return (totalCollateral.percentMul(liquidationThreshold)).wadDiv(totalDebt);
  }

  /**
   * @notice Calculates the maximum amount that can be borrowed depending on the available collateral, the total debt
   * and the average Loan To Value
   */
  function calculateAvailableBorrows(
    uint256 totalCollateralInBaseCurrency,
    uint256 totalDebtInBaseCurrency,
    uint256 ltv
  ) internal pure returns (uint256) {
    uint256 availableBorrowsInBaseCurrency = totalCollateralInBaseCurrency.percentMul(ltv);

    if (availableBorrowsInBaseCurrency < totalDebtInBaseCurrency) {
      return 0;
    }

    availableBorrowsInBaseCurrency = availableBorrowsInBaseCurrency - totalDebtInBaseCurrency;
    return availableBorrowsInBaseCurrency;
  }

  /**
   * @notice Calculates total debt of the user in the based currency used to normalize the values of the assets
   */
  function _getUserERC20DebtInBaseCurrency(
    address userAccount,
    DataTypes.AssetData storage assetData,
    DataTypes.GroupData storage groupData,
    uint256 assetPrice
  ) private view returns (uint256) {
    // fetching variable debt
    uint256 userTotalDebt = groupData.userScaledCrossBorrow[userAccount];
    if (userTotalDebt != 0) {
      uint256 normalizedIndex = InterestLogic.getNormalizedBorrowDebt(assetData, groupData);
      userTotalDebt = userTotalDebt.rayMul(normalizedIndex);
      userTotalDebt = assetPrice * userTotalDebt;
    }

    return userTotalDebt / (10 ** assetData.underlyingDecimals);
  }

  /**
   * @notice Calculates total balance of the user in the based currency used by the price oracle
   * @return The total balance of the user normalized to the base currency of the price oracle
   */
  function _getUserERC20BalanceInBaseCurrency(
    address userAccount,
    DataTypes.AssetData storage assetData,
    uint256 assetPrice
  ) private view returns (uint256) {
    uint256 userTotalBalance = assetData.userScaledCrossSupply[userAccount];
    if (userTotalBalance != 0) {
      uint256 normalizedIndex = InterestLogic.getNormalizedSupplyIncome(assetData);
      userTotalBalance = userTotalBalance.rayMul(normalizedIndex);
      userTotalBalance = assetPrice * userTotalBalance;
    }

    return userTotalBalance / (10 ** assetData.underlyingDecimals);
  }

  function _getUserERC721BalanceInBaseCurrency(
    address userAccount,
    DataTypes.AssetData storage assetData,
    uint256 assetPrice
  ) private view returns (uint256) {
    uint256 userTotalBalance = assetData.userScaledCrossSupply[userAccount];
    if (userTotalBalance != 0) {
      userTotalBalance = assetPrice * userTotalBalance;
    }

    return userTotalBalance;
  }

  function _getNftLoanDebtInBaseCurrency(
    DataTypes.AssetData storage debtAssetData,
    DataTypes.GroupData storage debtGroupData,
    DataTypes.IsolateLoanData storage nftLoanData,
    uint256 debtAssetPrice
  ) private view returns (uint256) {
    uint256 loanDebtAmount;

    if (nftLoanData.scaledAmount > 0) {
      uint256 normalizedIndex = InterestLogic.getNormalizedBorrowDebt(debtAssetData, debtGroupData);
      loanDebtAmount = nftLoanData.scaledAmount.rayMul(normalizedIndex);

      loanDebtAmount = debtAssetPrice * loanDebtAmount;
      loanDebtAmount = loanDebtAmount / (10 ** debtAssetData.underlyingDecimals);
    }

    return loanDebtAmount;
  }
}
