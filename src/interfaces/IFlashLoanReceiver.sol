// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @title IFlashLoanReceiver interface
 * @notice Interface for the IFlashLoanReceiver.
 * @dev implement this interface to develop a flashloan-compatible flashLoanReceiver contract
 **/
interface IFlashLoanReceiver {
  function executeOperationERC20(
    address[] calldata assets,
    uint256[] calldata amounts,
    address initiator,
    address operator,
    bytes calldata params
  ) external returns (bool);

  function executeOperationERC721(
    address[] calldata nftAssets,
    uint256[] calldata tokenIds,
    address initiator,
    address operator,
    bytes calldata params
  ) external returns (bool);
}
