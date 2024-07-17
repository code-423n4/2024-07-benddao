// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IFlashLoanReceiver} from '../../interfaces/IFlashLoanReceiver.sol';

import {Constants} from '../helpers/Constants.sol';
import {Errors} from '../helpers/Errors.sol';
import {Events} from '../helpers/Events.sol';

import {PercentageMath} from '../math/PercentageMath.sol';

import {InputTypes} from '../types/InputTypes.sol';
import {DataTypes} from '../types/DataTypes.sol';
import {StorageSlot} from './StorageSlot.sol';

import {VaultLogic} from './VaultLogic.sol';
import {ValidateLogic} from './ValidateLogic.sol';

library FlashLoanLogic {
  function executeFlashLoanERC20(InputTypes.ExecuteFlashLoanERC20Params memory inputParams) internal {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[inputParams.poolId];

    uint256 i;
    IFlashLoanReceiver receiver = IFlashLoanReceiver(inputParams.receiverAddress);

    ValidateLogic.validateFlashLoanERC20Basic(inputParams, poolData);

    // only token owner can do flashloan
    for (i = 0; i < inputParams.assets.length; i++) {
      DataTypes.AssetData storage assetData = poolData.assetLookup[inputParams.assets[i]];
      ValidateLogic.validateAssetBasic(assetData);
      require(assetData.assetType == Constants.ASSET_TYPE_ERC20, Errors.ASSET_TYPE_NOT_ERC20);
      require(assetData.isFlashLoanEnabled, Errors.ASSET_IS_FLASHLOAN_DISABLED);
    }

    // step 1: moving underlying asset forward to receiver contract
    VaultLogic.erc20TransferOutOnFlashLoan(inputParams.receiverAddress, inputParams.assets, inputParams.amounts);

    // setup 2: execute receiver contract, doing something like aidrop
    bool execOpRet = receiver.executeOperationERC20(
      inputParams.assets,
      inputParams.amounts,
      inputParams.msgSender,
      address(this),
      inputParams.params
    );
    require(execOpRet, Errors.FLASH_LOAN_EXEC_FAILED);

    // setup 3: moving underlying asset backward from receiver contract
    VaultLogic.erc20TransferInOnFlashLoan(inputParams.receiverAddress, inputParams.assets, inputParams.amounts);

    emit Events.FlashLoanERC20(
      inputParams.msgSender,
      inputParams.poolId,
      inputParams.assets,
      inputParams.amounts,
      inputParams.receiverAddress
    );
  }

  function executeFlashLoanERC721(InputTypes.ExecuteFlashLoanERC721Params memory inputParams) internal {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    DataTypes.PoolData storage poolData = ps.poolLookup[inputParams.poolId];

    uint256 i;
    IFlashLoanReceiver receiver = IFlashLoanReceiver(inputParams.receiverAddress);

    ValidateLogic.validateFlashLoanERC721Basic(inputParams, poolData);

    // only token owner can do flashloan
    for (i = 0; i < inputParams.nftTokenIds.length; i++) {
      DataTypes.AssetData storage assetData = poolData.assetLookup[inputParams.nftAssets[i]];
      ValidateLogic.validateAssetBasic(assetData);
      require(assetData.assetType == Constants.ASSET_TYPE_ERC721, Errors.ASSET_TYPE_NOT_ERC721);
      require(assetData.isFlashLoanEnabled, Errors.ASSET_IS_FLASHLOAN_DISABLED);

      // check the owner
      DataTypes.ERC721TokenData storage tokenData = VaultLogic.erc721GetTokenData(
        assetData,
        inputParams.nftTokenIds[i]
      );
      require(tokenData.owner == inputParams.msgSender, Errors.INVALID_TOKEN_OWNER);

      // check the isolate loan status
      DataTypes.IsolateLoanData storage loanData = poolData.loanLookup[inputParams.nftAssets[i]][
        inputParams.nftTokenIds[i]
      ];
      if (loanData.loanStatus != 0) {
        require(loanData.loanStatus == Constants.LOAN_STATUS_ACTIVE, Errors.INVALID_LOAN_STATUS);
      }
    }

    // step 1: moving underlying asset forward to receiver contract
    VaultLogic.erc721TransferOutOnFlashLoan(
      inputParams.receiverAddress,
      inputParams.nftAssets,
      inputParams.nftTokenIds
    );

    // setup 2: execute receiver contract, doing something like aidrop
    bool execOpRet = receiver.executeOperationERC721(
      inputParams.nftAssets,
      inputParams.nftTokenIds,
      inputParams.msgSender,
      address(this),
      inputParams.params
    );
    require(execOpRet, Errors.FLASH_LOAN_EXEC_FAILED);

    // setup 3: moving underlying asset backward from receiver contract
    VaultLogic.erc721TransferInOnFlashLoan(inputParams.receiverAddress, inputParams.nftAssets, inputParams.nftTokenIds);

    emit Events.FlashLoanERC721(
      inputParams.msgSender,
      inputParams.poolId,
      inputParams.nftAssets,
      inputParams.nftTokenIds,
      inputParams.receiverAddress
    );
  }
}
