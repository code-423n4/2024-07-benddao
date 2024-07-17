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

/// @notice Cross Lending Service Logic
contract CrossLending is BaseModule {
  constructor(bytes32 moduleGitCommit_) BaseModule(Constants.MODULEID__CROSS_LENDING, moduleGitCommit_) {}

  function crossBorrowERC20(
    uint32 poolId,
    address asset,
    uint8[] calldata groups,
    uint256[] calldata amounts,
    address onBehalf,
    address receiver
  ) public whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    bool isNative;
    if (asset == address(Constants.NATIVE_TOKEN_ADDRESS)) {
      isNative = true;
      asset = ps.wrappedNativeToken;
    }

    uint256 totalBorrowAmount = BorrowLogic.executeCrossBorrowERC20(
      InputTypes.ExecuteCrossBorrowERC20Params({
        msgSender: msgSender,
        poolId: poolId,
        asset: asset,
        groups: groups,
        amounts: amounts,
        onBehalf: onBehalf,
        receiver: receiver
      })
    );

    if (isNative) {
      VaultLogic.unwrapNativeTokenInWallet(asset, msgSender, totalBorrowAmount);
    }
  }

  function crossRepayERC20(
    uint32 poolId,
    address asset,
    uint8[] calldata groups,
    uint256[] calldata amounts,
    address onBehalf
  ) public payable whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    if (asset == Constants.NATIVE_TOKEN_ADDRESS) {
      asset = ps.wrappedNativeToken;
      VaultLogic.wrapNativeTokenInWallet(asset, msgSender, msg.value);
    } else {
      require(msg.value == 0, Errors.MSG_VALUE_NOT_ZERO);
    }

    BorrowLogic.executeCrossRepayERC20(
      InputTypes.ExecuteCrossRepayERC20Params({
        msgSender: msgSender,
        poolId: poolId,
        asset: asset,
        groups: groups,
        amounts: amounts,
        onBehalf: onBehalf
      })
    );
  }
}
