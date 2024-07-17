// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';

interface IUnstETH is IERC721 {
  struct WithdrawalRequestStatus {
    /// @notice stETH token amount that was locked on withdrawal queue for this request
    uint256 amountOfStETH;
    /// @notice amount of stETH shares locked on withdrawal queue for this request
    uint256 amountOfShares;
    /// @notice address that can claim or transfer this request
    address owner;
    /// @notice timestamp of when the request was created, in seconds
    uint256 timestamp;
    /// @notice true, if request is finalized
    bool isFinalized;
    /// @notice true, if request is claimed. Request is claimable if (isFinalized && !isClaimed)
    bool isClaimed;
  }

  function requestWithdrawals(
    uint256[] calldata _amounts,
    address _owner
  ) external returns (uint256[] memory requestIds);

  function getWithdrawalStatus(
    uint256[] calldata _requestIds
  ) external view returns (WithdrawalRequestStatus[] memory statuses);

  function claimWithdrawal(uint256 _requestId) external;
}
