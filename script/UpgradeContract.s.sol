// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ITransparentUpgradeableProxy} from '@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol';
import {ProxyAdmin} from '@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol';

import {Constants} from 'src/libraries/helpers/Constants.sol';

import {Configured, ConfigLib, Config} from 'config/Configured.sol';
import {DeployBase} from './DeployBase.s.sol';

import {IAddressProvider} from 'src/interfaces/IAddressProvider.sol';

import {AddressProvider} from 'src/AddressProvider.sol';

import {YieldEthStakingLido} from 'src/yield/lido/YieldEthStakingLido.sol';
import {YieldEthStakingEtherfi} from 'src/yield/etherfi/YieldEthStakingEtherfi.sol';
import {YieldSavingsDai} from 'src/yield/sdai/YieldSavingsDai.sol';

import '@forge-std/Script.sol';

contract UpgradeContract is DeployBase {
  using ConfigLib for Config;

  address internal addrYieldLido;
  address internal addrYieldEtherfi;
  address internal addrYieldSDai;

  function _deploy() internal virtual override {
    if (block.chainid == 11155111) {
      addrYieldLido = 0x31484Ba5772B41313B951f1b98394cfaB5d8ed8b;
      addrYieldEtherfi = 0x7dAe0FDE9a89553d65666531c2192Bf85F6edACc;
      addrYieldSDai = 0x5F695a92C0B3A595ceE43750C433e7B1109CBe3C;
    } else {
      revert('chainid not support');
    }

    address proxyAdminInCfg = config.getProxyAdmin();
    require(proxyAdminInCfg != address(0), 'ProxyAdmin not exist in config');

    address addrProviderInCfg = config.getAddressProvider();
    require(addrProviderInCfg != address(0), 'AddressProvider not exist in config');

    //_upgradeAddressProvider(proxyAdminInCfg, addrProviderInCfg);
    _upgradeYieldEthStakingLido(proxyAdminInCfg, addrProviderInCfg);
    _upgradeYieldEthStakingEtherfi(proxyAdminInCfg, addrProviderInCfg);
    _upgradeYieldSavingsDai(proxyAdminInCfg, addrProviderInCfg);
  }

  function _upgradeAddressProvider(address proxyAdmin_, address addressProvider_) internal {
    AddressProvider newImpl = new AddressProvider();

    ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdmin_);
    proxyAdmin.upgrade(ITransparentUpgradeableProxy(addressProvider_), address(newImpl));
  }

  function _upgradeYieldEthStakingLido(address proxyAdmin_, address /*addressProvider_*/) internal {
    YieldEthStakingLido newImpl = new YieldEthStakingLido();

    ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdmin_);
    proxyAdmin.upgrade(ITransparentUpgradeableProxy(addrYieldLido), address(newImpl));
  }

  function _upgradeYieldEthStakingEtherfi(address proxyAdmin_, address /*addressProvider_*/) internal {
    YieldEthStakingEtherfi newImpl = new YieldEthStakingEtherfi();

    ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdmin_);
    proxyAdmin.upgrade(ITransparentUpgradeableProxy(addrYieldEtherfi), address(newImpl));
  }

  function _upgradeYieldSavingsDai(address proxyAdmin_, address /*addressProvider_*/) internal {
    YieldSavingsDai newImpl = new YieldSavingsDai();

    ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdmin_);
    proxyAdmin.upgrade(ITransparentUpgradeableProxy(addrYieldSDai), address(newImpl));
  }
}
