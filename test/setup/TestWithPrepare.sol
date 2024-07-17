// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IERC20Metadata} from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';

import {Constants} from 'src/libraries/helpers/Constants.sol';

import {TestUser} from '../helpers/TestUser.sol';
import {TestWithData} from './TestWithData.sol';

import '@forge-std/Test.sol';

abstract contract TestWithPrepare is TestWithData {
  function onSetUp() public virtual override {
    super.onSetUp();
  }

  function prepareERC20(TestUser user, address asset, uint256 depositAmount) internal virtual {
    user.approveERC20(asset, type(uint256).max);
    user.depositERC20(tsCommonPoolId, asset, depositAmount, address(user));
  }

  function prepareWETH(TestUser user) internal virtual {
    uint256 depositAmount = 500 * (10 ** IERC20Metadata(tsWETH).decimals());
    prepareERC20(user, address(tsWETH), depositAmount);
  }

  function prepareUSDT(TestUser user) internal virtual {
    uint256 depositAmount = 500_000 * (10 ** IERC20Metadata(tsUSDT).decimals());
    prepareERC20(user, address(tsUSDT), depositAmount);
  }

  function prepareDAI(TestUser user) internal virtual {
    uint256 depositAmount = 500_000 * (10 ** IERC20Metadata(tsDAI).decimals());
    prepareERC20(user, address(tsDAI), depositAmount);
  }

  function prepareIsolateERC721(TestUser user, address asset, uint256[] memory tokenIds) internal virtual {
    user.setApprovalForAllERC721(asset, true);
    user.depositERC721(tsCommonPoolId, asset, tokenIds, Constants.SUPPLY_MODE_ISOLATE, address(user));
  }

  function prepareCrossERC721(TestUser user, address asset, uint256[] memory tokenIds) internal virtual {
    user.setApprovalForAllERC721(asset, true);
    user.depositERC721(tsCommonPoolId, asset, tokenIds, Constants.SUPPLY_MODE_CROSS, address(user));
  }

  function prepareIsolateBAYC(TestUser user) internal virtual returns (uint256[] memory tokenIds) {
    tokenIds = user.getTokenIds();
    prepareIsolateERC721(user, address(tsBAYC), tokenIds);
  }

  function prepareIsolateMAYC(TestUser user) internal virtual returns (uint256[] memory tokenIds) {
    tokenIds = user.getTokenIds();
    prepareIsolateERC721(user, address(tsMAYC), tokenIds);
  }

  function prepareCrossBAYC(TestUser user) internal virtual returns (uint256[] memory tokenIds) {
    tokenIds = user.getTokenIds();
    prepareCrossERC721(user, address(tsBAYC), tokenIds);
  }

  function prepareCrossMAYC(TestUser user) internal virtual returns (uint256[] memory tokenIds) {
    tokenIds = user.getTokenIds();
    prepareCrossERC721(user, address(tsMAYC), tokenIds);
  }
}
