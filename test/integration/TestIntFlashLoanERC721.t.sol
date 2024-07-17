// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';

import 'test/mocks/MockFlashLoanReceiver.sol';

import 'test/helpers/TestUser.sol';
import 'test/setup/TestWithBaseAction.sol';

contract TestIntFlashLoanERC721 is TestWithBaseAction {
  MockFlashLoanReceiver mockReceiver;

  struct TestCaseLocalVars {
    // prepare
    uint256[] baycTokenIds;
    uint256[] maycTokenIds;
    address[] flNftAssets;
    uint256[] flTokenIds;
    // results
    uint256 poolBalanceBefore;
    uint256 poolBalanceAfter;
  }

  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();

    mockReceiver = new MockFlashLoanReceiver();
  }

  function prepareNftTokens(TestCaseLocalVars memory testVars, bool isolate) internal {
    // deposit
    if (isolate) {
      testVars.baycTokenIds = prepareIsolateBAYC(tsDepositor1);
      testVars.maycTokenIds = prepareIsolateMAYC(tsDepositor1);
    } else {
      testVars.baycTokenIds = prepareCrossBAYC(tsDepositor1);
      testVars.maycTokenIds = prepareCrossMAYC(tsDepositor1);
    }

    testVars.flNftAssets = new address[](testVars.baycTokenIds.length + testVars.maycTokenIds.length);
    testVars.flTokenIds = new uint256[](testVars.baycTokenIds.length + testVars.maycTokenIds.length);

    uint idx = 0;
    for (uint i = 0; i < testVars.baycTokenIds.length; i++) {
      testVars.flNftAssets[idx] = address(tsBAYC);
      testVars.flTokenIds[idx] = testVars.baycTokenIds[i];
      idx++;
    }
    for (uint i = 0; i < testVars.maycTokenIds.length; i++) {
      testVars.flNftAssets[idx] = address(tsMAYC);
      testVars.flTokenIds[idx] = testVars.maycTokenIds[i];
      idx++;
    }
  }

  function test_RevertIf_IdListEmpty() public {
    address[] memory flNftAssets;
    uint256[] memory flTokenIds;

    tsHEVM.expectRevert(bytes(Errors.INVALID_ID_LIST));
    tsDepositor1.flashLoanERC721(tsCommonPoolId, flNftAssets, flTokenIds, address(mockReceiver), '');
  }

  function test_RevertIf_FlashLoanDisabled() public {
    address[] memory flNftAssets = new address[](1);
    flNftAssets[0] = address(tsBAYC);
    uint256[] memory flTokenIds = new uint256[](1);
    flTokenIds[0] = 10001;

    tsHEVM.expectRevert(bytes(Errors.ASSET_IS_FLASHLOAN_DISABLED));
    tsDepositor1.flashLoanERC721(tsCommonPoolId, flNftAssets, flTokenIds, address(mockReceiver), '');
  }

  function test_RevertIf_InvalidTokenOwner() public {
    TestCaseLocalVars memory testVars;

    tsHEVM.startPrank(tsPoolAdmin);
    tsConfigurator.setAssetFlashLoan(tsCommonPoolId, address(tsBAYC), true);
    tsConfigurator.setAssetFlashLoan(tsCommonPoolId, address(tsMAYC), true);
    tsHEVM.stopPrank();

    prepareNftTokens(testVars, false);

    tsHEVM.expectRevert(bytes(Errors.INVALID_TOKEN_OWNER));
    tsDepositor2.flashLoanERC721(tsCommonPoolId, testVars.flNftAssets, testVars.flTokenIds, address(mockReceiver), '');
  }

  function test_Should_FlashLoan_CrossTokens() public {
    TestCaseLocalVars memory testVars;

    tsHEVM.startPrank(tsPoolAdmin);
    tsConfigurator.setAssetFlashLoan(tsCommonPoolId, address(tsBAYC), true);
    tsConfigurator.setAssetFlashLoan(tsCommonPoolId, address(tsMAYC), true);
    tsHEVM.stopPrank();

    prepareNftTokens(testVars, false);

    testVars.poolBalanceBefore = tsBAYC.balanceOf(address(tsPoolManager));

    // flash loan
    tsDepositor1.flashLoanERC721(tsCommonPoolId, testVars.flNftAssets, testVars.flTokenIds, address(mockReceiver), '');

    // check results
    testVars.poolBalanceAfter = tsBAYC.balanceOf(address(tsPoolManager));
    assertEq(testVars.poolBalanceAfter, testVars.poolBalanceBefore, 'tsPoolManager balance');
  }

  function test_Should_FlashLoan_IsolateTokens() public {
    TestCaseLocalVars memory testVars;

    tsHEVM.startPrank(tsPoolAdmin);
    tsConfigurator.setAssetFlashLoan(tsCommonPoolId, address(tsBAYC), true);
    tsConfigurator.setAssetFlashLoan(tsCommonPoolId, address(tsMAYC), true);
    tsHEVM.stopPrank();

    prepareNftTokens(testVars, true);

    testVars.poolBalanceBefore = tsBAYC.balanceOf(address(tsPoolManager));

    // flash loan
    tsDepositor1.flashLoanERC721(tsCommonPoolId, testVars.flNftAssets, testVars.flTokenIds, address(mockReceiver), '');

    // check results
    testVars.poolBalanceAfter = tsBAYC.balanceOf(address(tsPoolManager));
    assertEq(testVars.poolBalanceAfter, testVars.poolBalanceBefore, 'tsPoolManager balance');
  }
}
