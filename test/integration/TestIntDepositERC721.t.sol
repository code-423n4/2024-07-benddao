// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';

import 'test/setup/TestWithBaseAction.sol';

contract TestIntDepositERC721 is TestWithBaseAction {
  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_RevertIf_InsufficientAllowance() public {
    uint256[] memory tokenIds = tsDepositor1.getTokenIds();

    tsDepositor1.setApprovalForAllERC721(address(tsBAYC), false);

    actionDepositERC721(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      Constants.SUPPLY_MODE_CROSS,
      bytes('ERC721: caller is not token owner or approved')
    );
  }

  function test_RevertIf_NotOwner() public {
    uint256[] memory tokenIds = tsDepositor2.getTokenIds();

    tsDepositor1.setApprovalForAllERC721(address(tsBAYC), true);

    actionDepositERC721(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsBAYC),
      tokenIds,
      Constants.SUPPLY_MODE_CROSS,
      bytes('ERC721: caller is not token owner or approved')
    );
  }

  function test_Should_Deposit_Cross() public {
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
  }

  function test_Should_Deposit_Isolate() public {
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
  }
}
