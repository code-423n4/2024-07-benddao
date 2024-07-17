// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/libraries/helpers/Constants.sol';
import 'src/libraries/helpers/Errors.sol';

import 'test/setup/TestWithPrepare.sol';
import '@forge-std/Test.sol';

contract TestDelegateERC721 is TestWithPrepare {
  function onSetUp() public virtual override {
    super.onSetUp();

    initCommonPools();
  }

  function test_RevertIf_InvalidTokenOwner() public {
    address nftAsset = address(tsBAYC);
    uint256[] memory tokenIds = prepareCrossBAYC(tsDepositor1);

    tsHEVM.expectRevert(bytes(Errors.INVALID_TOKEN_OWNER));
    tsDepositor2.delegateERC721(tsCommonPoolId, nftAsset, tokenIds, address(tsDepositor2), true);
  }

  function test_Should_Cross_Self() public {
    address nftAsset = address(tsBAYC);
    uint256[] memory tokenIds = prepareCrossBAYC(tsDepositor1);

    tsDepositor1.delegateERC721(tsCommonPoolId, nftAsset, tokenIds, address(tsDepositor1), true);

    address[][] memory delegations = tsPoolLens.getERC721Delegations(tsCommonPoolId, nftAsset, tokenIds);
    assertEq(delegations.length, tokenIds.length, 'delegations.length not eq');
    for (uint i = 0; i < tokenIds.length; i++) {
      assertEq(delegations[i].length, 1, 'delegations[i].length not eq');
      assertEq(delegations[i][0], address(tsDepositor1), 'delegations[i][0] not eq');
    }

    tsDepositor1.delegateERC721(tsCommonPoolId, nftAsset, tokenIds, address(tsDepositor1), false);

    address[][] memory delegations2 = tsPoolLens.getERC721Delegations(tsCommonPoolId, nftAsset, tokenIds);
    assertEq(delegations2.length, tokenIds.length, 'delegations2.length not eq');
    for (uint i = 0; i < tokenIds.length; i++) {
      assertEq(delegations2[i].length, 0, 'delegations2[i].length not eq');
    }
  }

  function test_Should_Cross_NotSelf() public {
    address nftAsset = address(tsBAYC);
    uint256[] memory tokenIds = prepareCrossBAYC(tsDepositor1);

    tsDepositor1.delegateERC721(tsCommonPoolId, nftAsset, tokenIds, address(tsDepositor2), true);

    address[][] memory delegations = tsPoolLens.getERC721Delegations(tsCommonPoolId, nftAsset, tokenIds);
    assertEq(delegations.length, tokenIds.length, 'delegations.length not eq');
    for (uint i = 0; i < tokenIds.length; i++) {
      assertEq(delegations[i].length, 1, 'delegations[i].length not eq');
      assertEq(delegations[i][0], address(tsDepositor2), 'delegations[i][0] not eq');
    }

    tsDepositor1.delegateERC721(tsCommonPoolId, nftAsset, tokenIds, address(tsDepositor2), false);

    address[][] memory delegations2 = tsPoolLens.getERC721Delegations(tsCommonPoolId, nftAsset, tokenIds);
    assertEq(delegations2.length, tokenIds.length, 'delegations2.length not eq');
    for (uint i = 0; i < tokenIds.length; i++) {
      assertEq(delegations2[i].length, 0, 'delegations2[i].length not eq');
    }
  }

  function test_Should_Isolate_NotSelf() public {
    address nftAsset = address(tsBAYC);
    uint256[] memory tokenIds = prepareIsolateBAYC(tsDepositor1);

    tsDepositor1.delegateERC721(tsCommonPoolId, nftAsset, tokenIds, address(tsDepositor2), true);

    address[][] memory delegations = tsPoolLens.getERC721Delegations(tsCommonPoolId, nftAsset, tokenIds);
    assertEq(delegations.length, tokenIds.length, 'delegations.length not eq');
    for (uint i = 0; i < tokenIds.length; i++) {
      assertEq(delegations[i].length, 1, 'delegations[i].length not eq');
      assertEq(delegations[i][0], address(tsDepositor2), 'delegations[i][0] not eq');
    }

    tsDepositor1.delegateERC721(tsCommonPoolId, nftAsset, tokenIds, address(tsDepositor2), false);

    address[][] memory delegations2 = tsPoolLens.getERC721Delegations(tsCommonPoolId, nftAsset, tokenIds);
    assertEq(delegations2.length, tokenIds.length, 'delegations2.length not eq');
    for (uint i = 0; i < tokenIds.length; i++) {
      assertEq(delegations2[i].length, 0, 'delegations2[i].length not eq');
    }
  }
}
