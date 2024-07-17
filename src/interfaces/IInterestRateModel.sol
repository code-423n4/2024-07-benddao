// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {InputTypes} from '../libraries/types/InputTypes.sol';

/**
 * @title IInterestRateModel
 * @notice Defines the basic interface for the Interest Rate Model
 */
interface IInterestRateModel {
  /**
   * @notice Calculates the interest rate depending on the group's state and configurations
   * @param utilizationRate The asset liquidity utilization rate
   * @return borrowRate The group borrow rate expressed in rays
   */
  function calculateGroupBorrowRate(uint256 groupId, uint256 utilizationRate) external view returns (uint256);
}
