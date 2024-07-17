// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IYield} from 'src/interfaces/IYield.sol';

import {Constants} from '../libraries/helpers/Constants.sol';
import {Errors} from '../libraries/helpers/Errors.sol';
import {DataTypes} from '../libraries/types/DataTypes.sol';
import {InputTypes} from '../libraries/types/InputTypes.sol';

import {StorageSlot} from '../libraries/logic/StorageSlot.sol';
import {VaultLogic} from '../libraries/logic/VaultLogic.sol';
import {YieldLogic} from '../libraries/logic/YieldLogic.sol';
import {QueryLogic} from '../libraries/logic/QueryLogic.sol';

import {BaseModule} from '../base/BaseModule.sol';

/// @notice Yield Service Logic
contract Yield is BaseModule, IYield {
  constructor(bytes32 moduleGitCommit_) BaseModule(Constants.MODULEID__YIELD, moduleGitCommit_) {}

  function yieldBorrowERC20(uint32 poolId, address asset, uint256 amount) public override whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    YieldLogic.executeYieldBorrowERC20(
      InputTypes.ExecuteYieldBorrowERC20Params({
        msgSender: msgSender,
        poolId: poolId,
        asset: asset,
        amount: amount,
        isExternalCaller: true
      })
    );
  }

  function yieldRepayERC20(uint32 poolId, address asset, uint256 amount) public override whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    YieldLogic.executeYieldRepayERC20(
      InputTypes.ExecuteYieldRepayERC20Params({
        msgSender: msgSender,
        poolId: poolId,
        asset: asset,
        amount: amount,
        isExternalCaller: true
      })
    );
  }

  function yieldSetERC721TokenData(
    uint32 poolId,
    address nftAsset,
    uint256 tokenId,
    bool isLock,
    address debtAsset
  ) public override whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    YieldLogic.executeYieldSetERC721TokenData(
      InputTypes.ExecuteYieldSetERC721TokenDataParams({
        msgSender: msgSender,
        poolId: poolId,
        nftAsset: nftAsset,
        tokenId: tokenId,
        isLock: isLock,
        debtAsset: debtAsset,
        isExternalCaller: true
      })
    );
  }

  function getYieldERC20BorrowBalance(
    uint32 poolId,
    address asset,
    address staker
  ) public view override returns (uint256) {
    return QueryLogic.getYieldERC20BorrowBalance(poolId, asset, staker);
  }

  function getERC721TokenData(
    uint32 poolId,
    address asset,
    uint256 tokenId
  ) public view override returns (address, uint8, address) {
    return QueryLogic.getERC721TokenData(poolId, asset, tokenId);
  }
}
