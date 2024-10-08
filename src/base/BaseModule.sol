// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Base} from './Base.sol';

abstract contract BaseModule is Base {
  // Construction

  // public accessors common to all modules

  uint public immutable moduleId;
  bytes32 public immutable moduleGitCommit;

  constructor(uint moduleId_, bytes32 moduleGitCommit_) {
    moduleId = moduleId_;
    moduleGitCommit = moduleGitCommit_;
  }

  // Accessing parameters

  function unpackTrailingParamMsgSender() internal pure returns (address msgSender) {
    assembly {
      msgSender := shr(96, calldataload(sub(calldatasize(), 40)))
    }
  }

  function unpackTrailingParams() internal pure returns (address msgSender, address proxyAddr) {
    assembly {
      msgSender := shr(96, calldataload(sub(calldatasize(), 40)))
      proxyAddr := shr(96, calldataload(sub(calldatasize(), 20)))
    }
  }

  // Emit logs via proxies
}
