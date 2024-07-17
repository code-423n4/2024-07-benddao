// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {WadRayMath} from 'src/libraries/math/WadRayMath.sol';

import '@forge-std/Test.sol';

contract TestWadRayMath is Test {
  Vm public tsHEVM = Vm(HEVM_ADDRESS);

  function test_Revert_WadMul() public {
    uint256 a = type(uint256).max;
    uint256 b = type(uint256).max;

    tsHEVM.expectRevert();
    WadRayMath.wadMul(a, b);
  }

  function test_Revert_WadDiv() public {
    uint256 a = type(uint256).max;
    uint256 b = type(uint256).max;

    tsHEVM.expectRevert();
    WadRayMath.wadDiv(a, b);

    tsHEVM.expectRevert();
    WadRayMath.wadDiv(a, 0);
  }

  function test_Revert_RayMul() public {
    uint256 a = type(uint256).max;
    uint256 b = type(uint256).max;

    tsHEVM.expectRevert();
    WadRayMath.rayMul(a, b);
  }

  function test_Revert_WadToRay() public {
    uint256 a = type(uint256).max;

    tsHEVM.expectRevert();
    WadRayMath.wadToRay(a);
  }

  function test_Revert_RayDiv() public {
    uint256 a = type(uint256).max;
    uint256 b = type(uint256).max;

    tsHEVM.expectRevert();
    WadRayMath.rayDiv(a, b);

    tsHEVM.expectRevert();
    WadRayMath.rayDiv(a, 0);
  }

  function test_Should_WadMul() public {
    uint256 a = 2 * WadRayMath.WAD;
    uint256 b = 1 * WadRayMath.WAD;

    uint256 result1 = WadRayMath.wadMul(a, b);
    uint256 result2 = WadRayMath.wadMul(b, a);
    assertEq(result1, result2, 'result1 not eq result2');

    uint256 result3 = WadRayMath.wadMul(a, 0);
    assertEq(result3, 0, 'result3 not eq 0');

    uint256 result4 = WadRayMath.wadMul(0, a);
    assertEq(result4, 0, 'result4 not eq 0');
  }

  function test_Should_WadDiv() public {
    uint256 a = 2 * WadRayMath.WAD;
    uint256 b = 1 * WadRayMath.WAD;

    uint256 result1 = WadRayMath.wadMul(a, b);
    uint256 result2 = WadRayMath.wadMul(b, a);
    assertEq(result1, result2, 'result1 not eq result2');

    uint256 result3 = WadRayMath.wadMul(a, 0);
    assertEq(result3, 0, 'result3 not eq 0');

    uint256 result4 = WadRayMath.wadMul(0, a);
    assertEq(result4, 0, 'result4 not eq 0');
  }

  function test_Should_RayMul() public {
    uint256 a = 2 * WadRayMath.RAY;
    uint256 b = 1 * WadRayMath.RAY;

    uint256 result1 = WadRayMath.rayMul(a, b);
    uint256 result2 = WadRayMath.rayMul(b, a);
    assertEq(result1, result2, 'result1 not eq result2');

    uint256 result3 = WadRayMath.rayMul(a, 0);
    assertEq(result3, 0, 'result3 not eq 0');

    uint256 result4 = WadRayMath.rayMul(0, a);
    assertEq(result4, 0, 'result4 not eq 0');
  }

  function test_Should_RayDiv() public {
    uint256 a = 2 * WadRayMath.RAY;
    uint256 b = 1 * WadRayMath.RAY;

    uint256 result1 = WadRayMath.rayDiv(a, b);
    assertEq(result1, 2 * WadRayMath.RAY, 'result1 not eq');

    uint256 result4 = WadRayMath.rayDiv(0, a);
    assertEq(result4, 0, 'result4 not eq 0');
  }

  function test_Should_WadToRay() public {
    uint256 a = 2 * WadRayMath.WAD;

    uint256 result1 = WadRayMath.wadToRay(a);
    assertEq(result1, 2 * WadRayMath.RAY, 'result1 not eq');
  }

  function test_Should_RayToWad() public {
    uint256 a = 2 * WadRayMath.RAY;
    uint256 result1 = WadRayMath.rayToWad(a);
    assertEq(result1, 2 * WadRayMath.WAD, 'result1 not eq');

    uint256 b = 2 * WadRayMath.RAY + WadRayMath.WAD_RAY_RATIO / 2 - 1;
    uint256 result2 = WadRayMath.rayToWad(b);
    assertEq(result2, 2 * WadRayMath.WAD, 'result2 not eq');

    uint256 c = 2 * WadRayMath.RAY + WadRayMath.WAD_RAY_RATIO / 2 + 1;
    uint256 result3 = WadRayMath.rayToWad(c);
    assertEq(result3, 2 * WadRayMath.WAD + 1, 'result3 not eq');
  }
}
