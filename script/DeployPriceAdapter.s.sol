// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {TransparentUpgradeableProxy} from '@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol';
import {ProxyAdmin} from '@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol';

import {IAddressProvider} from 'src/interfaces/IAddressProvider.sol';

import {Constants} from 'src/libraries/helpers/Constants.sol';

import {SDAIPriceAdapter} from 'src/oracles/SDAIPriceAdapter.sol';

import {Configured, ConfigLib, Config} from 'config/Configured.sol';
import {DeployBase} from './DeployBase.s.sol';

import '@forge-std/Script.sol';

contract DeployPriceAdapter is DeployBase {
  using ConfigLib for Config;

  function _deploy() internal virtual override {
    address proxyAdminInCfg = config.getProxyAdmin();
    require(proxyAdminInCfg != address(0), 'ProxyAdmin not exist in config');

    address addrProviderInCfg = config.getAddressProvider();
    require(addrProviderInCfg != address(0), 'AddressProvider not exist in config');

    _deploySDAIPriceAdapter(proxyAdminInCfg, addrProviderInCfg);
  }

  function _deploySDAIPriceAdapter(address /*proxyAdmin_*/, address /*addressProvider_*/) internal returns (address) {
    address daiAgg = address(0);
    address ratePot = address(0);

    uint256 chainId = config.getChainId();
    if (chainId == 1) {
      // mainnet
      revert('not support');
    } else if (chainId == 11155111) {
      // sepolia
      daiAgg = 0x14866185B1962B63C3Ea9E03Bc1da838bab34C19;
      ratePot = 0x30252a71d6bC66f772b1Ed7d07CdEa2952a0F032;
    } else {
      revert('not support');
    }

    SDAIPriceAdapter sdaiAdapter = new SDAIPriceAdapter(daiAgg, ratePot, 'sDAI / USD');

    return address(sdaiAdapter);
  }
}
