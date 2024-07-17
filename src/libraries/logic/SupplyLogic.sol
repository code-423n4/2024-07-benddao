// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IAddressProvider} from '../../interfaces/IAddressProvider.sol';

import {Constants} from '../helpers/Constants.sol';
import {Errors} from '../helpers/Errors.sol';
import {Events} from '../helpers/Events.sol';

import {InputTypes} from '../types/InputTypes.sol';
import {DataTypes} from '../types/DataTypes.sol';
import {StorageSlot} from './StorageSlot.sol';

import {VaultLogic} from './VaultLogic.sol';
import {InterestLogic} from './InterestLogic.sol';
import {ValidateLogic} from './ValidateLogic.sol';

library SupplyLogic {
  function executeDepositERC20(InputTypes.ExecuteDepositERC20Params memory params) internal {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();

    DataTypes.PoolData storage poolData = ps.poolLookup[params.poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[params.asset];

    InterestLogic.updateInterestIndexs(poolData, assetData);

    ValidateLogic.validateDepositERC20(params, poolData, assetData);

    VaultLogic.erc20IncreaseCrossSupply(assetData, params.onBehalf, params.amount);

    VaultLogic.accountCheckAndSetSuppliedAsset(poolData, assetData, params.onBehalf);

    InterestLogic.updateInterestRates(poolData, assetData, params.amount, 0);

    VaultLogic.erc20TransferInLiquidity(assetData, params.msgSender, params.amount);

    emit Events.DepositERC20(params.msgSender, params.poolId, params.asset, params.amount, params.onBehalf);
  }

  function executeWithdrawERC20(InputTypes.ExecuteWithdrawERC20Params memory params) internal {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();

    DataTypes.PoolData storage poolData = ps.poolLookup[params.poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[params.asset];

    InterestLogic.updateInterestIndexs(poolData, assetData);

    ValidateLogic.validateWithdrawERC20(params, poolData, assetData);

    // withdraw amount can not bigger than supply balance
    uint256 userBalance = VaultLogic.erc20GetUserCrossSupply(assetData, params.onBehalf, assetData.supplyIndex);
    if (userBalance < params.amount) {
      params.amount = userBalance;
    }
    require(params.amount <= assetData.availableLiquidity, Errors.ASSET_INSUFFICIENT_LIQUIDITY);

    VaultLogic.erc20DecreaseCrossSupply(assetData, params.onBehalf, params.amount);

    VaultLogic.accountCheckAndSetSuppliedAsset(poolData, assetData, params.onBehalf);

    InterestLogic.updateInterestRates(poolData, assetData, 0, params.amount);

    VaultLogic.erc20TransferOutLiquidity(assetData, params.receiver, params.amount);

    // check the HF still greater than 1.0
    ValidateLogic.validateHealthFactor(
      poolData,
      params.onBehalf,
      IAddressProvider(ps.addressProvider).getPriceOracle()
    );

    emit Events.WithdrawERC20(
      params.msgSender,
      params.poolId,
      params.asset,
      params.amount,
      params.onBehalf,
      params.receiver
    );
  }

  function executeDepositERC721(InputTypes.ExecuteDepositERC721Params memory params) internal {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();

    DataTypes.PoolData storage poolData = ps.poolLookup[params.poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[params.asset];

    ValidateLogic.validateDepositERC721(params, poolData, assetData);

    if (params.supplyMode == Constants.SUPPLY_MODE_CROSS) {
      VaultLogic.erc721IncreaseCrossSupply(assetData, params.onBehalf, params.tokenIds);
    } else if (params.supplyMode == Constants.SUPPLY_MODE_ISOLATE) {
      VaultLogic.erc721IncreaseIsolateSupply(assetData, params.onBehalf, params.tokenIds);
    } else {
      revert(Errors.INVALID_SUPPLY_MODE);
    }

    VaultLogic.erc721TransferInLiquidity(assetData, params.msgSender, params.tokenIds);

    VaultLogic.accountCheckAndSetSuppliedAsset(poolData, assetData, params.onBehalf);

    emit Events.DepositERC721(
      params.msgSender,
      params.poolId,
      params.asset,
      params.tokenIds,
      params.supplyMode,
      params.onBehalf
    );
  }

  function executeWithdrawERC721(InputTypes.ExecuteWithdrawERC721Params memory params) internal {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();

    DataTypes.PoolData storage poolData = ps.poolLookup[params.poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[params.asset];

    ValidateLogic.validateWithdrawERC721(params, poolData, assetData);

    if (params.supplyMode == Constants.SUPPLY_MODE_CROSS) {
      VaultLogic.erc721DecreaseCrossSupply(assetData, params.onBehalf, params.tokenIds);

      VaultLogic.accountCheckAndSetSuppliedAsset(poolData, assetData, params.onBehalf);

      ValidateLogic.validateHealthFactor(
        poolData,
        params.onBehalf,
        IAddressProvider(ps.addressProvider).getPriceOracle()
      );
    } else if (params.supplyMode == Constants.SUPPLY_MODE_ISOLATE) {
      for (uint256 i = 0; i < params.tokenIds.length; i++) {
        DataTypes.IsolateLoanData storage loanData = poolData.loanLookup[params.asset][params.tokenIds[i]];
        require(loanData.loanStatus == 0, Errors.ISOLATE_LOAN_EXISTS);

        DataTypes.ERC721TokenData storage tokenData = VaultLogic.erc721GetTokenData(assetData, params.tokenIds[i]);
        require(tokenData.lockerAddr == address(0), Errors.ASSET_ALREADY_LOCKED_IN_USE);
      }

      VaultLogic.erc721DecreaseIsolateSupply(assetData, params.onBehalf, params.tokenIds);
    } else {
      revert(Errors.INVALID_SUPPLY_MODE);
    }

    VaultLogic.erc721TransferOutLiquidity(assetData, params.receiver, params.tokenIds);

    emit Events.WithdrawERC721(
      params.msgSender,
      params.poolId,
      params.asset,
      params.tokenIds,
      params.supplyMode,
      params.onBehalf,
      params.receiver
    );
  }

  function executeSetERC721SupplyMode(InputTypes.ExecuteSetERC721SupplyModeParams memory params) internal {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();

    DataTypes.PoolData storage poolData = ps.poolLookup[params.poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[params.asset];

    ValidateLogic.validatePoolBasic(poolData);
    ValidateLogic.validateAssetBasic(assetData);

    ValidateLogic.validateSenderApproved(poolData, params.msgSender, params.asset, params.onBehalf);

    for (uint256 i = 0; i < params.tokenIds.length; i++) {
      DataTypes.ERC721TokenData storage tokenData = VaultLogic.erc721GetTokenData(assetData, params.tokenIds[i]);
      require(tokenData.owner == params.onBehalf, Errors.INVALID_TOKEN_OWNER);
      require(tokenData.supplyMode != params.supplyMode, Errors.ASSET_SUPPLY_MODE_IS_SAME);
      require(tokenData.lockerAddr == address(0), Errors.ASSET_ALREADY_LOCKED_IN_USE);

      DataTypes.IsolateLoanData storage loanData = poolData.loanLookup[params.asset][params.tokenIds[i]];
      require(loanData.loanStatus == 0, Errors.ISOLATE_LOAN_EXISTS);
    }

    if (params.supplyMode == Constants.SUPPLY_MODE_CROSS) {
      VaultLogic.erc721DecreaseIsolateSupply(assetData, params.onBehalf, params.tokenIds);

      VaultLogic.erc721IncreaseCrossSupply(assetData, params.onBehalf, params.tokenIds);
    } else if (params.supplyMode == Constants.SUPPLY_MODE_ISOLATE) {
      VaultLogic.erc721DecreaseCrossSupply(assetData, params.onBehalf, params.tokenIds);

      VaultLogic.erc721IncreaseIsolateSupply(assetData, params.onBehalf, params.tokenIds);
    } else {
      revert(Errors.INVALID_SUPPLY_MODE);
    }

    VaultLogic.accountCheckAndSetSuppliedAsset(poolData, assetData, params.onBehalf);

    ValidateLogic.validateHealthFactor(
      poolData,
      params.onBehalf,
      IAddressProvider(ps.addressProvider).getPriceOracle()
    );

    emit Events.SetERC721SupplyMode(
      params.msgSender,
      params.poolId,
      params.asset,
      params.tokenIds,
      params.supplyMode,
      params.onBehalf
    );
  }
}
