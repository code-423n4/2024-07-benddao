// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';

import 'test/setup/TestWithBaseAction.sol';

contract TestIntWithdrawERC721 is TestWithBaseAction {
  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_RevertIf_ListEmpty() public {
    uint256[] memory tokenIds = new uint256[](0);

    actionWithdrawERC721(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      Constants.SUPPLY_MODE_CROSS,
      bytes(Errors.INVALID_ID_LIST)
    );
  }

  function test_Should_Withdraw_Cross() public {
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

    actionWithdrawERC721(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      Constants.SUPPLY_MODE_CROSS,
      new bytes(0)
    );
  }

  function test_Should_Withdraw_Isolate() public {
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

    actionWithdrawERC721(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      Constants.SUPPLY_MODE_ISOLATE,
      new bytes(0)
    );
  }
}
