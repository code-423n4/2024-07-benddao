// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';

import 'test/setup/TestWithBaseAction.sol';

contract TestIntSetERC721SupplyMode is TestWithBaseAction {
  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_Should_SetMode_Cross2Isolate() public {
    uint256[] memory tokenIds = tsDepositor1.getTokenIds();

    tsDepositor1.setApprovalForAllERC721(address(tsBAYC), true);

    actionDepositERC721(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      Constants.SUPPLY_MODE_CROSS,
      new bytes(0)
    );

    tsDepositor1.setERC721SupplyMode(
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      Constants.SUPPLY_MODE_ISOLATE,
      address(tsDepositor1)
    );

    actionWithdrawERC721(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      Constants.SUPPLY_MODE_ISOLATE,
      new bytes(0)
    );
  }

  function test_Should_SetMode_Isolate2Cross() public {
    uint256[] memory tokenIds = tsDepositor1.getTokenIds();

    tsDepositor1.setApprovalForAllERC721(address(tsBAYC), true);

    actionDepositERC721(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      Constants.SUPPLY_MODE_ISOLATE,
      new bytes(0)
    );

    tsDepositor1.setERC721SupplyMode(
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      Constants.SUPPLY_MODE_CROSS,
      address(tsDepositor1)
    );

    actionWithdrawERC721(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      Constants.SUPPLY_MODE_CROSS,
      new bytes(0)
    );
  }
}
