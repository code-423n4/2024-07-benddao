// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {BaseModule} from '../base/BaseModule.sol';

import {Constants} from '../libraries/helpers/Constants.sol';
import {Errors} from '../libraries/helpers/Errors.sol';
import {DataTypes} from '../libraries/types/DataTypes.sol';
import {InputTypes} from '../libraries/types/InputTypes.sol';

import {StorageSlot} from '../libraries/logic/StorageSlot.sol';
import {VaultLogic} from '../libraries/logic/VaultLogic.sol';
import {FlashLoanLogic} from '../libraries/logic/FlashLoanLogic.sol';

/// @notice FlashLoan Service Logic
contract FlashLoan is BaseModule {
  constructor(bytes32 moduleGitCommit_) BaseModule(Constants.MODULEID__FLASHLOAN, moduleGitCommit_) {}

  /* @notice Don't use nonReentrant modifier here */
  function flashLoanERC20(
    uint32 poolId,
    address[] calldata assets,
    uint256[] calldata amounts,
    address receiverAddress,
    bytes calldata params
  ) public whenNotPaused {
    address msgSender = unpackTrailingParamMsgSender();
    FlashLoanLogic.executeFlashLoanERC20(
      InputTypes.ExecuteFlashLoanERC20Params({
        msgSender: msgSender,
        poolId: poolId,
        assets: assets,
        amounts: amounts,
        receiverAddress: receiverAddress,
        params: params
      })
    );
  }

  function flashLoanERC721(
    uint32 poolId,
    address[] calldata nftAssets,
    uint256[] calldata nftTokenIds,
    address receiverAddress,
    bytes calldata params
  ) public whenNotPaused nonReentrant {
    address msgSender = unpackTrailingParamMsgSender();
    FlashLoanLogic.executeFlashLoanERC721(
      InputTypes.ExecuteFlashLoanERC721Params({
        msgSender: msgSender,
        poolId: poolId,
        nftAssets: nftAssets,
        nftTokenIds: nftTokenIds,
        receiverAddress: receiverAddress,
        params: params
      })
    );
  }
}
