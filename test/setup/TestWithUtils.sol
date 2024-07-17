// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '@forge-std/Test.sol';

abstract contract TestWithUtils is Test {
  uint256 internal constant BLOCK_TIME = 12;

  bool internal _debugFlag;

  function setDebugFlag(bool flag) internal {
    _debugFlag = flag;
  }

  /// @dev Asserts a is approximately less than or equal to b, with a maximum absolute difference of maxDelta.
  function assertApproxLeAbs(uint256 a, uint256 b, uint256 maxDelta, string memory err) internal {
    assertLe(a, b, err);
    assertApproxEqAbs(a, b, maxDelta, err);
  }

  /// @dev Asserts a is approximately greater than or equal to b, with a maximum absolute difference of maxDelta.
  function assertApproxGeAbs(uint256 a, uint256 b, uint256 maxDelta, string memory err) internal {
    assertGe(a, b, err);
    assertApproxEqAbs(a, b, maxDelta, err);
  }

  function testEquality(uint256 _firstValue, uint256 _secondValue) internal {
    assertApproxEqAbs(_firstValue, _secondValue, 1);
  }

  function testEquality(uint256 _firstValue, uint256 _secondValue, string memory err) internal {
    assertApproxEqAbs(_firstValue, _secondValue, 1, err);
  }

  function approxMinus(uint256 a, uint256 b, uint256 maxDelta) internal pure returns (uint256) {
    if (a < b) {
      require((b - a) <= maxDelta, 'delta exceed maxDelta');
      return 0;
    }
    return a - b;
  }

  function bytes32ToAddress(bytes32 _bytes) internal pure returns (address) {
    return address(uint160(uint256(_bytes)));
  }

  /// @dev Rolls & warps the given number of blocks forward the blockchain.
  function advanceTimes(uint256 timeInSecs) internal {
    vm.roll(block.number + timeInSecs / BLOCK_TIME);
    vm.warp(block.timestamp + timeInSecs); // Block speed should depend on test network.
  }

  function advanceBlocks(uint256 blocks) internal {
    vm.roll(block.number + blocks);
    vm.warp(block.timestamp + blocks * BLOCK_TIME); // Block speed should depend on test network.
  }
}
