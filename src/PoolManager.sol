// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IAddressProvider} from 'src/interfaces/IAddressProvider.sol';
import {IACLManager} from 'src/interfaces/IACLManager.sol';

import {Constants} from 'src/libraries/helpers/Constants.sol';
import {Errors} from 'src/libraries/helpers/Errors.sol';
import {StorageSlot} from 'src/libraries/logic/StorageSlot.sol';
import {DataTypes} from 'src/libraries/types/DataTypes.sol';

import {Base} from 'src/base/Base.sol';
import {Proxy} from 'src/base/Proxy.sol';

/// @notice Main storage contract
contract PoolManager is Base {
  string public constant name = 'Bend Protocol V2';

  constructor(address provider_, address installerModule) {
    reentrancyLock = Constants.REENTRANCYLOCK__UNLOCKED;

    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();
    ps.addressProvider = provider_;
    ps.nextPoolId = Constants.INITIAL_POOL_ID;

    ps.wrappedNativeToken = IAddressProvider(ps.addressProvider).getWrappedNativeToken();
    require(ps.wrappedNativeToken != address(0), Errors.INVALID_ADDRESS);

    moduleLookup[Constants.MODULEID__INSTALLER] = installerModule;
    address installerProxy = _createProxy(Constants.MODULEID__INSTALLER);
    trustedSenders[installerProxy].moduleImpl = installerModule;
  }

  /// @notice Lookup the current implementation contract for a module
  /// @param moduleId Fixed constant that refers to a module type
  /// @return An internal address specifies the module's implementation code
  function moduleIdToImplementation(uint moduleId) external view returns (address) {
    return moduleLookup[moduleId];
  }

  /// @notice Lookup a proxy that can be used to interact with a module (only valid for single-proxy modules)
  /// @param moduleId Fixed constant that refers to a module type
  /// @return An address that should be cast to the appropriate module interface
  function moduleIdToProxy(uint moduleId) external view returns (address) {
    return proxyLookup[moduleId];
  }

  function dispatch() external payable reentrantOK {
    // only trusted proxy
    uint32 moduleId = trustedSenders[msg.sender].moduleId;
    address moduleImpl = trustedSenders[msg.sender].moduleImpl;

    require(moduleId != 0, Errors.PROXY_SENDER_NOT_TRUST);

    // multi proxy module
    if (moduleImpl == address(0)) moduleImpl = moduleLookup[moduleId];

    uint msgDataLength = msg.data.length;
    require(msgDataLength >= (4 + 4 + 20), Errors.PROXY_MSGDATA_TOO_SHORT);

    assembly {
      let payloadSize := sub(calldatasize(), 4)
      calldatacopy(0, 4, payloadSize)
      mstore(payloadSize, shl(96, caller()))

      let result := delegatecall(gas(), moduleImpl, 0, add(payloadSize, 20), 0, 0)

      returndatacopy(0, 0, returndatasize())

      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }

  receive() external payable {}

  modifier onlyPoolAdmin() {
    _onlyPoolAdmin();

    _;
  }

  function _onlyPoolAdmin() internal view {
    DataTypes.PoolStorage storage ps = StorageSlot.getPoolStorage();

    IACLManager aclManager = IACLManager(IAddressProvider(ps.addressProvider).getACLManager());
    require(aclManager.isPoolAdmin(msg.sender), Errors.CALLER_NOT_POOL_ADMIN);
  }

  /* @notice only used when user transfer ETH to contract by mistake */
  function emergencyEtherTransfer(address to, uint256 amount) public onlyPoolAdmin {
    (bool success, ) = to.call{value: amount}(new bytes(0));
    require(success, Errors.ETH_TRANSFER_FAILED);
  }

  /* @notice only used when user transfer ETH to module contract by mistake */
  function emergencyProxyEtherTransfer(address proxyAddr, address to, uint256 amount) public onlyPoolAdmin {
    Proxy proxy = Proxy(payable(proxyAddr));
    proxy.emergencyEtherTransfer(to, amount);
  }
}
