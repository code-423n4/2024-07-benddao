// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';

import 'test/setup/TestWithPrepare.sol';

contract TestIntCrossOnBehalf is TestWithPrepare {
  struct TestCaseLocalVars {
    // results
    // sender
    TestUserAssetData senderAssetDataBefore;
    TestUserAssetData senderAssetDataAfter;
    // onBehalf
    TestUserAssetData onBehalfAssetDataBefore;
    TestUserAssetData onBehalfAssetDataAfter;
    // receiver
    TestUserAssetData receiverAssetDataBefore;
    TestUserAssetData receiverAssetDataAfter;
  }

  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_RevertIf_Deposit_OnBehalf_Is_Zero() public {
    tsDepositor1.approveERC20(address(tsWETH), type(uint256).max);

    // deposit
    uint256 amount1 = 123 ether;
    tsHEVM.expectRevert(bytes(Errors.INVALID_ONBEHALF_ADDRESS));
    tsDepositor1.depositERC20(tsCommonPoolId, address(tsWETH), amount1, address(0));
  }

  function test_Should_Deposit_OnBehalf() public {
    tsDepositor1.approveERC20(address(tsWETH), type(uint256).max);

    // deposit
    TestCaseLocalVars memory testVars;
    testVars.senderAssetDataBefore = getUserAssetData(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.onBehalfAssetDataBefore = getUserAssetData(
      address(tsDepositor2),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );

    uint256 amount1 = 123 ether;
    tsDepositor1.depositERC20(tsCommonPoolId, address(tsWETH), amount1, address(tsDepositor2));

    testVars.senderAssetDataAfter = getUserAssetData(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.onBehalfAssetDataAfter = getUserAssetData(
      address(tsDepositor2),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );

    assertEq(
      testVars.senderAssetDataAfter.walletBalance,
      (testVars.senderAssetDataBefore.walletBalance - amount1),
      'sender.walletBalance not eq'
    );
    assertEq(
      testVars.onBehalfAssetDataAfter.walletBalance,
      (testVars.onBehalfAssetDataBefore.walletBalance),
      'onBehalf.walletBalance not eq'
    );

    assertEq(
      testVars.senderAssetDataAfter.totalCrossSupply,
      testVars.senderAssetDataBefore.totalCrossSupply,
      'sender.totalCrossSupply not eq'
    );
    assertEq(
      testVars.onBehalfAssetDataAfter.totalCrossSupply,
      (testVars.onBehalfAssetDataBefore.totalCrossSupply + amount1),
      'onBehalf.totalCrossSupply not eq'
    );
  }

  function test_RevertIf_Withdraw_OnBehalf_Invalid_Params() public {
    tsDepositor1.approveERC20(address(tsWETH), type(uint256).max);

    // deposit
    uint256 amount1 = 123 ether;
    tsDepositor1.depositERC20(tsCommonPoolId, address(tsWETH), amount1, address(tsDepositor2));

    // not approved
    tsHEVM.expectRevert(bytes(Errors.SENDER_NOT_APPROVED));
    tsDepositor1.withdrawERC20(tsCommonPoolId, address(tsWETH), amount1, address(tsDepositor2), address(tsDepositor3));

    // invalid receiver
    tsDepositor2.setApprovalForAll(tsCommonPoolId, address(tsWETH), address(tsDepositor1), true);

    tsHEVM.expectRevert(bytes(Errors.INVALID_TO_ADDRESS));
    tsDepositor1.withdrawERC20(tsCommonPoolId, address(tsWETH), amount1, address(tsDepositor2), address(0));
  }

  function test_Should_Withdraw_OnBehalf() public {
    tsDepositor1.approveERC20(address(tsWETH), type(uint256).max);

    // deposit
    uint256 amount1 = 123 ether;
    tsDepositor1.depositERC20(tsCommonPoolId, address(tsWETH), amount1, address(tsDepositor2));

    // withdraw
    TestCaseLocalVars memory testVars;

    testVars.senderAssetDataBefore = getUserAssetData(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.onBehalfAssetDataBefore = getUserAssetData(
      address(tsDepositor2),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.receiverAssetDataBefore = getUserAssetData(
      address(tsDepositor3),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );

    tsDepositor2.setApprovalForAll(tsCommonPoolId, address(tsWETH), address(tsDepositor1), true);

    tsDepositor1.withdrawERC20(tsCommonPoolId, address(tsWETH), amount1, address(tsDepositor2), address(tsDepositor3));

    testVars.senderAssetDataAfter = getUserAssetData(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.onBehalfAssetDataAfter = getUserAssetData(
      address(tsDepositor2),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.receiverAssetDataAfter = getUserAssetData(
      address(tsDepositor3),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );

    assertEq(
      testVars.senderAssetDataAfter.walletBalance,
      (testVars.senderAssetDataBefore.walletBalance),
      'sender.walletBalance not eq'
    );
    assertEq(
      testVars.onBehalfAssetDataAfter.walletBalance,
      (testVars.onBehalfAssetDataBefore.walletBalance),
      'onBehalf.walletBalance not eq'
    );
    assertEq(
      testVars.receiverAssetDataAfter.walletBalance,
      (testVars.receiverAssetDataBefore.walletBalance + amount1),
      'receiver.walletBalance not eq'
    );

    assertEq(
      testVars.senderAssetDataAfter.totalCrossSupply,
      testVars.senderAssetDataBefore.totalCrossSupply,
      'sender.totalCrossSupply not eq'
    );
    assertEq(
      testVars.onBehalfAssetDataAfter.totalCrossSupply,
      (testVars.onBehalfAssetDataBefore.totalCrossSupply - amount1),
      'onBehalf.totalCrossSupply not eq'
    );
    assertEq(
      testVars.receiverAssetDataAfter.totalCrossSupply,
      (testVars.receiverAssetDataBefore.totalCrossSupply),
      'receiver.totalCrossSupply not eq'
    );
  }

  function test_RevertIf_Borrow_OnBehalf_Invalid_Params() public {
    // prepare
    prepareWETH(tsDepositor1);

    prepareCrossBAYC(tsBorrower2);

    // borrow
    TestCaseLocalVars memory testVars;

    testVars.senderAssetDataBefore = getUserAssetData(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.onBehalfAssetDataBefore = getUserAssetData(
      address(tsBorrower2),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.receiverAssetDataBefore = getUserAssetData(
      address(tsBorrower3),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );

    // calculate borrow amount
    TestUserAccountData memory accountDataBeforeBorrow = getUserAccountData(address(tsBorrower2), tsCommonPoolId);

    uint8[] memory borrowGroups1 = new uint8[](1);
    borrowGroups1[0] = tsLowRateGroupId;

    uint256[] memory borrowAmounts1 = new uint256[](1);
    borrowAmounts1[0] =
      (accountDataBeforeBorrow.availableBorrowInBase * (10 ** tsWETH.decimals())) /
      tsPriceOracle.getAssetPrice(address(tsWETH));

    // not approved
    tsHEVM.expectRevert(bytes(Errors.SENDER_NOT_APPROVED));
    tsBorrower1.crossBorrowERC20(
      tsCommonPoolId,
      address(tsWETH),
      borrowGroups1,
      borrowAmounts1,
      address(tsBorrower2),
      address(tsBorrower3)
    );

    // invalid receiver
    tsBorrower2.setApprovalForAll(tsCommonPoolId, address(tsWETH), address(tsBorrower1), true);

    tsHEVM.expectRevert(bytes(Errors.INVALID_TO_ADDRESS));
    tsBorrower1.crossBorrowERC20(
      tsCommonPoolId,
      address(tsWETH),
      borrowGroups1,
      borrowAmounts1,
      address(tsBorrower2),
      address(0)
    );
  }

  function test_Should_Borrow_OnBehalf() public {
    // prepare
    prepareWETH(tsDepositor1);

    prepareCrossBAYC(tsBorrower2);

    // borrow
    TestCaseLocalVars memory testVars;

    testVars.senderAssetDataBefore = getUserAssetData(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.onBehalfAssetDataBefore = getUserAssetData(
      address(tsBorrower2),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.receiverAssetDataBefore = getUserAssetData(
      address(tsBorrower3),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );

    // calculate borrow amount
    TestUserAccountData memory accountDataBeforeBorrow = getUserAccountData(address(tsBorrower2), tsCommonPoolId);

    uint8[] memory borrowGroups1 = new uint8[](1);
    borrowGroups1[0] = tsLowRateGroupId;

    uint256[] memory borrowAmounts1 = new uint256[](1);
    borrowAmounts1[0] =
      (accountDataBeforeBorrow.availableBorrowInBase * (10 ** tsWETH.decimals())) /
      tsPriceOracle.getAssetPrice(address(tsWETH));

    // approve
    tsBorrower2.setApprovalForAll(tsCommonPoolId, address(tsWETH), address(tsBorrower1), true);

    tsBorrower1.crossBorrowERC20(
      tsCommonPoolId,
      address(tsWETH),
      borrowGroups1,
      borrowAmounts1,
      address(tsBorrower2),
      address(tsBorrower3)
    );

    testVars.senderAssetDataAfter = getUserAssetData(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.onBehalfAssetDataAfter = getUserAssetData(
      address(tsBorrower2),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.receiverAssetDataAfter = getUserAssetData(
      address(tsBorrower3),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );

    assertEq(
      testVars.senderAssetDataAfter.walletBalance,
      (testVars.senderAssetDataBefore.walletBalance),
      'sender.walletBalance not eq'
    );
    assertEq(
      testVars.onBehalfAssetDataAfter.walletBalance,
      (testVars.onBehalfAssetDataBefore.walletBalance),
      'onBehalf.walletBalance not eq'
    );
    assertEq(
      testVars.receiverAssetDataAfter.walletBalance,
      (testVars.receiverAssetDataBefore.walletBalance + borrowAmounts1[0]),
      'receiver.walletBalance not eq'
    );

    assertEq(
      testVars.senderAssetDataAfter.totalCrossBorrow,
      testVars.senderAssetDataBefore.totalCrossBorrow,
      'sender.totalCrossBorrow not eq'
    );
    assertEq(
      testVars.onBehalfAssetDataAfter.totalCrossBorrow,
      (testVars.onBehalfAssetDataBefore.totalCrossBorrow + borrowAmounts1[0]),
      'onBehalf.totalCrossBorrow not eq'
    );
    assertEq(
      testVars.receiverAssetDataAfter.totalCrossBorrow,
      (testVars.receiverAssetDataBefore.totalCrossBorrow),
      'receiver.totalCrossBorrow not eq'
    );
  }

  function test_Should_Repay_OnBehalf() public {
    // prepare
    prepareWETH(tsDepositor1);

    prepareCrossBAYC(tsBorrower2);

    // borrow

    // calculate borrow amount
    TestUserAccountData memory accountDataBeforeBorrow = getUserAccountData(address(tsBorrower2), tsCommonPoolId);

    uint8[] memory borrowGroups1 = new uint8[](1);
    borrowGroups1[0] = tsLowRateGroupId;

    uint256[] memory borrowAmounts1 = new uint256[](1);
    borrowAmounts1[0] =
      (accountDataBeforeBorrow.availableBorrowInBase * (10 ** tsWETH.decimals())) /
      tsPriceOracle.getAssetPrice(address(tsWETH));

    tsBorrower2.crossBorrowERC20(
      tsCommonPoolId,
      address(tsWETH),
      borrowGroups1,
      borrowAmounts1,
      address(tsBorrower2),
      address(tsBorrower2)
    );

    // repay

    TestCaseLocalVars memory testVars;

    testVars.senderAssetDataBefore = getUserAssetData(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.onBehalfAssetDataBefore = getUserAssetData(
      address(tsBorrower2),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );

    uint8[] memory repayGroups = new uint8[](1);
    repayGroups[0] = tsLowRateGroupId;

    uint256[] memory repayAmounts = new uint256[](1);
    (, repayAmounts[0], , ) = tsPoolLens.getUserAssetGroupData(
      address(tsBorrower2),
      tsCommonPoolId,
      address(tsWETH),
      uint8(tsLowRateGroupId)
    );

    tsBorrower1.approveERC20(address(tsWETH), type(uint256).max);

    tsBorrower1.crossRepayERC20(tsCommonPoolId, address(tsWETH), repayGroups, repayAmounts, address(tsBorrower2));

    testVars.senderAssetDataAfter = getUserAssetData(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    testVars.onBehalfAssetDataAfter = getUserAssetData(
      address(tsBorrower2),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );

    assertEq(
      testVars.senderAssetDataAfter.walletBalance,
      (testVars.senderAssetDataBefore.walletBalance - repayAmounts[0]),
      'sender.walletBalance not eq'
    );
    assertEq(
      testVars.onBehalfAssetDataAfter.walletBalance,
      (testVars.onBehalfAssetDataBefore.walletBalance),
      'onBehalf.walletBalance not eq'
    );

    assertEq(
      testVars.senderAssetDataAfter.totalCrossBorrow,
      testVars.senderAssetDataBefore.totalCrossBorrow,
      'sender.totalCrossBorrow not eq'
    );
    assertEq(
      testVars.onBehalfAssetDataAfter.totalCrossBorrow,
      (testVars.onBehalfAssetDataBefore.totalCrossBorrow - repayAmounts[0]),
      'onBehalf.totalCrossBorrow not eq'
    );
  }
}
