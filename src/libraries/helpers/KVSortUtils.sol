// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @dev Collection of sort functions related to key-value array types.
 * see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/6c9e10d72f0fdde00088eba144210e9cc78b2c65/contracts/utils/Arrays.sol.
 */
library KVSortUtils {
  struct KeyValue {
    uint256 key;
    uint256 val;
  }

  /**
   * @dev Sorts `array` of key-values in an ascending order.
   *
   * Sorting is done in-place using the heap sort algorithm.
   */
  function sort(KeyValue[] memory array) internal pure {
    unchecked {
      uint256 length = array.length;
      if (length < 2) return;

      // Heapify the array
      for (uint256 i = length / 2; i-- > 0; ) {
        _siftDown(array, length, i, array[i]);
      }

      // Drain all elements from highest to lowest and put them at the end of the array
      while (--length != 0) {
        KeyValue memory kv = array[0];
        _siftDown(array, length, 0, array[length]);
        array[length] = kv;
      }
    }
  }

  /**
   * @dev Insert a `inserted` item into an empty space in a binary heap.
   * Makes sure that the space and all items below it still form a valid heap.
   * Index `empty` is considered empty and will be overwritten.
   */
  function _siftDown(KeyValue[] memory array, uint256 length, uint256 emptyIdx, KeyValue memory inserted) private pure {
    unchecked {
      while (true) {
        // The first child of empty, one level deeper in the heap
        uint256 childIdx = (emptyIdx << 1) + 1;

        // Empty has no children
        if (childIdx >= length) break;

        KeyValue memory childItem = array[childIdx];
        uint256 otherChildIdx = childIdx + 1;

        // Pick the larger child
        if (otherChildIdx < length) {
          KeyValue memory otherChildItem = array[otherChildIdx];
          if (otherChildItem.val > childItem.val) {
            childIdx = otherChildIdx;
            childItem = otherChildItem;
          }
        }

        // No child is larger than the inserted value
        if (childItem.val <= inserted.val) break;

        // Move the larger child one level up and keep sifting down
        array[emptyIdx] = childItem;
        emptyIdx = childIdx;
      }

      array[emptyIdx] = inserted;
    }
  }
}
