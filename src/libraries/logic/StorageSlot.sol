// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {DataTypes} from '../types/DataTypes.sol';

library StorageSlot {
  // keccak256(abi.encode(uint256(keccak256("benddao.storage.v2.pool")) - 1)) & ~bytes32(uint256(0xff));
  bytes32 constant STORAGE_POSITION_POOL = 0xce044ef5c897ad3fe9fcce02f9f2b7dc69de8685dee403b46b4b685baa720200;

  function getPoolStorage() internal pure returns (DataTypes.PoolStorage storage rs) {
    bytes32 position = STORAGE_POSITION_POOL;
    assembly {
      rs.slot := position
    }
  }
}
