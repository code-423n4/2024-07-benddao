// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {KVSortUtils} from 'src/libraries/helpers/KVSortUtils.sol';

import '@forge-std/Test.sol';

contract TestUnitKVSortUtils is Test {
  Vm public tsHEVM = Vm(HEVM_ADDRESS);

  function testShouldSortWhenHasEmpty() public {
    KVSortUtils.KeyValue[] memory array = new KVSortUtils.KeyValue[](0);

    KVSortUtils.sort(array);

    assertEq(array.length, 0, 'length not eq');
  }

  function testShouldSortWhenOnlyOne() public {
    KVSortUtils.KeyValue[] memory array = new KVSortUtils.KeyValue[](1);
    array[0].key = 1234;
    array[0].val = 4321;

    KVSortUtils.sort(array);

    assertEq(array.length, 1, 'length not eq');
    assertEq(array[0].key, 1234, 'key not eq');
    assertEq(array[0].val, 4321, 'val not eq');
  }

  function testShouldSortWhenOrderIsAsc() public {
    uint256 kvNum = 3;

    KVSortUtils.KeyValue[] memory array = new KVSortUtils.KeyValue[](kvNum);
    // key: 1, 2, 3
    // val: 100, 200, 300
    for (uint256 i = 0; i < kvNum; i++) {
      array[i].key = (i + 1);
      array[i].val = (i + 1) * 100;
    }

    KVSortUtils.sort(array);

    assertEq(array.length, kvNum, 'length not eq');

    for (uint256 i = 0; i < kvNum; i++) {
      assertEq(array[i].key, (i + 1), 'key not eq');
      assertEq(array[i].val, (i + 1) * 100, 'val not eq');
    }
  }

  function testShouldSortWhenOrderIsDesc() public {
    uint256 kvNum = 3;

    KVSortUtils.KeyValue[] memory array = new KVSortUtils.KeyValue[](kvNum);
    // 3, 2, 1
    // 300, 200, 100
    for (uint256 i = 0; i < kvNum; i++) {
      array[i].key = (kvNum - i);
      array[i].val = (kvNum - i) * 100;
    }

    KVSortUtils.sort(array);

    assertEq(array.length, kvNum, 'length not eq');

    for (uint256 i = 0; i < kvNum; i++) {
      assertEq(array[i].key, (i + 1), 'key not eq');
      assertEq(array[i].val, (i + 1) * 100, 'val not eq');
    }
  }

  function testShouldSortWhenOutOfOrder() public {
    uint256 kvNum = 3;

    KVSortUtils.KeyValue[] memory array = new KVSortUtils.KeyValue[](kvNum);
    // 3, 1, 2
    // 300, 100, 200
    array[0].key = 3;
    array[0].val = 300;
    array[1].key = 1;
    array[1].val = 100;
    array[2].key = 2;
    array[2].val = 200;

    KVSortUtils.sort(array);

    assertEq(array.length, kvNum, 'length not eq');

    assertEq(array[0].key, 1, 'key not eq');
    assertEq(array[0].val, 100, 'val not eq');

    assertEq(array[1].key, 2, 'key not eq');
    assertEq(array[1].val, 200, 'val not eq');

    assertEq(array[2].key, 3, 'key not eq');
    assertEq(array[2].val, 300, 'val not eq');
  }

  function testShouldSortWhenAllIsSame() public {
    uint256 kvNum = 3;

    KVSortUtils.KeyValue[] memory array = new KVSortUtils.KeyValue[](kvNum);
    // key: 2, 2, 2
    // val: 200, 200, 200
    for (uint256 i = 0; i < kvNum; i++) {
      array[i].key = 2;
      array[i].val = 200;
    }

    KVSortUtils.sort(array);

    assertEq(array.length, kvNum, 'length not eq');

    for (uint256 i = 0; i < kvNum; i++) {
      assertEq(array[i].key, 2, 'key not eq');
      assertEq(array[i].val, 200, 'val not eq');
    }
  }

  function testShouldSortWhenPartIsSame() public {
    uint256 kvNum = 3;

    KVSortUtils.KeyValue[] memory array = new KVSortUtils.KeyValue[](kvNum);
    // 3, 2, 2
    // 300, 200, 200
    array[0].key = 3;
    array[0].val = 300;
    array[1].key = 2;
    array[1].val = 200;
    array[2].key = 2;
    array[2].val = 200;

    KVSortUtils.sort(array);

    assertEq(array.length, kvNum, 'length not eq');

    assertEq(array[0].key, 2, 'key not eq');
    assertEq(array[0].val, 200, 'val not eq');

    assertEq(array[1].key, 2, 'key not eq');
    assertEq(array[1].val, 200, 'val not eq');

    assertEq(array[2].key, 3, 'key not eq');
    assertEq(array[2].val, 300, 'val not eq');
  }
}
