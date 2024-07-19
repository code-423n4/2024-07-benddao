// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IPriceOracle} from 'src/interfaces/IPriceOracle.sol';

import {Errors} from 'src/libraries/helpers/Errors.sol';
import {PriceOracle} from 'src/PriceOracle.sol';

import 'test/mocks/MockERC20.sol';
import 'test/mocks/MockERC721.sol';
import 'test/mocks/MockChainlinkAggregator.sol';

import 'test/setup/TestWithSetup.sol';
import '@forge-std/Test.sol';

contract TestPoolManagerConfig is TestWithSetup {
  function onSetUp() public virtual override {
    super.onSetUp();
  }

  function test_RevertIf_CallerNotAdmin() public {
    tsHEVM.startPrank(address(tsHacker1));

    tsHEVM.expectRevert(bytes(Errors.CALLER_NOT_POOL_ADMIN));
    uint32 poolId1 = tsConfigurator.createPool('test 1');

    tsHEVM.expectRevert(bytes(Errors.CALLER_NOT_POOL_ADMIN));
    tsConfigurator.setPoolName(poolId1, 'test 1-1');

    tsHEVM.expectRevert(bytes(Errors.CALLER_NOT_POOL_ADMIN));
    tsConfigurator.deletePool(poolId1);

    tsHEVM.stopPrank();
  }

  // Global Configs
  function test_Should_ManagerGlobalStatus() public {
    tsHEVM.startPrank(address(tsEmergencyAdmin));

    tsConfigurator.setGlobalPause(true);

    bool isPaused1 = tsConfigurator.getGlobalPause();
    assertEq(isPaused1, true, 'isPaused1 not match');

    tsConfigurator.setGlobalPause(false);

    bool isPaused2 = tsConfigurator.getGlobalPause();
    assertEq(isPaused2, false, 'isPaused2 not match');

    tsHEVM.stopPrank();
  }

  // Pool Configs

  function test_Should_CreateAndDeletePool() public {
    tsHEVM.startPrank(address(tsPoolAdmin));

    uint32 poolId1 = tsConfigurator.createPool('test 1');
    uint32 poolId2 = tsConfigurator.createPool('test 2');

    tsConfigurator.setPoolName(poolId1, 'test 1-1');
    tsConfigurator.setPoolName(poolId2, 'test 2-1');

    tsConfigurator.deletePool(poolId1);
    tsConfigurator.deletePool(poolId2);

    tsHEVM.stopPrank();
  }

  function test_Should_ManagerPoolStatus() public {
    tsHEVM.prank(address(tsPoolAdmin));
    uint32 poolId = tsConfigurator.createPool('test 1');

    tsHEVM.prank(address(tsEmergencyAdmin));
    tsConfigurator.setPoolPause(poolId, true);

    (bool isPaused1, , , ) = tsPoolLens.getPoolConfigFlag(poolId);
    assertEq(isPaused1, true, 'isPaused1 not match');

    tsHEVM.prank(address(tsEmergencyAdmin));
    tsConfigurator.setPoolPause(poolId, false);

    (bool isPaused2, , , ) = tsPoolLens.getPoolConfigFlag(poolId);
    assertEq(isPaused2, false, 'isPaused2 not match');
  }

  function test_Should_CreateAndDeletePoolGroup() public {
    tsHEVM.startPrank(address(tsPoolAdmin));

    uint32 poolId = tsConfigurator.createPool('test 1');

    tsConfigurator.addPoolGroup(poolId, 1);
    tsConfigurator.addPoolGroup(poolId, 2);
    tsConfigurator.addPoolGroup(poolId, 3);

    uint256[] memory retGroupIds1 = tsPoolLens.getPoolGroupList(poolId);
    assertEq(retGroupIds1.length, 3, 'retGroupIds1 length not match');
    assertEq(retGroupIds1[0], 1, 'retGroupIds1 index 0 not match');

    tsConfigurator.removePoolGroup(poolId, 1);
    tsConfigurator.removePoolGroup(poolId, 2);
    tsConfigurator.removePoolGroup(poolId, 3);

    uint256[] memory retGroupIds2 = tsPoolLens.getPoolGroupList(poolId);
    assertEq(retGroupIds2.length, 0, 'retGroupIds2 length not match');

    tsHEVM.stopPrank();
  }

  function test_RevertIf_DeletePoolGroupUsedByAsset() public {
    tsHEVM.startPrank(address(tsPoolAdmin));

    uint32 poolId = tsConfigurator.createPool('test 1');
    tsConfigurator.addPoolGroup(poolId, 1);
    tsConfigurator.addPoolGroup(poolId, 2);

    tsConfigurator.addAssetERC20(poolId, address(tsDAI));
    tsConfigurator.addAssetGroup(poolId, address(tsDAI), 1, address(tsLowRateIRM));

    tsHEVM.expectRevert(bytes(Errors.GROUP_USED_BY_ASSET));
    tsConfigurator.removePoolGroup(poolId, 1);

    tsConfigurator.addAssetERC721(poolId, address(tsMAYC));
    tsConfigurator.setAssetClassGroup(poolId, address(tsMAYC), 2);

    tsHEVM.expectRevert(bytes(Errors.GROUP_USED_BY_ASSET));
    tsConfigurator.removePoolGroup(poolId, 2);

    tsHEVM.stopPrank();
  }

  function test_Should_CreateAndDeleteAssetERC20() public {
    tsHEVM.startPrank(address(tsPoolAdmin));

    uint32 poolId = tsConfigurator.createPool('test 1');

    tsConfigurator.addAssetERC20(poolId, address(tsDAI));
    tsConfigurator.addAssetERC20(poolId, address(tsUSDT));
    tsConfigurator.addAssetERC20(poolId, address(tsWETH));

    (address[] memory retAssets1, uint8[] memory retTypes1) = tsPoolLens.getPoolAssetList(poolId);
    assertEq(retAssets1.length, 3, 'retAssets1 length not match');
    assertEq(retAssets1[0], address(tsDAI), 'retAssets1 index 0 not match');
    assertEq(retTypes1.length, 3, 'retTypes1 length not match');
    assertEq(retTypes1[0], Constants.ASSET_TYPE_ERC20, 'retTypes1 index 0 not match');

    tsConfigurator.removeAssetERC20(poolId, address(tsDAI));
    tsConfigurator.removeAssetERC20(poolId, address(tsUSDT));
    tsConfigurator.removeAssetERC20(poolId, address(tsWETH));

    uint256[] memory retAssets2 = tsPoolLens.getPoolGroupList(poolId);
    assertEq(retAssets2.length, 0, 'retAssets2 length not match');

    tsHEVM.stopPrank();
  }

  function test_Should_CreateAndDeleteAssetERC721() public {
    tsHEVM.startPrank(address(tsPoolAdmin));

    uint32 poolId = tsConfigurator.createPool('test 1');

    tsConfigurator.addAssetERC721(poolId, address(tsWPUNK));
    tsConfigurator.addAssetERC721(poolId, address(tsBAYC));
    tsConfigurator.addAssetERC721(poolId, address(tsMAYC));

    (address[] memory retAssets1, uint8[] memory retTypes1) = tsPoolLens.getPoolAssetList(poolId);
    assertEq(retAssets1.length, 3, 'retAssets1 length not match');
    assertEq(retAssets1[0], address(tsWPUNK), 'retAssets1 index 0 not match');
    assertEq(retTypes1.length, 3, 'retTypes1 length not match');
    assertEq(retTypes1[0], Constants.ASSET_TYPE_ERC721, 'retTypes1 index 0 not match');

    tsConfigurator.removeAssetERC721(poolId, address(tsWPUNK));
    tsConfigurator.removeAssetERC721(poolId, address(tsBAYC));
    tsConfigurator.removeAssetERC721(poolId, address(tsMAYC));

    uint256[] memory retAssets2 = tsPoolLens.getPoolGroupList(poolId);
    assertEq(retAssets2.length, 0, 'retAssets2 length not match');

    tsHEVM.stopPrank();
  }

  function test_Should_ManagePoolYield() public {
    tsHEVM.startPrank(address(tsPoolAdmin));

    uint32 poolId = tsConfigurator.createPool('test 1');

    tsConfigurator.setPoolYieldEnable(poolId, true);
    tsConfigurator.setPoolYieldPause(poolId, true);

    (, bool isYieldEnabled1, bool isYieldPaused1, ) = tsPoolLens.getPoolConfigFlag(poolId);
    assertEq(isYieldEnabled1, true, 'isYieldEnabled1 not match');
    assertEq(isYieldPaused1, true, 'isYieldPaused1 not match');

    tsConfigurator.setPoolYieldEnable(poolId, false);
    tsConfigurator.setPoolYieldPause(poolId, false);

    (, bool isYieldEnabled2, bool isYieldPaused2, ) = tsPoolLens.getPoolConfigFlag(poolId);
    assertEq(isYieldEnabled2, false, 'isYieldEnabled2 not match');
    assertEq(isYieldPaused2, false, 'isYieldPaused2 not match');

    tsHEVM.stopPrank();
  }

  // Asset Configs

  function test_Should_CreateAndDeleteAssetGroup() public {
    tsHEVM.startPrank(address(tsPoolAdmin));

    uint32 poolId = tsConfigurator.createPool('test 1');
    tsConfigurator.addPoolGroup(poolId, 1);
    tsConfigurator.addPoolGroup(poolId, 2);
    tsConfigurator.addPoolGroup(poolId, 3);

    tsConfigurator.addAssetERC20(poolId, address(tsWETH));

    tsConfigurator.addAssetGroup(poolId, address(tsWETH), 1, address(tsLowRateIRM));
    tsConfigurator.addAssetGroup(poolId, address(tsWETH), 2, address(tsMiddleRateIRM));
    tsConfigurator.addAssetGroup(poolId, address(tsWETH), 3, address(tsHighRateIRM));

    uint256[] memory retGroupIds1 = tsPoolLens.getAssetGroupList(poolId, address(tsWETH));
    assertEq(retGroupIds1.length, 3, 'retGroupIds1 length not match');
    assertEq(retGroupIds1[1], 2, 'retGroupIds1 index 1 not match');

    tsConfigurator.removeAssetGroup(poolId, address(tsWETH), 1);
    tsConfigurator.removeAssetGroup(poolId, address(tsWETH), 2);
    tsConfigurator.removeAssetGroup(poolId, address(tsWETH), 3);

    uint256[] memory retGroupIds2 = tsPoolLens.getAssetGroupList(poolId, address(tsWETH));
    assertEq(retGroupIds2.length, 0, 'retGroupIds1 length not match');

    tsHEVM.stopPrank();
  }

  function test_Should_ManagerAssetStatus() public {
    tsHEVM.startPrank(address(tsPoolAdmin));

    uint32 poolId = tsConfigurator.createPool('test 1');
    tsConfigurator.addAssetERC20(poolId, address(tsWETH));

    tsConfigurator.setAssetActive(poolId, address(tsWETH), true);
    tsConfigurator.setAssetFrozen(poolId, address(tsWETH), true);
    tsConfigurator.setAssetPause(poolId, address(tsWETH), true);

    (bool isActive1, bool isFrozen1, bool isPaused1, , , ) = tsPoolLens.getAssetConfigFlag(poolId, address(tsWETH));
    assertEq(isActive1, true, 'isActive1 not match');
    assertEq(isFrozen1, true, 'isFrozen1 not match');
    assertEq(isPaused1, true, 'isPaused1 not match');

    tsConfigurator.setAssetActive(poolId, address(tsWETH), false);
    tsConfigurator.setAssetFrozen(poolId, address(tsWETH), false);
    tsConfigurator.setAssetPause(poolId, address(tsWETH), false);

    (bool isActive2, bool isFrozen2, bool isPaused2, , , ) = tsPoolLens.getAssetConfigFlag(poolId, address(tsWETH));
    assertEq(isActive2, false, 'isActive2 not match');
    assertEq(isFrozen2, false, 'isFrozen2 not match');
    assertEq(isPaused2, false, 'isPaused2 not match');

    tsHEVM.stopPrank();
  }

  function test_Should_ManageAssetCap() public {
    tsHEVM.startPrank(address(tsPoolAdmin));

    uint32 poolId = tsConfigurator.createPool('test 1');
    tsConfigurator.addAssetERC20(poolId, address(tsWETH));

    tsConfigurator.setAssetSupplyCap(poolId, address(tsWETH), 220 ether);
    tsConfigurator.setAssetBorrowCap(poolId, address(tsWETH), 150 ether);
    tsConfigurator.setAssetYieldCap(poolId, address(tsWETH), 2000); // 20%

    (uint256 supplyCap1, uint256 borrowCap1, uint256 yieldCap1) = tsPoolLens.getAssetConfigCap(poolId, address(tsWETH));
    assertEq(supplyCap1, 220 ether, 'supplyCap1 not match');
    assertEq(borrowCap1, 150 ether, 'borrowCap1 not match');
    assertEq(yieldCap1, 2000, 'yieldCap1 not match');

    tsConfigurator.setAssetSupplyCap(poolId, address(tsWETH), 0 ether);
    tsConfigurator.setAssetBorrowCap(poolId, address(tsWETH), 0 ether);
    tsConfigurator.setAssetYieldCap(poolId, address(tsWETH), 0); // 0%

    (uint256 supplyCap2, uint256 borrowCap2, uint256 yieldCap2) = tsPoolLens.getAssetConfigCap(poolId, address(tsWETH));
    assertEq(supplyCap2, 0, 'supplyCap1 not match');
    assertEq(borrowCap2, 0, 'borrowCap1 not match');
    assertEq(yieldCap2, 0, 'yieldCap1 not match');

    tsHEVM.stopPrank();
  }

  function test_Should_ManageAssetClassGroupAndRate() public {
    tsHEVM.startPrank(address(tsPoolAdmin));

    uint32 poolId = tsConfigurator.createPool('test 1');
    tsConfigurator.addPoolGroup(poolId, 1);
    tsConfigurator.addPoolGroup(poolId, 2);

    tsConfigurator.addAssetERC20(poolId, address(tsWETH));
    tsConfigurator.addAssetGroup(poolId, address(tsWETH), 1, address(tsLowRateIRM));

    // test class group
    tsConfigurator.setAssetClassGroup(poolId, address(tsWETH), 1);

    (uint256 classGroup1, , , , ) = tsPoolLens.getAssetLendingConfig(poolId, address(tsWETH));
    assertEq(classGroup1, 1, 'classGroup1 not match');

    tsConfigurator.setAssetClassGroup(poolId, address(tsWETH), 2);

    (uint256 classGroup2, , , , ) = tsPoolLens.getAssetLendingConfig(poolId, address(tsWETH));
    assertEq(classGroup2, 2, 'classGroup1 not match');

    // test group rate
    tsConfigurator.setAssetLendingRate(poolId, address(tsWETH), 1, address(tsHighRateIRM));

    (, , , , , , address rateModel1) = tsPoolLens.getAssetGroupData(poolId, address(tsWETH), 1);
    assertEq(rateModel1, address(tsHighRateIRM), 'rateModel1 not match');

    tsHEVM.stopPrank();
  }

  function test_Should_ManageAssetYield() public {
    tsHEVM.startPrank(address(tsPoolAdmin));

    uint32 poolId = tsConfigurator.createPool('test 1');
    tsConfigurator.setPoolYieldEnable(poolId, true);
    tsConfigurator.addAssetERC20(poolId, address(tsWETH));

    tsConfigurator.setAssetYieldEnable(poolId, address(tsWETH), true);
    tsConfigurator.setAssetYieldPause(poolId, address(tsWETH), true);

    (, , , , bool isYieldEnabled1, bool isYieldPaused1) = tsPoolLens.getAssetConfigFlag(poolId, address(tsWETH));
    assertEq(isYieldEnabled1, true, 'isYieldEnabled1 not match');
    assertEq(isYieldPaused1, true, 'isYieldPaused1 not match');

    tsConfigurator.setAssetYieldEnable(poolId, address(tsWETH), false);
    tsConfigurator.setAssetYieldPause(poolId, address(tsWETH), false);

    (, , , , bool isYieldEnabled2, bool isYieldPaused2) = tsPoolLens.getAssetConfigFlag(poolId, address(tsWETH));
    assertEq(isYieldEnabled2, false, 'isYieldEnabled2 not match');
    assertEq(isYieldPaused2, false, 'isYieldPaused2 not match');

    tsHEVM.stopPrank();
  }
}
