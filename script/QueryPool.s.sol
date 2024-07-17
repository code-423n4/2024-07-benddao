// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Constants} from 'src/libraries/helpers/Constants.sol';

import {Configured, ConfigLib, Config} from 'config/Configured.sol';
import {QueryBase} from './QueryBase.s.sol';

import {PoolManager} from 'src/PoolManager.sol';
import {PoolLens} from 'src/modules/PoolLens.sol';

import '@forge-std/Script.sol';

contract QueryPool is QueryBase {
  using ConfigLib for Config;

  function _query() internal virtual override {
    address addressInCfg = config.getPoolManager();
    require(addressInCfg != address(0), 'PoolManager not exist in config');

    PoolManager poolManager = PoolManager(payable(addressInCfg));

    PoolLens poolLens = PoolLens(poolManager.moduleIdToProxy(Constants.MODULEID__POOL_LENS));

    poolLens.getUserAccountData(0x8b04B42962BeCb429a4dBFb5025b66D3d7D31d27, 1);

    poolLens.getUserAccountGroupData(0x8b04B42962BeCb429a4dBFb5025b66D3d7D31d27, 1);
  }
}
