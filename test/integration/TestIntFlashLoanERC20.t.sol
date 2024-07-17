// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';

import 'test/mocks/MockFlashLoanReceiver.sol';

import 'test/helpers/TestUser.sol';
import 'test/setup/TestWithBaseAction.sol';

contract TestIntFlashLoanERC20 is TestWithBaseAction {
  MockFlashLoanReceiver mockReceiver;

  struct TestCaseLocalVars {
    // prepare
    address[] flAssets;
    uint256[] flAmounts;
    // results
    uint256 poolBalanceBefore1;
    uint256 poolBalanceAfter1;
    uint256 poolBalanceBefore2;
    uint256 poolBalanceAfter2;
  }

  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();

    mockReceiver = new MockFlashLoanReceiver();
  }

  function prepareERC20Tokens(TestCaseLocalVars memory testVars) internal {
    // deposit
    prepareUSDT(tsDepositor1);
    prepareWETH(tsDepositor1);

    testVars.flAssets = new address[](2);
    testVars.flAmounts = new uint256[](2);

    testVars.flAssets[0] = address(tsWETH);
    testVars.flAmounts[0] = 123 * (10 ** tsWETH.decimals());
    testVars.flAssets[1] = address(tsUSDT);
    testVars.flAmounts[1] = 12345 * (10 ** tsUSDT.decimals());
  }

  function test_RevertIf_IdListEmpty() public {
    address[] memory flAssets;
    uint256[] memory flAmounts;

    tsHEVM.expectRevert(bytes(Errors.INVALID_ID_LIST));
    tsDepositor1.flashLoanERC20(tsCommonPoolId, flAssets, flAmounts, address(mockReceiver), '');
  }

  function test_RevertIf_FlashLoanDisabled() public {
    address[] memory flAssets = new address[](1);
    flAssets[0] = address(tsWETH);
    uint256[] memory flAmounts = new uint256[](1);
    flAmounts[0] = 100;

    tsHEVM.expectRevert(bytes(Errors.ASSET_IS_FLASHLOAN_DISABLED));
    tsDepositor1.flashLoanERC20(tsCommonPoolId, flAssets, flAmounts, address(mockReceiver), '');
  }

  function test_Should_FlashLoan() public {
    TestCaseLocalVars memory testVars;

    tsHEVM.startPrank(tsPoolAdmin);
    tsConfigurator.setAssetFlashLoan(tsCommonPoolId, address(tsWETH), true);
    tsConfigurator.setAssetFlashLoan(tsCommonPoolId, address(tsUSDT), true);
    tsHEVM.stopPrank();

    prepareERC20Tokens(testVars);

    testVars.poolBalanceBefore1 = tsWETH.balanceOf(address(tsPoolManager));
    testVars.poolBalanceBefore2 = tsUSDT.balanceOf(address(tsPoolManager));

    // flash loan
    tsDepositor1.flashLoanERC20(tsCommonPoolId, testVars.flAssets, testVars.flAmounts, address(mockReceiver), '');

    // check results
    testVars.poolBalanceAfter1 = tsWETH.balanceOf(address(tsPoolManager));
    assertEq(testVars.poolBalanceAfter1, testVars.poolBalanceBefore1, 'tsPoolManager poolBalanceAfter1');

    testVars.poolBalanceAfter2 = tsUSDT.balanceOf(address(tsPoolManager));
    assertEq(testVars.poolBalanceAfter2, testVars.poolBalanceBefore2, 'tsPoolManager poolBalanceAfter2');
  }
}
