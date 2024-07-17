// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {BaseModule} from '../base/BaseModule.sol';

import {Constants} from '../libraries/helpers/Constants.sol';
import {Errors} from '../libraries/helpers/Errors.sol';
import {DataTypes} from '../libraries/types/DataTypes.sol';
import {InputTypes} from '../libraries/types/InputTypes.sol';

import {StorageSlot} from '../libraries/logic/StorageSlot.sol';
import {VaultLogic} from '../libraries/logic/VaultLogic.sol';
import {IsolateLogic} from '../libraries/logic/IsolateLogic.sol';
import {QueryLogic} from '../libraries/logic/QueryLogic.sol';

/// @notice Isolate Liquidation Service Logic
contract IsolateLiquidation is BaseModule {
  constructor(bytes32 moduleGitCommit_) BaseModule(Constants.MODULEID__ISOLATE_LIQUIDATION, moduleGitCommit_) {}

  function isolateAuction(
    uint32 poolId,
    address nftAsset,
    uint256[] calldata nftTokenIds,
    address asset,
    uint256[] calldata amounts
  ) public payable whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    if (asset == Constants.NATIVE_TOKEN_ADDRESS) {
      asset = ps.wrappedNativeToken;
      VaultLogic.wrapNativeTokenInWallet(asset, msgSender, msg.value);
    } else {
      require(msg.value == 0, Errors.MSG_VALUE_NOT_ZERO);
    }

    IsolateLogic.executeIsolateAuction(
      InputTypes.ExecuteIsolateAuctionParams({
        msgSender: msgSender,
        poolId: poolId,
        nftAsset: nftAsset,
        nftTokenIds: nftTokenIds,
        asset: asset,
        amounts: amounts
      })
    );
  }

  function isolateRedeem(
    uint32 poolId,
    address nftAsset,
    uint256[] calldata nftTokenIds,
    address asset,
    uint256[] calldata /*amounts*/
  ) public payable whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    if (asset == Constants.NATIVE_TOKEN_ADDRESS) {
      asset = ps.wrappedNativeToken;
      VaultLogic.wrapNativeTokenInWallet(asset, msgSender, msg.value);
    } else {
      require(msg.value == 0, Errors.MSG_VALUE_NOT_ZERO);
    }

    IsolateLogic.executeIsolateRedeem(
      InputTypes.ExecuteIsolateRedeemParams({
        msgSender: msgSender,
        poolId: poolId,
        nftAsset: nftAsset,
        nftTokenIds: nftTokenIds,
        asset: asset
      })
    );
  }

  function isolateLiquidate(
    uint32 poolId,
    address nftAsset,
    uint256[] calldata nftTokenIds,
    address asset,
    uint256[] calldata /*amounts*/,
    bool supplyAsCollateral
  ) public payable whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    if (asset == Constants.NATIVE_TOKEN_ADDRESS) {
      asset = ps.wrappedNativeToken;
      VaultLogic.wrapNativeTokenInWallet(asset, msgSender, msg.value);
    } else {
      require(msg.value == 0, Errors.MSG_VALUE_NOT_ZERO);
    }

    IsolateLogic.executeIsolateLiquidate(
      InputTypes.ExecuteIsolateLiquidateParams({
        msgSender: msgSender,
        poolId: poolId,
        nftAsset: nftAsset,
        nftTokenIds: nftTokenIds,
        asset: asset,
        supplyAsCollateral: supplyAsCollateral
      })
    );
  }
}
