// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';

import 'test/setup/TestWithBaseAction.sol';

contract TestIntDepositERC20 is TestWithBaseAction {
  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_RevertIf_AmountZero() public {
    uint256 amount = 0 ether;

    tsDepositor1.approveERC20(address(tsWETH), 1);
    actionDepositERC20(address(tsDepositor1), tsCommonPoolId, address(tsWETH), amount, bytes(Errors.INVALID_AMOUNT));
  }

  function test_RevertIf_InsufficientAllowance() public {
    uint256 amount = 100 ether;

    tsDepositor1.approveERC20(address(tsWETH), 1);
    actionDepositERC20(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsWETH),
      amount,
      bytes('ERC20: insufficient allowance')
    );
  }

  function test_RevertIf_ExceedBalance() public {
    uint256 amount = tsWETH.balanceOf(address(tsDepositor1)) + 100;

    tsDepositor1.approveERC20(address(tsWETH), amount);
    actionDepositERC20(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsWETH),
      amount,
      bytes('ERC20: transfer amount exceeds balance')
    );
  }

  function test_Should_Deposit_WETH() public {
    tsDepositor1.approveERC20(address(tsWETH), type(uint256).max);

    uint256 amount1 = 123 ether;
    actionDepositERC20(address(tsDepositor1), tsCommonPoolId, address(tsWETH), amount1, new bytes(0));

    advanceTimes(30 days);

    TestUserAssetData memory userAssetData1 = getUserAssetData(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    assertEq(userAssetData1.totalCrossSupply, amount1, 'TC:UAD:totalCrossSupply == amount1');

    uint256 amount2 = 45 ether;
    actionDepositERC20(address(tsDepositor1), tsCommonPoolId, address(tsWETH), amount2, new bytes(0));

    advanceTimes(30 days);

    TestUserAssetData memory userAssetData2 = getUserAssetData(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsWETH),
      Constants.ASSET_TYPE_ERC20
    );
    assertEq(userAssetData2.totalCrossSupply, amount1 + amount2, 'TC:UAD:totalCrossSupply == amount1+amount2');
  }

  function test_Should_Deposit_USDT() public {
    tsDepositor1.approveERC20(address(tsUSDT), type(uint256).max);

    uint256 amount1 = 543 * (10 ** tsUSDT.decimals());
    actionDepositERC20(address(tsDepositor1), tsCommonPoolId, address(tsUSDT), amount1, new bytes(0));

    advanceTimes(30 days);

    TestUserAssetData memory userAssetData1 = getUserAssetData(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsUSDT),
      Constants.ASSET_TYPE_ERC20
    );
    assertEq(userAssetData1.totalCrossSupply, amount1, 'TC:UAD:totalCrossSupply == amount1');

    uint256 amount2 = 21 * (10 ** tsUSDT.decimals());
    actionDepositERC20(address(tsDepositor1), tsCommonPoolId, address(tsUSDT), amount2, new bytes(0));

    advanceTimes(30 days);

    TestUserAssetData memory userAssetData2 = getUserAssetData(
      address(tsDepositor1),
      tsCommonPoolId,
      address(tsUSDT),
      Constants.ASSET_TYPE_ERC20
    );
    assertEq(userAssetData2.totalCrossSupply, amount1 + amount2, 'TC:UAD:totalCrossSupply == amount1+amount2');
  }
}
