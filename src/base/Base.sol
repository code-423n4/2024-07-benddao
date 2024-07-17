// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Pausable} from '@openzeppelin/contracts/security/Pausable.sol';
import {ERC721Holder} from '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';

import {Constants} from 'src/libraries/helpers/Constants.sol';
import {Events} from 'src/libraries/helpers/Events.sol';
import {Errors} from 'src/libraries/helpers/Errors.sol';

import {Storage} from 'src/base/Storage.sol';
import {Proxy} from 'src/base/Proxy.sol';

abstract contract Base is Storage, Pausable, ERC721Holder {
  constructor() {
    reentrancyLock = Constants.REENTRANCYLOCK__UNLOCKED;
  }

  // Modules

  function _createProxy(uint proxyModuleId) internal returns (address) {
    require(proxyModuleId != 0, Errors.PROXY_INVALID_MODULE);
    require(proxyModuleId <= Constants.MAX_EXTERNAL_MODULEID, Errors.PROXY_INTERNAL_MODULE);

    // If we've already created a proxy for a single-proxy module, just return it:

    if (proxyLookup[proxyModuleId] != address(0)) return proxyLookup[proxyModuleId];

    // Otherwise create a proxy:

    address proxyAddr = address(new Proxy());

    if (proxyModuleId <= Constants.MAX_EXTERNAL_SINGLE_PROXY_MODULEID) proxyLookup[proxyModuleId] = proxyAddr;

    trustedSenders[proxyAddr] = TrustedSenderInfo({moduleId: uint32(proxyModuleId), moduleImpl: address(0)});

    emit Events.ProxyCreated(proxyAddr, proxyModuleId);

    return proxyAddr;
  }

  function callInternalModule(uint moduleId, bytes memory input) internal returns (bytes memory) {
    (bool success, bytes memory result) = moduleLookup[moduleId].delegatecall(input);
    if (!success) revertBytes(result);
    return result;
  }

  // Modifiers

  modifier nonReentrant() {
    require(reentrancyLock == Constants.REENTRANCYLOCK__UNLOCKED, Errors.REENTRANCY_ALREADY_LOCKED);

    reentrancyLock = Constants.REENTRANCYLOCK__LOCKED;
    _;
    reentrancyLock = Constants.REENTRANCYLOCK__UNLOCKED;
  }

  modifier reentrantOK() {
    // documentation only
    _;
  }

  // Used to flag functions which do not modify storage, but do perform a delegate call
  // to a view function, which prohibits a standard view modifier. The flag is used to
  // patch state mutability in compiled ABIs and interfaces.
  modifier staticDelegate() {
    _;
  }

  // Error handling

  function revertBytes(bytes memory errMsg) internal pure {
    if (errMsg.length > 0) {
      assembly {
        revert(add(32, errMsg), mload(errMsg))
      }
    }

    revert(Errors.EMPTY_ERROR);
  }
}
