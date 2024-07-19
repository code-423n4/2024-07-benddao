// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library InputTypes {
  struct ExecuteDepositERC20Params {
    address msgSender;
    uint32 poolId;
    address asset;
    uint256 amount;
    address onBehalf;
  }

  struct ExecuteWithdrawERC20Params {
    address msgSender;
    uint32 poolId;
    address asset;
    uint256 amount;
    address onBehalf;
    address receiver;
  }

  struct ExecuteDepositERC721Params {
    address msgSender;
    uint32 poolId;
    address asset;
    uint256[] tokenIds;
    uint8 supplyMode;
    address onBehalf;
  }

  struct ExecuteWithdrawERC721Params {
    address msgSender;
    uint32 poolId;
    address asset;
    uint256[] tokenIds;
    uint8 supplyMode;
    address onBehalf;
    address receiver;
  }

  struct ExecuteSetERC721SupplyModeParams {
    address msgSender;
    uint32 poolId;
    address asset;
    uint256[] tokenIds;
    uint8 supplyMode;
    address onBehalf;
  }

  // Cross Lending

  struct ExecuteCrossBorrowERC20Params {
    address msgSender;
    uint32 poolId;
    address asset;
    uint8[] groups;
    uint256[] amounts;
    address onBehalf;
    address receiver;
  }

  struct ExecuteCrossRepayERC20Params {
    address msgSender;
    uint32 poolId;
    address asset;
    uint8[] groups;
    uint256[] amounts;
    address onBehalf;
  }

  struct ExecuteCrossLiquidateERC20Params {
    address msgSender;
    uint32 poolId;
    address borrower;
    address collateralAsset;
    address debtAsset;
    uint256 debtToCover;
    bool supplyAsCollateral;
  }

  struct ExecuteCrossLiquidateERC721Params {
    address msgSender;
    uint32 poolId;
    address borrower;
    address collateralAsset;
    uint256[] collateralTokenIds;
    address debtAsset;
    bool supplyAsCollateral;
  }

  struct ViewGetUserCrossLiquidateDataParams {
    uint32 poolId;
    address borrower;
    address collateralAsset;
    uint256 collateralAmount;
    address debtAsset;
    uint256 debtAmount;
  }

  // Isolate Lending

  struct ExecuteIsolateBorrowParams {
    address msgSender;
    uint32 poolId;
    address nftAsset;
    uint256[] nftTokenIds;
    address asset;
    uint256[] amounts;
    address onBehalf;
    address receiver;
  }

  struct ExecuteIsolateRepayParams {
    address msgSender;
    uint32 poolId;
    address nftAsset;
    uint256[] nftTokenIds;
    address asset;
    uint256[] amounts;
    address onBehalf;
  }

  struct ExecuteIsolateAuctionParams {
    address msgSender;
    uint32 poolId;
    address nftAsset;
    uint256[] nftTokenIds;
    address asset;
    uint256[] amounts;
  }

  struct ExecuteIsolateRedeemParams {
    address msgSender;
    uint32 poolId;
    address nftAsset;
    uint256[] nftTokenIds;
    address asset;
  }

  struct ExecuteIsolateLiquidateParams {
    address msgSender;
    uint32 poolId;
    address nftAsset;
    uint256[] nftTokenIds;
    address asset;
    bool supplyAsCollateral;
  }

  // Yield

  struct ExecuteYieldBorrowERC20Params {
    address msgSender;
    uint32 poolId;
    address asset;
    uint256 amount;
    bool isExternalCaller;
  }

  struct ExecuteYieldRepayERC20Params {
    address msgSender;
    uint32 poolId;
    address asset;
    uint256 amount;
    bool isExternalCaller;
  }

  struct ExecuteYieldSetERC721TokenDataParams {
    address msgSender;
    uint32 poolId;
    address nftAsset;
    uint256 tokenId;
    bool isLock;
    address debtAsset;
    bool isExternalCaller;
  }

  // Misc
  struct ExecuteFlashLoanERC20Params {
    address msgSender;
    uint32 poolId;
    address[] assets;
    uint256[] amounts;
    address receiverAddress;
    bytes params;
  }

  struct ExecuteFlashLoanERC721Params {
    address msgSender;
    uint32 poolId;
    address[] nftAssets;
    uint256[] nftTokenIds;
    address receiverAddress;
    bytes params;
  }

  struct ExecuteDelegateERC721Params {
    address msgSender;
    uint32 poolId;
    address nftAsset;
    uint256[] tokenIds;
    address delegate;
    bool value;
  }
}
