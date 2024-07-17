// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IWithdrawRequestNFT {
  struct WithdrawRequest {
    uint96 amountOfEEth;
    uint96 shareOfEEth;
    bool isValid;
    uint32 feeGwei;
  }

  function requestWithdraw(
    uint96 amountOfEEth,
    uint96 shareOfEEth,
    address requester,
    uint256 fee
  ) external payable returns (uint256);

  function claimWithdraw(uint256 requestId) external;

  function getRequest(uint256 requestId) external view returns (WithdrawRequest memory);

  function isFinalized(uint256 requestId) external view returns (bool);
}
