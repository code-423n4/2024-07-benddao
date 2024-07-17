// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Config, ConfigLib} from 'config/ConfigLib.sol';

import {StdChains, VmSafe} from '@forge-std/StdChains.sol';

contract Configured is StdChains {
  using ConfigLib for Config;

  VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256('hevm cheat code')))));

  Config internal config;

  address internal cfgWrappedNative;

  function _network() internal view virtual returns (string memory) {
    return vm.envString('NETWORK');
  }

  function _rpcAlias() internal virtual returns (string memory) {
    return config.getRpcAlias();
  }

  function _initConfig() internal returns (Config storage) {
    if (bytes(config.json).length == 0) {
      string memory root = vm.projectRoot();
      string memory path = string.concat(root, '/config/', _network(), '.json');

      config.json = vm.readFile(path);
    }

    return config;
  }

  function _loadConfig() internal virtual {
    cfgWrappedNative = config.getWrappedNative();
  }
}
