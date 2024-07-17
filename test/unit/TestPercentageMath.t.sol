// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {PercentageMath} from 'src/libraries/math/PercentageMath.sol';

import '@forge-std/Test.sol';

contract TestPercentageMath is Test {
  Vm public tsHEVM = Vm(HEVM_ADDRESS);

  function test_Revert_PercentMul() public {
    uint256 value = type(uint256).max;

    tsHEVM.expectRevert();
    PercentageMath.percentMul(value, PercentageMath.PERCENTAGE_FACTOR);
  }

  function test_Revert_PercentDiv() public {
    uint256 value = type(uint256).max;

    tsHEVM.expectRevert();
    PercentageMath.percentDiv(value, 0);
  }

  function test_Should_PercentMul() public {
    uint256 value = 100;

    uint256 result1 = PercentageMath.percentMul(value, 0);
    assertEq(result1, 0, 'result1 not eq');

    uint256 result2 = PercentageMath.percentMul(value, PercentageMath.PERCENTAGE_FACTOR);
    assertEq(result2, value, 'result2 not eq');

    uint256 result3 = PercentageMath.percentMul(value, PercentageMath.HALF_PERCENTAGE_FACTOR);
    assertEq(result3, value / 2, 'result3 not eq');
  }

  function test_Should_PercentDiv() public {
    uint256 value = 100;

    uint256 result1 = PercentageMath.percentDiv(value, PercentageMath.PERCENTAGE_FACTOR);
    assertEq(result1, 100, 'result1 not eq');

    uint256 result2 = PercentageMath.percentDiv(value, PercentageMath.PERCENTAGE_FACTOR * 2);
    assertEq(result2, value / 2, 'result2 not eq');

    uint256 result3 = PercentageMath.percentDiv(value, PercentageMath.HALF_PERCENTAGE_FACTOR);
    assertEq(result3, value * 2, 'result3 not eq');
  }
}
