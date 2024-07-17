// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {TransparentUpgradeableProxy} from '@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol';
import {ProxyAdmin} from '@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol';

import {IAddressProvider} from 'src/interfaces/IAddressProvider.sol';

import {Constants} from 'src/libraries/helpers/Constants.sol';

import {YieldEthStakingLido} from 'src/yield/lido/YieldEthStakingLido.sol';
import {YieldEthStakingEtherfi} from 'src/yield/etherfi/YieldEthStakingEtherfi.sol';
import {YieldSavingsDai} from 'src/yield/sdai/YieldSavingsDai.sol';

import {YieldRegistry} from 'src/yield/YieldRegistry.sol';
import {YieldAccount} from 'src/yield/YieldAccount.sol';

import {Configured, ConfigLib, Config} from 'config/Configured.sol';
import {DeployBase} from './DeployBase.s.sol';

import '@forge-std/Script.sol';

contract DeployYieldStaking is DeployBase {
  using ConfigLib for Config;

  function _deploy() internal virtual override {
    address proxyAdminInCfg = config.getProxyAdmin();
    require(proxyAdminInCfg != address(0), 'ProxyAdmin not exist in config');

    address addrProviderInCfg = config.getAddressProvider();
    require(addrProviderInCfg != address(0), 'AddressProvider not exist in config');

    _deployYieldRegistry(proxyAdminInCfg, addrProviderInCfg);

    _deployYieldEthStakingLido(proxyAdminInCfg, addrProviderInCfg);

    _deployYieldEthStakingEtherfi(proxyAdminInCfg, addrProviderInCfg);

    _deployYieldSavingsDai(proxyAdminInCfg, addrProviderInCfg);
  }

  function _deployYieldRegistry(address proxyAdmin_, address addressProvider_) internal returns (address) {
    YieldRegistry yieldRegistryImpl = new YieldRegistry();

    TransparentUpgradeableProxy yieldRegistryProxy = new TransparentUpgradeableProxy(
      address(yieldRegistryImpl),
      address(proxyAdmin_),
      abi.encodeWithSelector(yieldRegistryImpl.initialize.selector, address(addressProvider_))
    );
    YieldRegistry yieldRegistry = YieldRegistry(address(yieldRegistryProxy));

    IAddressProvider(addressProvider_).setYieldRegistry(address(yieldRegistry));

    YieldAccount accountImpl = new YieldAccount();

    yieldRegistry.setYieldAccountImplementation(address(accountImpl));

    return address(yieldRegistry);
  }

  function _deployYieldEthStakingLido(address proxyAdmin_, address addressProvider_) internal returns (address) {
    address weth = address(0);
    address stETH = address(0);
    address unstETH = address(0);

    uint256 chainId = config.getChainId();
    if (chainId == 1) {
      // mainnet
      revert('not support');
    } else if (chainId == 11155111) {
      // sepolia
      weth = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
      stETH = 0x13c8843a3d2DEe70CAC440EEc0e7D5F587fC3e92;
      unstETH = 0xD2E252CdB70eDb72E847ee9B6BB249Ead1BFd380;
    } else {
      revert('not support');
    }

    YieldEthStakingLido yieldLidoImpl = new YieldEthStakingLido();

    TransparentUpgradeableProxy yieldLidoProxy = new TransparentUpgradeableProxy(
      address(yieldLidoImpl),
      address(proxyAdmin_),
      abi.encodeWithSelector(yieldLidoImpl.initialize.selector, address(addressProvider_), weth, stETH, unstETH)
    );
    YieldEthStakingLido yieldLido = YieldEthStakingLido(payable(yieldLidoProxy));

    return address(yieldLido);
  }

  function _deployYieldEthStakingEtherfi(address proxyAdmin_, address addressProvider_) internal returns (address) {
    address weth = address(0);
    address etherfiPool = address(0);

    uint256 chainId = config.getChainId();
    if (chainId == 1) {
      // mainnet
      revert('not support');
    } else if (chainId == 11155111) {
      // sepolia
      weth = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
      etherfiPool = 0x5794bfcBb9c72691420419102E6406163FC5c67c;
    } else {
      revert('not support');
    }

    YieldEthStakingEtherfi yieldEtherfiImpl = new YieldEthStakingEtherfi();

    TransparentUpgradeableProxy yieldEtherfiProxy = new TransparentUpgradeableProxy(
      address(yieldEtherfiImpl),
      address(proxyAdmin_),
      abi.encodeWithSelector(yieldEtherfiImpl.initialize.selector, address(addressProvider_), weth, etherfiPool)
    );
    YieldEthStakingEtherfi yieldEtherfi = YieldEthStakingEtherfi(payable(yieldEtherfiProxy));

    return address(yieldEtherfi);
  }

  function _deployYieldSavingsDai(address proxyAdmin_, address addressProvider_) internal returns (address) {
    address dai = address(0);
    address sdai = address(0);

    uint256 chainId = config.getChainId();
    if (chainId == 1) {
      // mainnet
      revert('not support');
    } else if (chainId == 11155111) {
      // sepolia
      dai = 0xf9a88B0cc31f248c89F063C2928fA10e5A029B88;
      sdai = 0x4C2A90A649eC4aAA43526637DFaaeCAD5F8a6b4c;
    } else {
      revert('not support');
    }

    YieldSavingsDai yieldSDaiImpl = new YieldSavingsDai();

    TransparentUpgradeableProxy yieldSDaiProxy = new TransparentUpgradeableProxy(
      address(yieldSDaiImpl),
      address(proxyAdmin_),
      abi.encodeWithSelector(yieldSDaiImpl.initialize.selector, address(addressProvider_), dai, sdai)
    );
    YieldSavingsDai yieldSDai = YieldSavingsDai(payable(yieldSDaiProxy));

    return address(yieldSDai);
  }
}
