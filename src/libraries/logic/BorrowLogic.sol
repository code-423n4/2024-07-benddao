// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IAddressProvider} from '../../interfaces/IAddressProvider.sol';

import {Constants} from '../helpers/Constants.sol';
import {Errors} from '../helpers/Errors.sol';
import {Events} from '../helpers/Events.sol';

import {PercentageMath} from '../math/PercentageMath.sol';

import {InputTypes} from '../types/InputTypes.sol';
import {DataTypes} from '../types/DataTypes.sol';
import {StorageSlot} from './StorageSlot.sol';

import {VaultLogic} from './VaultLogic.sol';
import {InterestLogic} from './InterestLogic.sol';
import {ValidateLogic} from './ValidateLogic.sol';

library BorrowLogic {
  using PercentageMath for uint256;

  function executeCrossBorrowERC20(InputTypes.ExecuteCrossBorrowERC20Params memory params) internal returns (uint256) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    address priceOracle = IAddressProvider(ps.addressProvider).getPriceOracle();

    DataTypes.PoolData storage poolData = ps.poolLookup[params.poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[params.asset];

    // check the basic params
    ValidateLogic.validateCrossBorrowERC20Basic(params, poolData, assetData);

    // account status need latest balance, update supply & borrow index first
    InterestLogic.updateInterestIndexs(poolData, assetData);

    // check the user account
    ValidateLogic.validateCrossBorrowERC20Account(params, poolData, assetData, priceOracle);

    // update debt state
    uint256 totalBorrowAmount;
    for (uint256 gidx = 0; gidx < params.groups.length; gidx++) {
      DataTypes.GroupData storage groupData = assetData.groupLookup[params.groups[gidx]];

      VaultLogic.erc20IncreaseCrossBorrow(groupData, params.onBehalf, params.amounts[gidx]);
      totalBorrowAmount += params.amounts[gidx];
    }

    VaultLogic.accountCheckAndSetBorrowedAsset(poolData, assetData, params.onBehalf);

    InterestLogic.updateInterestRates(poolData, assetData, 0, totalBorrowAmount);

    // transfer underlying asset to borrower
    VaultLogic.erc20TransferOutLiquidity(assetData, params.receiver, totalBorrowAmount);

    emit Events.CrossBorrowERC20(
      params.msgSender,
      params.poolId,
      params.asset,
      params.groups,
      params.amounts,
      params.onBehalf,
      params.receiver
    );

    return totalBorrowAmount;
  }

  function executeCrossRepayERC20(InputTypes.ExecuteCrossRepayERC20Params memory params) internal returns (uint256) {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();

    DataTypes.PoolData storage poolData = ps.poolLookup[params.poolId];
    DataTypes.AssetData storage assetData = poolData.assetLookup[params.asset];

    // do some basic checks, e.g. params
    ValidateLogic.validateCrossRepayERC20Basic(params, poolData, assetData);

    // account status need latest balance, update supply & borrow index first
    InterestLogic.updateInterestIndexs(poolData, assetData);

    // update debt state
    uint256 totalRepayAmount;
    for (uint256 gidx = 0; gidx < params.groups.length; gidx++) {
      DataTypes.GroupData storage groupData = assetData.groupLookup[params.groups[gidx]];

      uint256 debtAmount = VaultLogic.erc20GetUserCrossBorrowInGroup(groupData, params.onBehalf, groupData.borrowIndex);
      require(debtAmount > 0, Errors.BORROW_BALANCE_IS_ZERO);

      if (debtAmount < params.amounts[gidx]) {
        params.amounts[gidx] = debtAmount;
      }

      VaultLogic.erc20DecreaseCrossBorrow(groupData, params.onBehalf, params.amounts[gidx]);

      totalRepayAmount += params.amounts[gidx];
    }

    VaultLogic.accountCheckAndSetBorrowedAsset(poolData, assetData, params.onBehalf);

    InterestLogic.updateInterestRates(poolData, assetData, totalRepayAmount, 0);

    // transfer underlying asset from borrower to pool
    VaultLogic.erc20TransferInLiquidity(assetData, params.msgSender, totalRepayAmount);

    emit Events.CrossRepayERC20(
      params.msgSender,
      params.poolId,
      params.asset,
      params.groups,
      params.amounts,
      params.onBehalf
    );

    return totalRepayAmount;
  }
}
