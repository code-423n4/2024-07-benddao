// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Constants} from 'src/libraries/helpers/Constants.sol';

import {PoolManager} from 'src/PoolManager.sol';
import {Installer} from 'src/modules/Installer.sol';
import {Configurator} from 'src/modules/Configurator.sol';
import {BVault} from 'src/modules/BVault.sol';
import {CrossLending} from 'src/modules/CrossLending.sol';
import {CrossLiquidation} from 'src/modules/CrossLiquidation.sol';
import {IsolateLending} from 'src/modules/IsolateLending.sol';
import {IsolateLiquidation} from 'src/modules/IsolateLiquidation.sol';
import {Yield} from 'src/modules/Yield.sol';
import {FlashLoan} from 'src/modules/FlashLoan.sol';
import {PoolLens} from 'src/modules/PoolLens.sol';

import {Configured, ConfigLib, Config} from 'config/Configured.sol';
import {DeployBase} from './DeployBase.s.sol';

import '@forge-std/Script.sol';

contract InstallModule is DeployBase {
  using ConfigLib for Config;

  function _deploy() internal virtual override {
    address addressInCfg = config.getPoolManager();
    require(addressInCfg != address(0), 'PoolManager not exist in config');

    PoolManager poolManager = PoolManager(payable(addressInCfg));

    Installer installer = Installer(poolManager.moduleIdToProxy(Constants.MODULEID__INSTALLER));

    //address[] memory modules = _allModules();
    address[] memory modules = _someModules();

    installer.installModules(modules);
  }

  function _someModules() internal returns (address[] memory) {
    address[] memory modules = new address[](1);
    uint modIdx = 0;

    PoolLens tsPoolLensImpl = new PoolLens(gitCommitHash);
    modules[modIdx++] = address(tsPoolLensImpl);

    return modules;
  }

  function _allModules() internal returns (address[] memory) {
    address[] memory modules = new address[](9);
    uint modIdx = 0;

    Configurator tsConfiguratorImpl = new Configurator(gitCommitHash);
    modules[modIdx++] = address(tsConfiguratorImpl);

    BVault tsVaultImpl = new BVault(gitCommitHash);
    modules[modIdx++] = address(tsVaultImpl);

    CrossLending tsCrossLendingImpl = new CrossLending(gitCommitHash);
    modules[modIdx++] = address(tsCrossLendingImpl);

    CrossLiquidation tsCrossLiquidationImpl = new CrossLiquidation(gitCommitHash);
    modules[modIdx++] = address(tsCrossLiquidationImpl);

    IsolateLending tsIsolateLendingImpl = new IsolateLending(gitCommitHash);
    modules[modIdx++] = address(tsIsolateLendingImpl);

    IsolateLiquidation tsIsolateLiquidationImpl = new IsolateLiquidation(gitCommitHash);
    modules[modIdx++] = address(tsIsolateLiquidationImpl);

    Yield tsYieldImpl = new Yield(gitCommitHash);
    modules[modIdx++] = address(tsYieldImpl);

    FlashLoan tsFlashLoanImpl = new FlashLoan(gitCommitHash);
    modules[modIdx++] = address(tsFlashLoanImpl);

    PoolLens tsPoolLensImpl = new PoolLens(gitCommitHash);
    modules[modIdx++] = address(tsPoolLensImpl);

    return modules;
  }
}
