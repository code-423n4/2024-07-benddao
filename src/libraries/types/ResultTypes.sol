// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library ResultTypes {
    struct UserAccountResult {
      uint256 totalCollateralInBaseCurrency;
      uint256 totalDebtInBaseCurrency;
      uint256 avgLtv;
      uint256 avgLiquidationThreshold;
      uint256 healthFactor;
      uint256[] allGroupsCollateralInBaseCurrency;
      uint256[] allGroupsDebtInBaseCurrency;
      uint256[] allGroupsAvgLtv;
      uint256[] allGroupsAvgLiquidationThreshold;
      uint256 inputCollateralInBaseCurrency;
      address highestDebtAsset;
      uint256 highestDebtInBaseCurrency;
    }

    struct NftLoanResult {
      uint256 totalCollateralInBaseCurrency;
      uint256 totalDebtInBaseCurrency;
      uint256 healthFactor;
      uint256 debtAssetPriceInBaseCurrency;
      uint256 nftAssetPriceInBaseCurrency;
    }
}