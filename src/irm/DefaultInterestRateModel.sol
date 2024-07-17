// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {WadRayMath} from '../libraries/math/WadRayMath.sol';
import {PercentageMath} from '../libraries/math/PercentageMath.sol';
import {InputTypes} from '../libraries/types/InputTypes.sol';
import {Errors} from '../libraries/helpers/Errors.sol';

import {IInterestRateModel} from '../interfaces/IInterestRateModel.sol';
import {IDefaultInterestRateModel} from '../interfaces/IDefaultInterestRateModel.sol';

/**
 * @title DefaultInterestRateModel contract
 * @notice Implements the calculation of the interest rates depending on the reserve state
 * @dev The model of interest rate is based on 2 slopes, one before the `OPTIMAL_USAGE_RATIO`
 * point of usage and another from that one to 100%.
 */
contract DefaultInterestRateModel is IDefaultInterestRateModel {
  using WadRayMath for uint256;
  using PercentageMath for uint256;

  /// @inheritdoc IDefaultInterestRateModel
  uint256 public immutable OPTIMAL_USAGE_RATIO;

  /// @inheritdoc IDefaultInterestRateModel
  uint256 public immutable MAX_EXCESS_USAGE_RATIO;

  // Base variable borrow rate when usage rate = 0. Expressed in ray
  uint256 internal immutable _baseVariableBorrowRate;

  // Slope of the variable interest curve when usage ratio > 0 and <= OPTIMAL_USAGE_RATIO. Expressed in ray
  uint256 internal immutable _variableRateSlope1;

  // Slope of the variable interest curve when usage ratio > OPTIMAL_USAGE_RATIO. Expressed in ray
  uint256 internal immutable _variableRateSlope2;

  /**
   * @dev Constructor.
   * @param optimalUsageRatio The optimal usage ratio
   * @param baseVariableBorrowRate The variable base borrow rate
   * @param variableRateSlope1 The variable rate slope below optimal usage ratio
   * @param variableRateSlope2 The variable rate slope above optimal usage ratio
   */
  constructor(
    uint256 optimalUsageRatio,
    uint256 baseVariableBorrowRate,
    uint256 variableRateSlope1,
    uint256 variableRateSlope2
  ) {
    OPTIMAL_USAGE_RATIO = optimalUsageRatio;
    MAX_EXCESS_USAGE_RATIO = WadRayMath.RAY - optimalUsageRatio;
    _baseVariableBorrowRate = baseVariableBorrowRate;
    _variableRateSlope1 = variableRateSlope1;
    _variableRateSlope2 = variableRateSlope2;
  }

  /// @inheritdoc IDefaultInterestRateModel
  function getVariableRateSlope1() external view returns (uint256) {
    return _variableRateSlope1;
  }

  /// @inheritdoc IDefaultInterestRateModel
  function getVariableRateSlope2() external view returns (uint256) {
    return _variableRateSlope2;
  }

  /// @inheritdoc IDefaultInterestRateModel
  function getBaseVariableBorrowRate() external view override returns (uint256) {
    return _baseVariableBorrowRate;
  }

  /// @inheritdoc IDefaultInterestRateModel
  function getMaxVariableBorrowRate() external view override returns (uint256) {
    return _baseVariableBorrowRate + _variableRateSlope1 + _variableRateSlope2;
  }

  struct CalcInterestRatesLocalVars {
    uint256 currentBorrowRate;
  }

  /// @inheritdoc IInterestRateModel
  function calculateGroupBorrowRate(
    uint256 /*groupId*/,
    uint256 utilizationRate
  ) public view override returns (uint256) {
    CalcInterestRatesLocalVars memory vars;

    vars.currentBorrowRate = _baseVariableBorrowRate;

    if (utilizationRate > OPTIMAL_USAGE_RATIO) {
      uint256 excessRate = (utilizationRate - OPTIMAL_USAGE_RATIO).rayDiv(MAX_EXCESS_USAGE_RATIO);

      vars.currentBorrowRate += _variableRateSlope1 + _variableRateSlope2.rayMul(excessRate);
    } else {
      vars.currentBorrowRate += _variableRateSlope1.rayMul(utilizationRate).rayDiv(OPTIMAL_USAGE_RATIO);
    }

    return (vars.currentBorrowRate);
  }
}
