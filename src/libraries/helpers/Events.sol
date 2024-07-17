// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library Events {
  // Modeuls Events
  event ProxyCreated(address indexed proxy, uint moduleId);
  event InstallerSetUpgradeAdmin(address indexed newUpgradeAdmin);
  event InstallerSetGovernorAdmin(address indexed newGovernorAdmin);
  event InstallerInstallModule(uint indexed moduleId, address indexed moduleImpl, bytes32 moduleGitCommit);

  /* Oracle Events */
  event AssetAggregatorUpdated(address indexed asset, address aggregator);
  event BendNFTOracleUpdated(address bendNFTOracle);

  /* Pool Events */
  event CreatePool(uint32 indexed poolId, string name);
  event DeletePool(uint32 indexed poolId);
  event SetPoolName(uint32 indexed poolId, string name);

  event AddPoolGroup(uint32 indexed poolId, uint8 groupId);
  event RemovePoolGroup(uint32 indexed poolId, uint8 groupId);

  event SetPoolPause(uint32 indexed poolId, bool isPause);
  event CollectFeeToTreasury(uint32 indexed poolId, address indexed asset, uint256 fee, uint256 index);

  event SetPoolYieldEnable(uint32 indexed poolId, bool isEnable);
  event SetPoolYieldPause(uint32 indexed poolId, bool isPause);

  /* Asset Events */
  event AssetInterestSupplyDataUpdated(
    uint32 indexed poolId,
    address indexed asset,
    uint256 supplyRate,
    uint256 supplyIndex
  );
  event AssetInterestBorrowDataUpdated(
    uint32 indexed poolId,
    address indexed asset,
    uint256 groupId,
    uint256 borrowRate,
    uint256 borrowIndex
  );

  event AddAsset(uint32 indexed poolId, address indexed asset, uint8 assetType);
  event RemoveAsset(uint32 indexed poolId, address indexed asset, uint8 assetType);

  event AddAssetGroup(uint32 indexed poolId, address indexed asset, uint8 groupId);
  event RemoveAssetGroup(uint32 indexed poolId, address indexed asset, uint8 groupId);

  event SetAssetActive(uint32 indexed poolId, address indexed asset, bool isActive);
  event SetAssetFrozen(uint32 indexed poolId, address indexed asset, bool isFrozen);
  event SetAssetPause(uint32 indexed poolId, address indexed asset, bool isPause);
  event SetAssetBorrowing(uint32 indexed poolId, address indexed asset, bool isEnable);
  event SetAssetFlashLoan(uint32 indexed poolId, address indexed asset, bool isEnable);
  event SetAssetSupplyCap(uint32 indexed poolId, address indexed asset, uint256 newCap);
  event SetAssetBorrowCap(uint32 indexed poolId, address indexed asset, uint256 newCap);
  event SetAssetClassGroup(uint32 indexed poolId, address indexed asset, uint8 groupId);
  event SetAssetCollateralParams(
    uint32 indexed poolId,
    address indexed asset,
    uint16 collateralFactor,
    uint16 liquidationThreshold,
    uint16 liquidationBonus
  );
  event SetAssetAuctionParams(
    uint32 indexed poolId,
    address indexed asset,
    uint16 redeemThreshold,
    uint16 bidFineFactor,
    uint16 minBidFineFactor,
    uint40 auctionDuration
  );
  event SetAssetProtocolFee(uint32 indexed poolId, address indexed asset, uint16 feeFactor);
  event SetAssetLendingRate(uint32 indexed poolId, address indexed asset, uint8 groupId, address rateModel);

  event SetAssetYieldEnable(uint32 indexed poolId, address indexed asset, bool isEnable);
  event SetAssetYieldPause(uint32 indexed poolId, address indexed asset, bool isPause);
  event SetAssetYieldCap(uint32 indexed poolId, address indexed asset, uint256 newCap);
  event SetAssetYieldRate(uint32 indexed poolId, address indexed asset, address rateModel);
  event SetManagerYieldCap(uint32 indexed poolId, address indexed staker, address indexed asset, uint256 newCap);

  /* Supply Events */
  event DepositERC20(
    address indexed sender,
    uint256 indexed poolId,
    address indexed asset,
    uint256 amount,
    address onBehalf
  );
  event WithdrawERC20(
    address indexed sender,
    uint256 indexed poolId,
    address indexed asset,
    uint256 amount,
    address onBehalf,
    address receiver
  );

  event DepositERC721(
    address indexed sender,
    uint256 indexed poolId,
    address indexed asset,
    uint256[] tokenIds,
    uint8 supplyMode,
    address onBehalf
  );
  event WithdrawERC721(
    address indexed sender,
    uint256 indexed poolId,
    address indexed asset,
    uint256[] tokenIds,
    uint8 supplyMode,
    address onBehalf,
    address receiver
  );

  event SetERC721SupplyMode(
    address indexed sender,
    uint256 indexed poolId,
    address indexed asset,
    uint256[] tokenIds,
    uint8 supplyMode,
    address onBehalf
  );

  // Cross Lending Events
  event CrossBorrowERC20(
    address indexed sender,
    uint256 indexed poolId,
    address indexed asset,
    uint8[] groups,
    uint256[] amounts,
    address onBehalf,
    address receiver
  );

  event CrossRepayERC20(
    address indexed sender,
    uint256 indexed poolId,
    address indexed asset,
    uint8[] groups,
    uint256[] amounts,
    address onBehalf
  );

  event CrossLiquidateERC20(
    address indexed liquidator,
    uint256 indexed poolId,
    address indexed user,
    address collateralAsset,
    address debtAsset,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    bool supplyAsCollateral
  );

  event CrossLiquidateERC721(
    address indexed liquidator,
    uint256 indexed poolId,
    address indexed user,
    address collateralAsset,
    uint256[] liquidatedCollateralTokenIds,
    address debtAsset,
    uint256 liquidatedDebtAmount,
    bool supplyAsCollateral
  );

  // Isolate Lending Events
  event IsolateBorrow(
    address indexed sender,
    uint256 indexed poolId,
    address indexed nftAsset,
    uint256[] tokenIds,
    address debtAsset,
    uint256[] amounts,
    address onBehalf,
    address receiver
  );

  event IsolateRepay(
    address indexed sender,
    uint256 indexed poolId,
    address indexed nftAsset,
    uint256[] tokenIds,
    address debtAsset,
    uint256[] amounts,
    address onBehalf
  );

  event IsolateAuction(
    address indexed sender,
    uint256 indexed poolId,
    address indexed nftAsset,
    uint256[] tokenIds,
    address debtAsset,
    uint256[] bidAmounts
  );

  event IsolateRedeem(
    address indexed sender,
    uint256 indexed poolId,
    address indexed nftAsset,
    uint256[] tokenIds,
    address debtAsset,
    uint256[] redeemAmounts,
    uint256[] bidFines
  );

  event IsolateLiquidate(
    address indexed sender,
    uint256 indexed poolId,
    address indexed nftAsset,
    uint256[] tokenIds,
    address debtAsset,
    uint256[] extraAmounts,
    uint256[] remainAmounts,
    bool supplyAsCollateral
  );

  /* Yield Events */
  event YieldBorrowERC20(address indexed sender, uint256 indexed poolId, address indexed asset, uint256 amount);

  event YieldRepayERC20(address indexed sender, uint256 indexed poolId, address indexed asset, uint256 amount);

  // Misc Events
  event FlashLoanERC20(
    address indexed sender,
    uint32 indexed poolId,
    address[] assets,
    uint256[] amounts,
    address receiverAddress
  );

  event FlashLoanERC721(
    address indexed sender,
    uint32 indexed poolId,
    address[] nftAssets,
    uint256[] nftTokenIds,
    address receiverAddress
  );

  event SetApprovalForAll(
    address indexed sender,
    uint32 indexed poolId,
    address indexed asset,
    address operator,
    bool approved
  );
}
