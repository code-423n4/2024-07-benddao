// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {BaseModule} from '../base/BaseModule.sol';

import {Constants} from '../libraries/helpers/Constants.sol';
import {Errors} from '../libraries/helpers/Errors.sol';
import {DataTypes} from '../libraries/types/DataTypes.sol';
import {InputTypes} from '../libraries/types/InputTypes.sol';

import {StorageSlot} from '../libraries/logic/StorageSlot.sol';
import {VaultLogic} from '../libraries/logic/VaultLogic.sol';
import {SupplyLogic} from '../libraries/logic/SupplyLogic.sol';
import {PoolLogic} from '../libraries/logic/PoolLogic.sol';

/// @notice BVault Service Logic
contract BVault is BaseModule {
  constructor(bytes32 moduleGitCommit_) BaseModule(Constants.MODULEID__BVAULT, moduleGitCommit_) {}

  function depositERC20(
    uint32 poolId,
    address asset,
    uint256 amount,
    address onBehalf
  ) public payable whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    if (asset == Constants.NATIVE_TOKEN_ADDRESS) {
      asset = ps.wrappedNativeToken;
      amount = msg.value;
      VaultLogic.wrapNativeTokenInWallet(asset, msgSender, amount);
    } else {
      require(msg.value == 0, Errors.MSG_VALUE_NOT_ZERO);
    }

    SupplyLogic.executeDepositERC20(
      InputTypes.ExecuteDepositERC20Params({
        msgSender: msgSender,
        poolId: poolId,
        asset: asset,
        amount: amount,
        onBehalf: onBehalf
      })
    );
  }

  function withdrawERC20(
    uint32 poolId,
    address asset,
    uint256 amount,
    address onBehalf,
    address receiver
  ) public whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    bool isNative;
    if (asset == Constants.NATIVE_TOKEN_ADDRESS) {
      isNative = true;
      asset = ps.wrappedNativeToken;
    }

    SupplyLogic.executeWithdrawERC20(
      InputTypes.ExecuteWithdrawERC20Params({
        msgSender: msgSender,
        poolId: poolId,
        asset: asset,
        amount: amount,
        onBehalf: onBehalf,
        receiver: receiver
      })
    );

    if (isNative) {
      VaultLogic.unwrapNativeTokenInWallet(asset, msgSender, amount);
    }
  }

  function depositERC721(
    uint32 poolId,
    address asset,
    uint256[] calldata tokenIds,
    uint8 supplyMode,
    address onBehalf
  ) public whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    SupplyLogic.executeDepositERC721(
      InputTypes.ExecuteDepositERC721Params({
        msgSender: msgSender,
        poolId: poolId,
        asset: asset,
        tokenIds: tokenIds,
        supplyMode: supplyMode,
        onBehalf: onBehalf
      })
    );
  }

  function withdrawERC721(
    uint32 poolId,
    address asset,
    uint256[] calldata tokenIds,
    uint8 supplyMode,
    address onBehalf,
    address receiver
  ) public whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    SupplyLogic.executeWithdrawERC721(
      InputTypes.ExecuteWithdrawERC721Params({
        msgSender: msgSender,
        poolId: poolId,
        asset: asset,
        tokenIds: tokenIds,
        supplyMode: supplyMode,
        onBehalf: onBehalf,
        receiver: receiver
      })
    );
  }

  function setERC721SupplyMode(
    uint32 poolId,
    address asset,
    uint256[] calldata tokenIds,
    uint8 supplyMode,
    address onBehalf
  ) public whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    SupplyLogic.executeSetERC721SupplyMode(
      InputTypes.ExecuteSetERC721SupplyModeParams({
        msgSender: msgSender,
        poolId: poolId,
        asset: asset,
        tokenIds: tokenIds,
        supplyMode: supplyMode,
        onBehalf: onBehalf
      })
    );
  }

  function collectFeeToTreasury(uint32 poolId, address[] calldata assets) public whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    PoolLogic.executeCollectFeeToTreasury(msgSender, poolId, assets);
  }

  function delegateERC721(
    uint32 poolId,
    address nftAsset,
    uint256[] calldata tokenIds,
    address delegate,
    bool value
  ) public whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    PoolLogic.executeDelegateERC721(
      InputTypes.ExecuteDelegateERC721Params({
        msgSender: msgSender,
        poolId: poolId,
        nftAsset: nftAsset,
        tokenIds: tokenIds,
        delegate: delegate,
        value: value
      })
    );
  }

  function setApprovalForAll(
    uint32 poolId,
    address asset,
    address operator,
    bool approved
  ) public whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    PoolLogic.executeSetApprovalForAll(msgSender, poolId, asset, operator, approved);
  }
}
