// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {BaseModule} from '../base/BaseModule.sol';

import {Constants} from '../libraries/helpers/Constants.sol';
import {Errors} from '../libraries/helpers/Errors.sol';
import {DataTypes} from '../libraries/types/DataTypes.sol';
import {InputTypes} from '../libraries/types/InputTypes.sol';

import {StorageSlot} from '../libraries/logic/StorageSlot.sol';
import {VaultLogic} from '../libraries/logic/VaultLogic.sol';
import {BorrowLogic} from '../libraries/logic/BorrowLogic.sol';
import {LiquidationLogic} from '../libraries/logic/LiquidationLogic.sol';
import {QueryLogic} from '../libraries/logic/QueryLogic.sol';

/// @notice Cross Liquidation Service Logic
contract CrossLiquidation is BaseModule {
  constructor(bytes32 moduleGitCommit_) BaseModule(Constants.MODULEID__CROSS_LIQUIDATION, moduleGitCommit_) {}

  function crossLiquidateERC20(
    uint32 poolId,
    address borrower,
    address collateralAsset,
    address debtAsset,
    uint256 debtToCover,
    bool supplyAsCollateral
  ) public payable whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    if (debtAsset == Constants.NATIVE_TOKEN_ADDRESS) {
      debtAsset = ps.wrappedNativeToken;
      VaultLogic.wrapNativeTokenInWallet(debtAsset, msgSender, msg.value);
    } else {
      require(msg.value == 0, Errors.MSG_VALUE_NOT_ZERO);
    }

    bool isCollateralNative;
    if (collateralAsset == Constants.NATIVE_TOKEN_ADDRESS) {
      isCollateralNative = true;
      collateralAsset = ps.wrappedNativeToken;
    }

    (uint256 actualCollateralToLiquidate, ) = LiquidationLogic.executeCrossLiquidateERC20(
      InputTypes.ExecuteCrossLiquidateERC20Params({
        msgSender: msgSender,
        poolId: poolId,
        borrower: borrower,
        collateralAsset: collateralAsset,
        debtAsset: debtAsset,
        debtToCover: debtToCover,
        supplyAsCollateral: supplyAsCollateral
      })
    );

    if (isCollateralNative && !supplyAsCollateral) {
      VaultLogic.unwrapNativeTokenInWallet(collateralAsset, msgSender, actualCollateralToLiquidate);
    }
  }

  function crossLiquidateERC721(
    uint32 poolId,
    address borrower,
    address collateralAsset,
    uint256[] calldata collateralTokenIds,
    address debtAsset,
    bool supplyAsCollateral
  ) public payable whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    if (debtAsset == Constants.NATIVE_TOKEN_ADDRESS) {
      debtAsset = ps.wrappedNativeToken;
      VaultLogic.wrapNativeTokenInWallet(debtAsset, msgSender, msg.value);
    } else {
      require(msg.value == 0, Errors.MSG_VALUE_NOT_ZERO);
    }

    LiquidationLogic.executeCrossLiquidateERC721(
      InputTypes.ExecuteCrossLiquidateERC721Params({
        msgSender: msgSender,
        poolId: poolId,
        borrower: borrower,
        collateralAsset: collateralAsset,
        collateralTokenIds: collateralTokenIds,
        debtAsset: debtAsset,
        supplyAsCollateral: supplyAsCollateral
      })
    );
  }
}
