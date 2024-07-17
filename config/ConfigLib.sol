// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {stdJson} from '@forge-std/StdJson.sol';

struct Config {
  string json;
}

library ConfigLib {
  using stdJson for string;

  string internal constant CHAIN_ID_PATH = '$.chainId';
  string internal constant RPC_ALIAS_PATH = '$.rpcAlias';
  string internal constant FORK_BLOCK_NUMBER_PATH = '$.forkBlockNumber';
  string internal constant WRAPPED_NATIVE_PATH = '$.wrappedNative';
  string internal constant PROXY_ADMIN_PATH = '$.ProxyAdmin';
  string internal constant ADDRESS_PROVIDER_PATH = '$.AddressProvider';
  string internal constant ACL_ADMIN_PATH = '$.ACLAdmin';
  string internal constant ACL_MANAGER_PATH = '$.ACLManager';
  string internal constant PRICE_ORACLE_PATH = '$.PriceOracle';
  string internal constant POOL_MANAGER_PATH = '$.PoolManager';
  string internal constant TREASURY_PATH = '$.treasury';

  function getAddress(Config storage config, string memory key) internal view returns (address) {
    return config.json.readAddress(string.concat('$.', key));
  }

  function getAddressArray(
    Config storage config,
    string[] memory keys
  ) internal view returns (address[] memory addresses) {
    addresses = new address[](keys.length);

    for (uint256 i; i < keys.length; ++i) {
      addresses[i] = getAddress(config, keys[i]);
    }
  }

  function getChainId(Config storage config) internal view returns (uint256) {
    return config.json.readUint(CHAIN_ID_PATH);
  }

  function getRpcAlias(Config storage config) internal view returns (string memory) {
    return config.json.readString(RPC_ALIAS_PATH);
  }

  function getForkBlockNumber(Config storage config) internal view returns (uint256) {
    return config.json.readUint(FORK_BLOCK_NUMBER_PATH);
  }

  function getWrappedNative(Config storage config) internal view returns (address) {
    return config.json.readAddress(WRAPPED_NATIVE_PATH);
  }

  function getProxyAdmin(Config storage config) internal view returns (address) {
    return config.json.readAddress(PROXY_ADMIN_PATH);
  }

  function getAddressProvider(Config storage config) internal view returns (address) {
    return config.json.readAddress(ADDRESS_PROVIDER_PATH);
  }

  function getACLAdmin(Config storage config) internal view returns (address) {
    return config.json.readAddress(ACL_ADMIN_PATH);
  }

  function getACLManager(Config storage config) internal view returns (address) {
    return config.json.readAddress(ACL_MANAGER_PATH);
  }

  function getPriceOracle(Config storage config) internal view returns (address) {
    return config.json.readAddress(PRICE_ORACLE_PATH);
  }

  function getPoolManager(Config storage config) internal view returns (address) {
    return config.json.readAddress(POOL_MANAGER_PATH);
  }

  function getTreasury(Config storage config) internal view returns (address) {
    return config.json.readAddress(TREASURY_PATH);
  }
}
