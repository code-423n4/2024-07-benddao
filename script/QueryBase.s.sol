// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Configured, ConfigLib, Config} from 'config/Configured.sol';

import '@forge-std/Script.sol';

abstract contract QueryBase is Script, Configured {
  using ConfigLib for Config;
  address internal deployer;
  bytes32 internal gitCommitHash;
  string internal etherscanKey;

  function run() external {
    _initConfig();

    _loadConfig();

    _query();
  }

  function _query() internal virtual {}
}
