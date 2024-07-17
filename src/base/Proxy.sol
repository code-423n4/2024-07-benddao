// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

contract Proxy {
  address immutable creator;

  constructor() {
    creator = msg.sender;
  }

  // External interface

  receive() external payable {}

  fallback() external payable {
    address creator_ = creator;
    uint value = msg.value;

    if (msg.sender == creator_) {
      assembly {
        mstore(0, 0)
        calldatacopy(31, 0, calldatasize())

        switch mload(0) // numTopics
        case 0 {
          log0(32, sub(calldatasize(), 1))
        }
        case 1 {
          log1(64, sub(calldatasize(), 33), mload(32))
        }
        case 2 {
          log2(96, sub(calldatasize(), 65), mload(32), mload(64))
        }
        case 3 {
          log3(128, sub(calldatasize(), 97), mload(32), mload(64), mload(96))
        }
        case 4 {
          log4(160, sub(calldatasize(), 129), mload(32), mload(64), mload(96), mload(128))
        }
        default {
          revert(0, 0)
        }

        return(0, 0)
      }
    } else {
      assembly {
        mstore(0, 0xe9c4a3ac00000000000000000000000000000000000000000000000000000000) // dispatch() selector
        calldatacopy(4, 0, calldatasize())
        mstore(add(4, calldatasize()), shl(96, caller()))

        let result := call(gas(), creator_, value, 0, add(24, calldatasize()), 0, 0)
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
  }

  /* @notice only used when user transfer ETH to contract by mistake */
  function emergencyEtherTransfer(address to, uint256 amount) public {
    require(msg.sender == creator, 'Invalid caller');

    (bool success, ) = to.call{value: amount}(new bytes(0));
    require(success, 'ETH_TRANSFER_FAILED');
  }
}
