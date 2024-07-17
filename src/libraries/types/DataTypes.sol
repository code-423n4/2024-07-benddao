// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

library DataTypes {
  /****************************************************************************/
  /* Data Types for Pool Lending */
  struct PoolData {
    uint32 poolId;
    string name;
    bool isPaused;

    // group
    mapping(uint8 => bool) enabledGroups;
    EnumerableSetUpgradeable.UintSet groupList;

    // underlying asset to asset data
    mapping(address => AssetData) assetLookup;
    EnumerableSetUpgradeable.AddressSet assetList;

    // nft address -> nft id -> isolate loan
    mapping(address => mapping(uint256 => IsolateLoanData)) loanLookup;
    // account data
    mapping(address => AccountData) accountLookup;

    // yield
    bool isYieldEnabled;
    bool isYieldPaused;
    uint8 yieldGroup;
  }

  struct AccountData {
    EnumerableSetUpgradeable.AddressSet suppliedAssets;
    EnumerableSetUpgradeable.AddressSet borrowedAssets;
    // asset => operator => approved
    mapping(address => mapping(address => bool)) operatorApprovals;
  }

  struct GroupData {
    // config parameters
    address rateModel;

    // user state
    uint256 totalScaledCrossBorrow;
    mapping(address => uint256) userScaledCrossBorrow;
    uint256 totalScaledIsolateBorrow;
    mapping(address => uint256) userScaledIsolateBorrow;

    // interest state
    uint128 borrowRate;
    uint128 borrowIndex;
    uint8 groupId;
  }

  struct ERC721TokenData {
    address owner;
    uint8 supplyMode; // 0=cross margin, 1=isolate
    address lockerAddr;
  }

  struct YieldManagerData {
    uint256 yieldCap;
  }

  struct AssetData {
    // config params
    address underlyingAsset;
    uint8 assetType; // See ASSET_TYPE_xxx
    uint8 underlyingDecimals; // only for ERC20
    uint8 classGroup;
    bool isActive;
    bool isFrozen;
    bool isPaused;
    bool isBorrowingEnabled;
    bool isFlashLoanEnabled;
    bool isYieldEnabled;
    bool isYieldPaused;
    uint16 feeFactor;
    uint16 collateralFactor;
    uint16 liquidationThreshold;
    uint16 liquidationBonus;
    uint16 redeemThreshold;
    uint16 bidFineFactor;
    uint16 minBidFineFactor;
    uint40 auctionDuration;
    uint256 supplyCap;
    uint256 borrowCap;
    uint256 yieldCap;

    // group state
    mapping(uint8 => GroupData) groupLookup;
    EnumerableSetUpgradeable.UintSet groupList;

    // user state
    uint256 totalScaledCrossSupply; // total supplied balance in cross margin mode
    uint256 totalScaledIsolateSupply; // total supplied balance in isolate mode, only for ERC721
    uint256 availableLiquidity;
    uint256 totalBidAmout;
    mapping(address => uint256) userScaledCrossSupply; // user supplied balance in cross margin mode
    mapping(address => uint256) userScaledIsolateSupply; // user supplied balance in isolate mode, only for ERC721
    mapping(uint256 => ERC721TokenData) erc721TokenData; // token -> data, only for ERC721

    // asset interest state
    uint128 supplyRate;
    uint128 supplyIndex;
    uint256 accruedFee; // as treasury supplied balance in cross mode
    uint40 lastUpdateTimestamp;

    // yield state
    mapping(address => YieldManagerData) yieldManagerLookup;
  }

  struct IsolateLoanData {
    address reserveAsset;
    uint256 scaledAmount;
    uint8 reserveGroup;
    uint8 loanStatus;
    uint40 bidStartTimestamp;
    address firstBidder;
    address lastBidder;
    uint256 bidAmount;
  }

  /****************************************************************************/
  /* Data Types for Storage */
  struct PoolStorage {
    // common fileds
    address addressProvider;
    address wrappedNativeToken; // WETH

    // pool fields
    uint32 nextPoolId;
    mapping(uint32 => PoolData) poolLookup;
    EnumerableSetUpgradeable.UintSet poolList;
  }
}
