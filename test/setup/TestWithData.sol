// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {IERC20Metadata} from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {ERC721} from '@openzeppelin/contracts/token/ERC721/ERC721.sol';

import {WadRayMath} from 'src/libraries/math/WadRayMath.sol';
import {Constants} from 'src/libraries/helpers/Constants.sol';

import {TestWithSetup} from './TestWithSetup.sol';

import '@forge-std/Test.sol';

abstract contract TestWithData is TestWithSetup {
  using WadRayMath for uint256;

  // asset level config
  struct TestAssetConfig {
    uint8 decimals;
    uint8 classGroup;
    uint16 feeFactor;
    uint16 collateralFactor;
    uint16 liquidationThreshold;
    uint16 liquidationBonus;
  }

  // asset level data
  struct TestGroupData {
    uint8 groupId;
    // fields come from contract
    uint256 totalScaledCrossBorrow;
    uint256 totalCrossBorrow;
    uint256 totalScaledIsolateBorrow;
    uint256 totalIsolateBorrow;
    uint256 borrowRate;
    uint256 borrowIndex;
    address rateModel;
    // fields not come from contract
  }

  struct TestAssetData {
    address asset;
    uint8 assetType;
    TestAssetConfig config;
    // fields come from contract
    uint256 totalScaledCrossSupply;
    uint256 totalCrossSupply;
    uint256 totalScaledIsolateSupply;
    uint256 totalIsolateSupply;
    uint256 availableSupply;
    uint256 supplyRate;
    uint256 supplyIndex;
    uint256 lastUpdateTimestamp;
    TestGroupData[] groupsData;
    // fields not come from contract
    uint256 totalScaledCrossBorrow;
    uint256 totalCrossBorrow;
    uint256 totalScaledIsolateBorrow;
    uint256 totalIsolateBorrow;
    uint256 totalLiquidity;
    uint256 utilizationRate;
  }

  // user level data
  struct TestUserGroupData {
    // fields come from contract
    uint256 totalScaledCrossBorrow;
    uint256 totalCrossBorrow;
    uint256 totalScaledIsolateBorrow;
    uint256 totalIsolateBorrow;
    // fields not come from contract
  }

  struct TestUserAssetData {
    address user;
    // fields come from contract
    uint256 walletBalance;
    uint256 totalScaledCrossSupply;
    uint256 totalCrossSupply;
    uint256 totalScaledIsolateSupply;
    uint256 totalIsolateSupply;
    uint256 totalScaledCrossBorrow;
    uint256 totalCrossBorrow;
    uint256 totalScaledIsolateBorrow;
    uint256 totalIsolateBorrow;
    TestUserGroupData[] groupsData;
    // fields not come from contract
  }

  struct TestUserAccountData {
    // fields come from contract
    uint256 totalCollateralInBase;
    uint256 totalBorrowInBase;
    uint256 availableBorrowInBase;
    uint256 currentCollateralFactor;
    uint256 currentLiquidationThreshold;
    uint256 healthFactor;
    // fields not come from contract
  }

  struct TestLoanData {
    address nftAsset;
    uint256 nftTokenId;
    // collateral fields from contract
    uint256 totalCollateral;
    uint256 totalBorrow;
    uint256 availableBorrow;
    uint256 healthFactor;
    // loan fields from contract
    address reserveAsset;
    uint256 scaledAmount;
    uint256 borrowAmount;
    uint8 reserveGroup;
    uint8 loanStatus;
    // bid fields from contract
    uint40 bidStartTimestamp;
    uint40 bidEndTimestamp;
    address firstBidder;
    address lastBidder;
    uint256 bidAmount;
    uint256 bidFine;
    uint256 redeemAmount;
    // fields not come from contract
  }

  struct TestContractData {
    TestAssetData assetData;
    TestUserAssetData userAssetData;
    TestUserAccountData accountData;
    TestLoanData[] loansData;
    // following fileds to avoid stack too deep
    TestAssetData assetData2;
    TestUserAssetData userAssetData2;
    TestUserAccountData accountData2;
    TestAssetData assetData3;
    TestUserAssetData userAssetData3;
    TestUserAccountData accountData3;
    TestAssetData assetData4;
    TestUserAssetData userAssetData4;
    TestUserAccountData accountData4;
  }

  function onSetUp() public virtual override {
    super.onSetUp();
  }

  function getAssetData(
    uint32 poolId,
    address asset,
    uint8 assetType
  ) public view returns (TestAssetData memory assetData) {
    assetData.asset = asset;
    assetData.assetType = assetType;

    if (assetType == Constants.ASSET_TYPE_ERC20) {
      assetData.config.decimals = IERC20Metadata(asset).decimals();
    }

    (
      assetData.config.classGroup,
      assetData.config.feeFactor,
      assetData.config.collateralFactor,
      assetData.config.liquidationThreshold,
      assetData.config.liquidationBonus
    ) = tsPoolLens.getAssetLendingConfig(poolId, asset);

    (
      assetData.totalScaledCrossSupply,
      assetData.totalCrossSupply,
      assetData.totalScaledIsolateSupply,
      assetData.totalIsolateSupply,
      assetData.availableSupply,
      assetData.supplyRate,
      assetData.supplyIndex,
      assetData.lastUpdateTimestamp
    ) = tsPoolLens.getAssetSupplyData(poolId, asset);

    uint256 maxGroupNum = tsPoolLens.getPoolMaxGroupNumber();
    assetData.groupsData = new TestGroupData[](maxGroupNum);

    uint256[] memory groupIds = tsPoolLens.getAssetGroupList(poolId, asset);
    for (uint256 i = 0; i < groupIds.length; i++) {
      TestGroupData memory groupData = assetData.groupsData[groupIds[i]];
      groupData.groupId = uint8(i);
      (
        groupData.totalScaledCrossBorrow,
        groupData.totalCrossBorrow,
        groupData.totalScaledIsolateBorrow,
        groupData.totalIsolateBorrow,
        groupData.borrowRate,
        groupData.borrowIndex,
        groupData.rateModel
      ) = tsPoolLens.getAssetGroupData(poolId, asset, uint8(groupIds[i]));

      assetData.totalScaledCrossBorrow += groupData.totalScaledCrossBorrow;
      assetData.totalCrossBorrow += groupData.totalCrossBorrow;
      assetData.totalScaledIsolateBorrow += groupData.totalScaledIsolateBorrow;
      assetData.totalIsolateBorrow += groupData.totalIsolateBorrow;
    }

    assetData.totalLiquidity = (assetData.totalCrossBorrow + assetData.totalIsolateBorrow) + assetData.availableSupply;
    if (assetData.totalLiquidity > 0) {
      assetData.utilizationRate = (assetData.totalCrossBorrow + assetData.totalIsolateBorrow).rayDiv(
        assetData.totalLiquidity
      );
    }
  }

  function copyAssetData(TestAssetData memory assetDataOld) public pure returns (TestAssetData memory assetDataNew) {
    assetDataNew.asset = assetDataOld.asset;
    assetDataNew.assetType = assetDataOld.assetType;

    // just refer to the original config
    assetDataNew.config = assetDataOld.config;

    assetDataNew.totalScaledCrossSupply = assetDataOld.totalScaledCrossSupply;
    assetDataNew.totalCrossSupply = assetDataOld.totalCrossSupply;
    assetDataNew.totalScaledIsolateSupply = assetDataOld.totalScaledIsolateSupply;
    assetDataNew.totalIsolateSupply = assetDataOld.totalIsolateSupply;
    assetDataNew.availableSupply = assetDataOld.availableSupply;
    assetDataNew.supplyRate = assetDataOld.supplyRate;
    assetDataNew.supplyIndex = assetDataOld.supplyIndex;
    assetDataNew.lastUpdateTimestamp = assetDataOld.lastUpdateTimestamp;

    assetDataNew.groupsData = new TestGroupData[](assetDataOld.groupsData.length);
    for (uint256 i = 0; i < assetDataOld.groupsData.length; i++) {
      TestGroupData memory groupDataOld = assetDataOld.groupsData[i];
      TestGroupData memory groupDataNew = assetDataNew.groupsData[i];

      groupDataNew.totalScaledCrossBorrow = groupDataOld.totalScaledCrossBorrow;
      groupDataNew.totalCrossBorrow = groupDataOld.totalCrossBorrow;
      groupDataNew.totalScaledIsolateBorrow = groupDataOld.totalScaledIsolateBorrow;
      groupDataNew.totalIsolateBorrow = groupDataOld.totalIsolateBorrow;
      groupDataNew.borrowRate = groupDataOld.borrowRate;
      groupDataNew.borrowIndex = groupDataOld.borrowIndex;
      groupDataNew.rateModel = groupDataOld.rateModel;
    }

    assetDataNew.totalScaledCrossBorrow = assetDataOld.totalScaledCrossBorrow;
    assetDataNew.totalCrossBorrow = assetDataOld.totalCrossBorrow;
    assetDataNew.totalScaledIsolateBorrow = assetDataOld.totalScaledIsolateBorrow;
    assetDataNew.totalIsolateBorrow = assetDataOld.totalIsolateBorrow;
    assetDataNew.totalLiquidity = assetDataOld.totalLiquidity;
    assetDataNew.utilizationRate = assetDataOld.utilizationRate;
  }

  function getUserAccountData(address user, uint32 poolId) public view returns (TestUserAccountData memory data) {
    (
      data.totalCollateralInBase,
      data.totalBorrowInBase,
      data.availableBorrowInBase,
      data.currentCollateralFactor,
      data.currentLiquidationThreshold,
      data.healthFactor
    ) = tsPoolLens.getUserAccountData(user, poolId);
  }

  function getUserAssetData(
    address user,
    uint32 poolId,
    address asset,
    uint8 assetType
  ) public view returns (TestUserAssetData memory userAssetData) {
    userAssetData.user = user;

    if (assetType == Constants.ASSET_TYPE_ERC20) {
      userAssetData.walletBalance = ERC20(asset).balanceOf(user);
    } else if (assetType == Constants.ASSET_TYPE_ERC721) {
      userAssetData.walletBalance = ERC721(asset).balanceOf(user);
    }

    (
      userAssetData.totalScaledCrossSupply,
      userAssetData.totalScaledIsolateSupply,
      userAssetData.totalScaledCrossBorrow,
      userAssetData.totalScaledIsolateBorrow
    ) = tsPoolLens.getUserAssetScaledData(user, poolId, asset);

    (
      userAssetData.totalCrossSupply,
      userAssetData.totalIsolateSupply,
      userAssetData.totalCrossBorrow,
      userAssetData.totalIsolateBorrow
    ) = tsPoolLens.getUserAssetData(user, poolId, asset);

    uint256 maxGroupNum = tsPoolLens.getPoolMaxGroupNumber();
    userAssetData.groupsData = new TestUserGroupData[](maxGroupNum);

    uint256[] memory groupIds = tsPoolLens.getAssetGroupList(poolId, asset);
    for (uint256 i = 0; i < groupIds.length; i++) {
      TestUserGroupData memory groupData = userAssetData.groupsData[groupIds[i]];
      (
        groupData.totalScaledCrossBorrow,
        groupData.totalCrossBorrow,
        groupData.totalScaledIsolateBorrow,
        groupData.totalIsolateBorrow
      ) = tsPoolLens.getUserAssetGroupData(user, poolId, asset, uint8(groupIds[i]));
    }
  }

  function copyUserAssetData(
    TestUserAssetData memory userAssetDataOld
  ) public pure returns (TestUserAssetData memory userAssetDataNew) {
    userAssetDataNew.user = userAssetDataOld.user;

    userAssetDataNew.walletBalance = userAssetDataOld.walletBalance;
    userAssetDataNew.totalScaledCrossSupply = userAssetDataOld.totalScaledCrossSupply;
    userAssetDataNew.totalCrossSupply = userAssetDataOld.totalCrossSupply;
    userAssetDataNew.totalScaledIsolateSupply = userAssetDataOld.totalScaledIsolateSupply;
    userAssetDataNew.totalIsolateSupply = userAssetDataOld.totalIsolateSupply;

    userAssetDataNew.groupsData = new TestUserGroupData[](userAssetDataOld.groupsData.length);
    for (uint256 i = 0; i < userAssetDataOld.groupsData.length; i++) {
      TestUserGroupData memory groupDataOld = userAssetDataOld.groupsData[i];
      TestUserGroupData memory groupDataNew = userAssetDataNew.groupsData[i];

      groupDataNew.totalScaledCrossBorrow = groupDataOld.totalScaledCrossBorrow;
      groupDataNew.totalCrossBorrow = groupDataOld.totalCrossBorrow;
      groupDataNew.totalScaledIsolateBorrow = groupDataOld.totalScaledIsolateBorrow;
      groupDataNew.totalIsolateBorrow = groupDataOld.totalIsolateBorrow;
    }
  }

  function getIsolateLoanData(
    uint32 poolId,
    address nftAsset,
    uint256[] memory nftTokenIds
  ) internal view returns (TestLoanData[] memory loansData) {
    loansData = new TestLoanData[](nftTokenIds.length);

    for (uint256 i = 0; i < nftTokenIds.length; i++) {
      loansData[i] = getIsolateLoanData(poolId, nftAsset, nftTokenIds[i]);
    }
  }

  function getIsolateLoanData(
    uint32 poolId,
    address nftAsset,
    uint256 nftTokenId
  ) internal view returns (TestLoanData memory data) {
    data.nftAsset = nftAsset;
    data.nftTokenId = nftTokenId;

    (data.reserveAsset, data.scaledAmount, data.borrowAmount, data.reserveGroup, data.loanStatus) = tsPoolLens
      .getIsolateLoanData(poolId, nftAsset, nftTokenId);

    (
      data.bidStartTimestamp,
      data.bidEndTimestamp,
      data.firstBidder,
      data.lastBidder,
      data.bidAmount,
      data.bidFine,
      data.redeemAmount
    ) = tsPoolLens.getIsolateAuctionData(poolId, nftAsset, nftTokenId);

    if (data.reserveAsset != address(0)) {
      (data.totalCollateral, data.totalBorrow, data.availableBorrow, data.healthFactor) = tsPoolLens
        .getIsolateCollateralData(poolId, nftAsset, nftTokenId, data.reserveAsset);
    }
  }

  function getIsolateCollateralData(
    uint32 poolId,
    address nftAsset,
    uint256 nftTokenId,
    address debtAsset
  ) internal view returns (TestLoanData memory data) {
    data.nftAsset = nftAsset;
    data.nftTokenId = nftTokenId;

    (data.totalCollateral, data.totalBorrow, data.availableBorrow, data.healthFactor) = tsPoolLens
      .getIsolateCollateralData(poolId, nftAsset, nftTokenId, debtAsset);
  }

  function copyLoanData(TestLoanData memory loanDataOld) public pure returns (TestLoanData memory loanDataNew) {
    loanDataNew.nftAsset = loanDataOld.nftAsset;
    loanDataNew.nftTokenId = loanDataOld.nftTokenId;

    loanDataNew.reserveAsset = loanDataOld.reserveAsset;
    loanDataNew.scaledAmount = loanDataOld.scaledAmount;
    loanDataNew.borrowAmount = loanDataOld.borrowAmount;
    loanDataNew.reserveGroup = loanDataOld.reserveGroup;
    loanDataNew.loanStatus = loanDataOld.loanStatus;

    loanDataNew.bidStartTimestamp = loanDataOld.bidStartTimestamp;
    loanDataNew.bidEndTimestamp = loanDataOld.bidEndTimestamp;
    loanDataNew.firstBidder = loanDataOld.firstBidder;
    loanDataNew.lastBidder = loanDataOld.lastBidder;
    loanDataNew.bidAmount = loanDataOld.bidAmount;
  }

  function copyLoanData(TestLoanData[] memory loansDataOld) public pure returns (TestLoanData[] memory loansDataNew) {
    loansDataNew = new TestLoanData[](loansDataOld.length);

    for (uint256 i = 0; i < loansDataOld.length; i++) {
      loansDataNew[i] = copyLoanData(loansDataOld[i]);
    }
  }

  function getContractData(
    address user,
    uint32 poolId,
    address asset,
    uint8 assetType
  ) internal view returns (TestContractData memory data) {
    data.assetData = getAssetData(poolId, asset, assetType);
    data.userAssetData = getUserAssetData(user, poolId, asset, assetType);
  }

  function getContractDataWithAccout(
    address user,
    uint32 poolId,
    address asset,
    uint8 assetType
  ) internal view returns (TestContractData memory data) {
    data.assetData = getAssetData(poolId, asset, assetType);
    data.userAssetData = getUserAssetData(user, poolId, asset, assetType);
    data.accountData = getUserAccountData(user, poolId);
  }
}
