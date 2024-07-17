// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';

import 'test/helpers/TestUser.sol';
import 'test/setup/TestWithCrossAction.sol';

contract TestIntCrossBorrowERC20 is TestWithCrossAction {
  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_RevertIf_BorrowUSDT_InvalidParams() public {
    uint8[] memory borrowGroups1;
    uint256[] memory borrowAmounts1;

    // empty id list
    tsHEVM.expectRevert(bytes(Errors.GROUP_LIST_IS_EMPTY));
    tsBorrower1.crossBorrowERC20(
      tsCommonPoolId,
      Constants.NATIVE_TOKEN_ADDRESS,
      borrowGroups1,
      borrowAmounts1,
      address(tsBorrower1),
      address(tsBorrower1)
    );

    // inconsistent length
    borrowGroups1 = new uint8[](2);
    borrowAmounts1 = new uint256[](3);
    tsHEVM.expectRevert(bytes(Errors.INCONSISTENT_PARAMS_LENGTH));
    tsBorrower1.crossBorrowERC20(
      tsCommonPoolId,
      Constants.NATIVE_TOKEN_ADDRESS,
      borrowGroups1,
      borrowAmounts1,
      address(tsBorrower1),
      address(tsBorrower1)
    );

    // dup ids
    borrowGroups1 = new uint8[](3);
    borrowGroups1[0] = tsLowRateGroupId;
    borrowGroups1[1] = tsMiddleRateGroupId;
    borrowGroups1[2] = tsLowRateGroupId;
    borrowAmounts1 = new uint256[](3);

    tsHEVM.expectRevert(bytes(Errors.ARRAY_HAS_DUP_ELEMENT));
    tsBorrower1.crossBorrowERC20(
      tsCommonPoolId,
      Constants.NATIVE_TOKEN_ADDRESS,
      borrowGroups1,
      borrowAmounts1,
      address(tsBorrower1),
      address(tsBorrower1)
    );

    // invalid amount
    borrowGroups1 = new uint8[](1);
    borrowGroups1[0] = tsLowRateGroupId;
    borrowAmounts1 = new uint256[](1);
    borrowAmounts1[0] = 0;
    tsHEVM.expectRevert(bytes(Errors.INVALID_AMOUNT));
    tsBorrower1.crossBorrowERC20(
      tsCommonPoolId,
      Constants.NATIVE_TOKEN_ADDRESS,
      borrowGroups1,
      borrowAmounts1,
      address(tsBorrower1),
      address(tsBorrower1)
    );
  }

  function test_Should_BorrowUSDT_HasWETH() public {
    prepareUSDT(tsDepositor1);

    prepareWETH(tsBorrower1);

    uint8[] memory borrowGroups = new uint8[](1);
    borrowGroups[0] = tsLowRateGroupId;

    uint256[] memory borrowAmounts = new uint256[](1);
    borrowAmounts[0] = 1000 * (10 ** tsUSDT.decimals());

    actionCrossBorrowERC20(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsUSDT),
      borrowGroups,
      borrowAmounts,
      new bytes(0)
    );
  }

  function test_Should_BorrowUSDT_HasBAYC() public {
    prepareUSDT(tsDepositor1);

    prepareCrossBAYC(tsBorrower1);

    uint8[] memory borrowGroups = new uint8[](1);
    borrowGroups[0] = tsLowRateGroupId;

    uint256[] memory borrowAmounts = new uint256[](1);
    borrowAmounts[0] = 1000 * (10 ** tsUSDT.decimals());

    actionCrossBorrowERC20(
      address(tsBorrower1),
      tsCommonPoolId,
      address(tsUSDT),
      borrowGroups,
      borrowAmounts,
      new bytes(0)
    );
  }

  function test_Should_BorrowUSDT_HasWETH_BAYC() public {
    prepareUSDT(tsDepositor1);
    prepareUSDT(tsDepositor2);

    prepareWETH(tsBorrower1);
    prepareCrossBAYC(tsBorrower1);

    (uint256[] memory groupsIds, , , uint256[] memory groupsAvailableBorrowInBase) = tsPoolLens.getUserAccountGroupData(
      address(tsBorrower1),
      tsCommonPoolId
    );

    uint256 groupNum = 0;
    for (uint256 i = 0; i < groupsAvailableBorrowInBase.length; i++) {
      if (groupsAvailableBorrowInBase[i] > 0) {
        groupNum++;
      }
    }

    uint256 usdtPrice = tsPriceOracle.getAssetPrice(address(tsUSDT));

    uint8[] memory borrowGroups = new uint8[](groupNum);
    uint256[] memory borrowAmounts = new uint256[](1);

    uint256 grpIdx = 0;
    for (uint256 i = 0; i < groupsAvailableBorrowInBase.length; i++) {
      uint256 groupId = groupsIds[i];
      if (groupsAvailableBorrowInBase[i] > 0) {
        borrowGroups[grpIdx] = uint8(groupId);
        borrowAmounts[grpIdx] = (groupsAvailableBorrowInBase[i] * (10 ** tsUSDT.decimals())) / usdtPrice;
        grpIdx++;
      }
    }

    tsBorrower1.crossBorrowERC20(
      tsCommonPoolId,
      address(tsUSDT),
      borrowGroups,
      borrowAmounts,
      address(tsBorrower1),
      address(tsBorrower1)
    );
  }
}
