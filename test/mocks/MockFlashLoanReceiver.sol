// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {ERC721Holder} from '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';

contract MockFlashLoanReceiver is ERC721Holder {
  address[] public savedAssets;
  uint256[] public savedAmounts;
  address[] public savedNftAssets;
  uint256[] public savedTokenIds;
  address public savedInitiator;
  address public savedOperator;
  bytes public savedParams;

  function executeOperationERC20(
    address[] calldata assets,
    uint256[] calldata amounts,
    address initiator,
    address operator,
    bytes calldata params
  ) public returns (bool) {
    savedAssets = assets;
    savedAmounts = amounts;
    savedInitiator = initiator;
    savedOperator = operator;
    savedParams = params;

    for (uint i = 0; i < assets.length; i++) {
      IERC20(assets[i]).approve(operator, amounts[i]);
    }

    return true;
  }

  function executeOperationERC721(
    address[] calldata nftAssets,
    uint256[] calldata tokenIds,
    address initiator,
    address operator,
    bytes calldata params
  ) public returns (bool) {
    savedNftAssets = nftAssets;
    savedTokenIds = tokenIds;
    savedInitiator = initiator;
    savedOperator = operator;
    savedParams = params;

    for (uint i = 0; i < nftAssets.length; i++) {
      IERC721(nftAssets[i]).approve(operator, tokenIds[i]);
    }

    return true;
  }
}
