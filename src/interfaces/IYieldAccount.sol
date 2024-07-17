// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IYieldAccount {
  function safeApprove(address token, address spender, uint256 amount) external;

  function safeTransferNativeToken(address to, uint256 amount) external;

  function safeTransfer(address token, address to, uint256 amount) external;

  function execute(address target, bytes calldata data) external returns (bytes memory result);

  function executeWithValue(
    address target,
    bytes calldata data,
    uint256 value
  ) external payable returns (bytes memory result);

  function rescue(address target, bytes calldata data) external;
}
