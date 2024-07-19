// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

import {IAddressProvider} from '../../interfaces/IAddressProvider.sol';
import {IPriceOracleGetter} from '../..//interfaces/IPriceOracleGetter.sol';
import {IDelegateRegistryV2} from 'src/interfaces/IDelegateRegistryV2.sol';

import {Constants} from '../helpers/Constants.sol';
import {Errors} from '../helpers/Errors.sol';
import {Events} from '../helpers/Events.sol';

import {InputTypes} from '../types/InputTypes.sol';
import {DataTypes} from '../types/DataTypes.sol';
import {ResultTypes} from '../types/ResultTypes.sol';

import {WadRayMath} from '../math/WadRayMath.sol';
import {PercentageMath} from '../math/PercentageMath.sol';

import {StorageSlot} from './StorageSlot.sol';
import {VaultLogic} from './VaultLogic.sol';
import {GenericLogic} from './GenericLogic.sol';
import {InterestLogic} from './InterestLogic.sol';

library QueryLogic {
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
  using WadRayMath for uint256;
  using PercentageMath for uint256;

  function getPoolMaxAssetNumber() internal pure returns (uint256) {
    return Constants.MAX_NUMBER_OF_ASSET;
  }

  function getPoolMaxGroupNumber() internal pure returns (uint256) {
    return Constants.MAX_NUMBER_OF_GROUP;
  }

  function getPoolList() internal view returns (uint256[] memory) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    return ps.poolList.values();
  }

  function getPoolName(uint32 poolId) internal view returns (string memory) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    return poolData.name;
  }

  function getPoolConfigFlag(
    uint32 poolId
  ) internal view returns (bool isPaused, bool isYieldEnabled, bool isYieldPaused, uint8 yieldGroup) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];

    return (poolData.isPaused, poolData.isYieldEnabled, poolData.isYieldPaused, poolData.yieldGroup);
  }

  function getPoolGroupList(uint32 poolId) internal view returns (uint256[] memory groupIds) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];

    uint256[] memory poolAllGroupIds = poolData.groupList.values();
    uint256 groupNum;
    for (uint256 i = 0; i < poolAllGroupIds.length; i++) {
      if ((poolAllGroupIds[i] >= Constants.GROUP_ID_LEND_MIN) && (poolAllGroupIds[i] <= Constants.GROUP_ID_LEND_MAX)) {
        groupNum++;
      }
    }

    groupIds = new uint256[](groupNum);
    uint256 retIdx;
    for (uint256 i = 0; i < poolAllGroupIds.length; i++) {
      if ((poolAllGroupIds[i] >= Constants.GROUP_ID_LEND_MIN) && (poolAllGroupIds[i] <= Constants.GROUP_ID_LEND_MAX)) {
        groupIds[retIdx++] = poolAllGroupIds[i];
      }
    }

    return groupIds;
  }

  function getPoolAssetList(uint32 poolId) internal view returns (address[] memory assets, uint8[] memory types) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];

    assets = poolData.assetList.values();
    types = new uint8[](assets.length);

    for (uint i = 0; i < assets.length; i++) {
      DataTypes.AssetData storage assetData = poolData.assetLookup[assets[i]];
      types[i] = assetData.assetType;
    }
  }

  function getAssetGroupList(uint32 poolId, address asset) internal view returns (uint256[] memory) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];

    return assetData.groupList.values();
  }

  function getAssetConfigFlag(
    uint32 poolId,
    address asset
  )
    internal
    view
    returns (
      bool isActive,
      bool isFrozen,
      bool isPaused,
      bool isBorrowingEnabled,
      bool isYieldEnabled,
      bool isYieldPaused
    )
  {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];

    return (
      assetData.isActive,
      assetData.isFrozen,
      assetData.isPaused,
      assetData.isBorrowingEnabled,
      assetData.isYieldEnabled,
      assetData.isYieldPaused
    );
  }

  function getAssetConfigCap(
    uint32 poolId,
    address asset
  ) internal view returns (uint256 supplyCap, uint256 borrowCap, uint256 yieldCap) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];

    return (assetData.supplyCap, assetData.borrowCap, assetData.yieldCap);
  }

  function getAssetLendingConfig(
    uint32 poolId,
    address asset
  )
    internal
    view
    returns (
      uint8 classGroup,
      uint16 feeFactor,
      uint16 collateralFactor,
      uint16 liquidationThreshold,
      uint16 liquidationBonus
    )
  {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];

    return (
      assetData.classGroup,
      assetData.feeFactor,
      assetData.collateralFactor,
      assetData.liquidationThreshold,
      assetData.liquidationBonus
    );
  }

  function getAssetAuctionConfig(
    uint32 poolId,
    address asset
  )
    internal
    view
    returns (uint16 redeemThreshold, uint16 bidFineFactor, uint16 minBidFineFactor, uint40 auctionDuration)
  {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];

    return (assetData.redeemThreshold, assetData.bidFineFactor, assetData.minBidFineFactor, assetData.auctionDuration);
  }

  function getAssetSupplyData(
    uint32 poolId,
    address asset
  )
    internal
    view
    returns (
      uint256 totalScaledCrossSupply,
      uint256 totalCrossSupply,
      uint256 totalScaledIsolateSupply,
      uint256 totalIsolateSupply,
      uint256 availableSupply,
      uint256 supplyRate,
      uint256 supplyIndex,
      uint256 lastUpdateTimestamp
    )
  {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];

    if (assetData.assetType == Constants.ASSET_TYPE_ERC20) {
      totalScaledCrossSupply = VaultLogic.erc20GetTotalScaledCrossSupply(assetData);
      totalScaledIsolateSupply = VaultLogic.erc20GetTotalScaledIsolateSupply(assetData);

      uint256 index = InterestLogic.getNormalizedSupplyIncome(assetData);
      totalCrossSupply = VaultLogic.erc20GetTotalCrossSupply(assetData, index);
      totalIsolateSupply = VaultLogic.erc20GetTotalIsolateSupply(assetData, index);
    } else if (assetData.assetType == Constants.ASSET_TYPE_ERC721) {
      totalScaledCrossSupply = totalCrossSupply = VaultLogic.erc721GetTotalCrossSupply(assetData);
      totalScaledIsolateSupply = totalIsolateSupply = VaultLogic.erc721GetTotalIsolateSupply(assetData);
    }

    availableSupply = assetData.availableLiquidity;
    supplyRate = assetData.supplyRate;
    supplyIndex = assetData.supplyIndex;
    lastUpdateTimestamp = assetData.lastUpdateTimestamp;
  }

  function getAssetGroupData(
    uint32 poolId,
    address asset,
    uint8 group
  )
    internal
    view
    returns (
      uint256 totalScaledCrossBorrow,
      uint256 totalCrossBorrow,
      uint256 totalScaledIsolateBorrow,
      uint256 totalIsolateBorrow,
      uint256 borrowRate,
      uint256 borrowIndex,
      address rateModel
    )
  {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];
    DataTypes.GroupData storage groupData = assetData.groupLookup[group];

    if (assetData.assetType == Constants.ASSET_TYPE_ERC20) {
      totalScaledCrossBorrow = VaultLogic.erc20GetTotalScaledCrossBorrowInGroup(groupData);
      totalScaledIsolateBorrow = VaultLogic.erc20GetTotalScaledIsolateBorrowInGroup(groupData);

      uint256 index = InterestLogic.getNormalizedBorrowDebt(assetData, groupData);
      totalCrossBorrow = VaultLogic.erc20GetTotalCrossBorrowInGroup(groupData, index);
      totalIsolateBorrow = VaultLogic.erc20GetTotalIsolateBorrowInGroup(groupData, index);

      borrowRate = groupData.borrowRate;
      borrowIndex = groupData.borrowIndex;
      rateModel = groupData.rateModel;
    }
  }

  function getAssetFeeData(
    uint32 poolId,
    address asset
  ) internal view returns (uint256 feeFactor, uint256 accruedFee, uint256 normAccruedFee) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];

    uint256 index = InterestLogic.getNormalizedSupplyIncome(assetData);
    accruedFee = assetData.accruedFee;
    normAccruedFee = accruedFee.rayMul(index);
    return (assetData.feeFactor, accruedFee, normAccruedFee);
  }

  function getUserAccountData(
    address user,
    uint32 poolId
  )
    internal
    view
    returns (
      uint256 totalCollateralInBase,
      uint256 totalBorrowInBase,
      uint256 availableBorrowInBase,
      uint256 avgLtv,
      uint256 avgLiquidationThreshold,
      uint256 healthFactor
    )
  {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];

    ResultTypes.UserAccountResult memory result = GenericLogic.calculateUserAccountDataForHeathFactor(
      poolData,
      user,
      IAddressProvider(ps.addressProvider).getPriceOracle()
    );

    totalCollateralInBase = result.totalCollateralInBaseCurrency;
    totalBorrowInBase = result.totalDebtInBaseCurrency;

    availableBorrowInBase = GenericLogic.calculateAvailableBorrows(
      totalCollateralInBase,
      totalBorrowInBase,
      result.avgLtv
    );

    avgLtv = result.avgLtv;
    avgLiquidationThreshold = result.avgLiquidationThreshold;
    healthFactor = result.healthFactor;
  }

  struct GetUserAccountDataLocalVars {
    address oracle;
    uint256 assetPrice;
    uint256 assetUnit;
    uint256 assetValueInBase;
  }

  function getUserAccountDataForCalculation(
    address user,
    uint32 poolId,
    uint8 calcType,
    address asset,
    uint256 amount
  )
    internal
    view
    returns (
      uint256 totalCollateralInBase,
      uint256 totalBorrowInBase,
      uint256 availableBorrowInBase,
      uint256 avgLtv,
      uint256 avgLiquidationThreshold,
      uint256 healthFactor
    )
  {
    GetUserAccountDataLocalVars memory vars;
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];

    (
      totalCollateralInBase,
      totalBorrowInBase,
      availableBorrowInBase,
      avgLtv,
      avgLiquidationThreshold,
      healthFactor
    ) = getUserAccountData(user, poolId);

    vars.oracle = IAddressProvider(ps.addressProvider).getPriceOracle();
    vars.assetPrice = IPriceOracleGetter(vars.oracle).getAssetPrice(asset);
    if (assetData.assetType == Constants.ASSET_TYPE_ERC20) {
      vars.assetUnit = 10 ** assetData.underlyingDecimals;
    } else {
      vars.assetUnit = 1;
    }
    vars.assetValueInBase = (vars.assetPrice * amount) / vars.assetUnit;

    avgLtv = avgLtv * totalCollateralInBase;
    avgLiquidationThreshold = avgLiquidationThreshold * totalCollateralInBase;

    if (calcType == 1) {
      // supply
      avgLtv = avgLtv + (vars.assetValueInBase * assetData.collateralFactor);
      avgLiquidationThreshold = avgLiquidationThreshold + (vars.assetValueInBase * assetData.liquidationThreshold);

      totalCollateralInBase += vars.assetValueInBase;
    } else if (calcType == 2) {
      // withdraw
      avgLtv = avgLtv - (vars.assetValueInBase * assetData.collateralFactor);
      avgLiquidationThreshold = avgLiquidationThreshold - (vars.assetValueInBase * assetData.liquidationThreshold);

      if (totalCollateralInBase > vars.assetValueInBase) {
        totalCollateralInBase -= vars.assetValueInBase;
      } else {
        totalCollateralInBase = 0;
      }
    } else if (calcType == 3) {
      // borrow
      totalBorrowInBase += vars.assetValueInBase;
    } else if (calcType == 4) {
      // repay
      if (totalBorrowInBase > vars.assetValueInBase) {
        totalBorrowInBase -= vars.assetValueInBase;
      } else {
        totalBorrowInBase = 0;
      }
    }

    if (totalCollateralInBase == 0) {
      avgLtv = 0;
      avgLiquidationThreshold = 0;
    } else {
      avgLtv = avgLtv / totalCollateralInBase;
      avgLiquidationThreshold = avgLiquidationThreshold / totalCollateralInBase;
    }

    availableBorrowInBase = GenericLogic.calculateAvailableBorrows(totalCollateralInBase, totalBorrowInBase, avgLtv);

    healthFactor = GenericLogic.calculateHealthFactorFromBalances(
      totalCollateralInBase,
      totalBorrowInBase,
      avgLiquidationThreshold
    );
  }

  struct GetUserAssetDataLocalVars {
    uint256 aidx;
    uint256 gidx;
    uint256[] assetGroupIds;
    uint256 index;
  }

  function getUserAssetData(
    address user,
    uint32 poolId,
    address asset
  )
    internal
    view
    returns (uint256 totalCrossSupply, uint256 totalIsolateSupply, uint256 totalCrossBorrow, uint256 totalIsolateBorrow)
  {
    GetUserAssetDataLocalVars memory vars;

    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];

    vars.assetGroupIds = assetData.groupList.values();

    if (assetData.assetType == Constants.ASSET_TYPE_ERC20) {
      vars.index = InterestLogic.getNormalizedSupplyIncome(assetData);
      totalCrossSupply = VaultLogic.erc20GetUserCrossSupply(assetData, user, vars.index);

      for (vars.gidx = 0; vars.gidx < vars.assetGroupIds.length; vars.gidx++) {
        DataTypes.GroupData storage groupData = assetData.groupLookup[uint8(vars.assetGroupIds[vars.gidx])];
        vars.index = InterestLogic.getNormalizedBorrowDebt(assetData, groupData);
        totalCrossBorrow += VaultLogic.erc20GetUserCrossBorrowInGroup(groupData, user, vars.index);
        totalIsolateBorrow += VaultLogic.erc20GetUserIsolateBorrowInGroup(groupData, user, vars.index);
      }
    } else if (assetData.assetType == Constants.ASSET_TYPE_ERC721) {
      totalCrossSupply = VaultLogic.erc721GetUserCrossSupply(assetData, user);
      totalIsolateSupply = VaultLogic.erc721GetUserIsolateSupply(assetData, user);
    }
  }

  function getUserAssetScaledData(
    address user,
    uint32 poolId,
    address asset
  )
    internal
    view
    returns (
      uint256 totalScaledCrossSupply,
      uint256 totalScaledIsolateSupply,
      uint256 totalScaledCrossBorrow,
      uint256 totalScaledIsolateBorrow
    )
  {
    GetUserAssetDataLocalVars memory vars;

    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];

    vars.assetGroupIds = assetData.groupList.values();

    if (assetData.assetType == Constants.ASSET_TYPE_ERC20) {
      totalScaledCrossSupply = VaultLogic.erc20GetUserScaledCrossSupply(assetData, user);

      for (vars.gidx = 0; vars.gidx < vars.assetGroupIds.length; vars.gidx++) {
        DataTypes.GroupData storage groupData = assetData.groupLookup[uint8(vars.assetGroupIds[vars.gidx])];
        totalScaledCrossBorrow += VaultLogic.erc20GetUserScaledCrossBorrowInGroup(groupData, user);
        totalScaledIsolateBorrow += VaultLogic.erc20GetUserScaledIsolateBorrowInGroup(groupData, user);
      }
    } else if (assetData.assetType == Constants.ASSET_TYPE_ERC721) {
      totalScaledCrossSupply = VaultLogic.erc721GetUserCrossSupply(assetData, user);
      totalScaledIsolateSupply = VaultLogic.erc721GetUserIsolateSupply(assetData, user);
    }
  }

  function getUserAssetGroupData(
    address user,
    uint32 poolId,
    address asset,
    uint8 groupId
  )
    internal
    view
    returns (
      uint256 totalScaledCrossBorrow,
      uint256 totalCrossBorrow,
      uint256 totalScaledIsolateBorrow,
      uint256 totalIsolateBorrow
    )
  {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];
    DataTypes.GroupData storage groupData = assetData.groupLookup[groupId];

    totalScaledCrossBorrow = VaultLogic.erc20GetUserScaledCrossBorrowInGroup(groupData, user);
    totalScaledIsolateBorrow = VaultLogic.erc20GetUserScaledIsolateBorrowInGroup(groupData, user);

    uint256 index = InterestLogic.getNormalizedBorrowDebt(assetData, groupData);
    totalCrossBorrow = VaultLogic.erc20GetUserCrossBorrowInGroup(groupData, user, index);
    totalIsolateBorrow = VaultLogic.erc20GetUserIsolateBorrowInGroup(groupData, user, index);
  }

  function getUserAccountGroupData(
    address user,
    uint32 poolId
  )
    internal
    view
    returns (
      uint256[] memory groupsIds,
      uint256[] memory groupsCollateralInBase,
      uint256[] memory groupsBorrowInBase,
      uint256[] memory groupsAvailableBorrowInBase
    )
  {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];

    ResultTypes.UserAccountResult memory result = GenericLogic.calculateUserAccountDataForHeathFactor(
      poolData,
      user,
      IAddressProvider(ps.addressProvider).getPriceOracle()
    );

    groupsIds = getPoolGroupList(poolId);

    groupsCollateralInBase = new uint256[](groupsIds.length);
    groupsBorrowInBase = new uint256[](groupsIds.length);
    groupsAvailableBorrowInBase = new uint256[](groupsIds.length);

    uint256 curGroupId;
    for (uint256 i = 0; i < groupsIds.length; i++) {
      curGroupId = groupsIds[i];

      groupsCollateralInBase[i] = result.allGroupsCollateralInBaseCurrency[curGroupId];
      groupsBorrowInBase[i] = result.allGroupsDebtInBaseCurrency[curGroupId];

      groupsAvailableBorrowInBase[i] = GenericLogic.calculateAvailableBorrows(
        result.allGroupsCollateralInBaseCurrency[curGroupId],
        result.allGroupsDebtInBaseCurrency[curGroupId],
        result.allGroupsAvgLtv[curGroupId]
      );
    }
  }

  function getIsolateCollateralData(
    uint32 poolId,
    address nftAsset,
    uint256 tokenId,
    address debtAsset
  )
    internal
    view
    returns (uint256 totalCollateral, uint256 totalBorrow, uint256 availableBorrow, uint256 healthFactor)
  {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];

    DataTypes.AssetData storage nftAssetData = poolData.assetLookup[nftAsset];
    DataTypes.AssetData storage debtAssetData = poolData.assetLookup[debtAsset];
    DataTypes.GroupData storage debtGroupData = debtAssetData.groupLookup[nftAssetData.classGroup];
    DataTypes.IsolateLoanData storage loanData = poolData.loanLookup[nftAsset][tokenId];

    ResultTypes.NftLoanResult memory nftLoanResult = GenericLogic.calculateNftLoanData(
      debtAssetData,
      debtGroupData,
      nftAssetData,
      loanData,
      IAddressProvider(ps.addressProvider).getPriceOracle()
    );

    totalCollateral =
      (nftLoanResult.totalCollateralInBaseCurrency * (10 ** debtAssetData.underlyingDecimals)) /
      nftLoanResult.debtAssetPriceInBaseCurrency;
    totalBorrow =
      (nftLoanResult.totalDebtInBaseCurrency * (10 ** debtAssetData.underlyingDecimals)) /
      nftLoanResult.debtAssetPriceInBaseCurrency;
    availableBorrow = GenericLogic.calculateAvailableBorrows(
      totalCollateral,
      totalBorrow,
      nftAssetData.collateralFactor
    );

    healthFactor = nftLoanResult.healthFactor;
  }

  function getIsolateLoanData(
    uint32 poolId,
    address nftAsset,
    uint256 tokenId
  )
    internal
    view
    returns (address reserveAsset, uint256 scaledAmount, uint256 borrowAmount, uint8 reserveGroup, uint8 loanStatus)
  {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];

    DataTypes.IsolateLoanData storage loanData = poolData.loanLookup[nftAsset][tokenId];
    if (loanData.reserveAsset == address(0)) {
      return (address(0), 0, 0, 0, 0);
    }

    DataTypes.AssetData storage assetData = poolData.assetLookup[loanData.reserveAsset];
    DataTypes.GroupData storage groupData = assetData.groupLookup[loanData.reserveGroup];

    reserveAsset = loanData.reserveAsset;
    scaledAmount = loanData.scaledAmount;
    borrowAmount = scaledAmount.rayMul(InterestLogic.getNormalizedBorrowDebt(assetData, groupData));
    reserveGroup = loanData.reserveGroup;
    loanStatus = loanData.loanStatus;
  }

  function getIsolateAuctionData(
    uint32 poolId,
    address nftAsset,
    uint256 tokenId
  )
    internal
    view
    returns (
      uint40 bidStartTimestamp,
      uint40 bidEndTimestamp,
      address firstBidder,
      address lastBidder,
      uint256 bidAmount,
      uint256 bidFine,
      uint256 redeemAmount
    )
  {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];

    DataTypes.IsolateLoanData storage loanData = poolData.loanLookup[nftAsset][tokenId];
    if (loanData.loanStatus != Constants.LOAN_STATUS_AUCTION) {
      return (0, 0, address(0), address(0), 0, 0, 0);
    }

    DataTypes.AssetData storage nftAssetData = poolData.assetLookup[nftAsset];
    DataTypes.AssetData storage debtAssetData = poolData.assetLookup[loanData.reserveAsset];
    DataTypes.GroupData storage debtGroupData = debtAssetData.groupLookup[loanData.reserveGroup];

    bidStartTimestamp = loanData.bidStartTimestamp;
    bidEndTimestamp = loanData.bidStartTimestamp + nftAssetData.auctionDuration;
    firstBidder = loanData.firstBidder;
    lastBidder = loanData.lastBidder;
    bidAmount = loanData.bidAmount;

    (, bidFine) = GenericLogic.calculateNftLoanBidFine(
      debtAssetData,
      debtGroupData,
      nftAssetData,
      loanData,
      IAddressProvider(ps.addressProvider).getPriceOracle()
    );

    uint256 normalizedIndex = InterestLogic.getNormalizedBorrowDebt(debtAssetData, debtGroupData);
    uint256 borrowAmount = loanData.scaledAmount.rayMul(normalizedIndex);
    redeemAmount = borrowAmount.percentMul(nftAssetData.redeemThreshold);
  }

  function getYieldERC20BorrowBalance(uint32 poolId, address asset, address staker) internal view returns (uint256) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];
    DataTypes.GroupData storage groupData = assetData.groupLookup[poolData.yieldGroup];

    uint256 scaledBalance = VaultLogic.erc20GetUserScaledCrossBorrowInGroup(groupData, staker);
    return scaledBalance.rayMul(InterestLogic.getNormalizedBorrowDebt(assetData, groupData));
  }

  function getERC721TokenData(
    uint32 poolId,
    address asset,
    uint256 tokenId
  ) internal view returns (address, uint8, address) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[asset];

    DataTypes.ERC721TokenData storage tokenData = VaultLogic.erc721GetTokenData(assetData, tokenId);
    return (tokenData.owner, tokenData.supplyMode, tokenData.lockerAddr);
  }

  function getERC721Delegations(
    uint32 /*poolId*/,
    address nftAsset,
    uint256[] calldata tokenIds
  ) internal view returns (address[][] memory) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();

    IDelegateRegistryV2 delegateRegistryV2 = IDelegateRegistryV2(
      IAddressProvider(ps.addressProvider).getDelegateRegistryV2()
    );

    IDelegateRegistryV2.Delegation[] memory allOutDelegations = delegateRegistryV2.getOutgoingDelegations(
      address(this)
    );

    address[][] memory delegateAddrs = new address[][](tokenIds.length);

    for (uint256 i = 0; i < tokenIds.length; i++) {
      // step 1: calculate the array num
      uint256 delegateNum = 0;
      for (uint256 j = 0; j < allOutDelegations.length; j++) {
        if ((allOutDelegations[j].contract_ == nftAsset) && (allOutDelegations[j].tokenId == tokenIds[i])) {
          delegateNum++;
        }
      }

      // step 2: fill the array elements
      delegateAddrs[i] = new address[](delegateNum);
      uint256 addrIdx = 0;
      for (uint256 j = 0; j < allOutDelegations.length; j++) {
        if ((allOutDelegations[j].contract_ == nftAsset) && (allOutDelegations[j].tokenId == tokenIds[i])) {
          delegateAddrs[i][addrIdx] = allOutDelegations[j].to;
          addrIdx++;
        }
      }
    }

    return delegateAddrs;
  }

  function isApprovedForAll(
    uint32 poolId,
    address account,
    address asset,
    address operator
  ) internal view returns (bool) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[poolId];
    return VaultLogic.accountIsApprovedForAll(poolData, account, asset, operator);
  }
}
