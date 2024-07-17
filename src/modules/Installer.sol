// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IAddressProvider} from 'src/interfaces/IAddressProvider.sol';
import {IACLManager} from 'src/interfaces/IACLManager.sol';

import {Constants} from 'src/libraries/helpers/Constants.sol';
import {Errors} from 'src/libraries/helpers/Errors.sol';
import {Events} from 'src/libraries/helpers/Events.sol';
import {DataTypes} from 'src/libraries/types/DataTypes.sol';

import {StorageSlot} from 'src/libraries/logic/StorageSlot.sol';
import {PoolLogic} from 'src/libraries/logic/PoolLogic.sol';

import {BaseModule} from 'src/base/BaseModule.sol';

contract Installer is BaseModule {
  constructor(bytes32 moduleGitCommit_) BaseModule(Constants.MODULEID__INSTALLER, moduleGitCommit_) {}

  modifier adminOnly() {
    address msgSender = unpackTrailingParamMsgSender();
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();

    IACLManager aclManager = IACLManager(IAddressProvider(ps.addressProvider).getACLManager());
    require(aclManager.isPoolAdmin(msgSender), Errors.CALLER_NOT_POOL_ADMIN);

    _;
  }

  function installModules(address[] memory moduleAddrs) external nonReentrant adminOnly {
    for (uint i = 0; i < moduleAddrs.length; ++i) {
      address moduleAddr = moduleAddrs[i];
      uint newModuleId = BaseModule(moduleAddr).moduleId();
      bytes32 moduleGitCommit = BaseModule(moduleAddr).moduleGitCommit();

      moduleLookup[newModuleId] = moduleAddr;

      if (newModuleId <= Constants.MAX_EXTERNAL_SINGLE_PROXY_MODULEID) {
        address proxyAddr = _createProxy(newModuleId);
        trustedSenders[proxyAddr].moduleImpl = moduleAddr;
      }

      emit Events.InstallerInstallModule(newModuleId, moduleAddr, moduleGitCommit);
    }
  }
}
