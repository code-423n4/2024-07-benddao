// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

library ShareUtils {
  using Math for uint256;

  function convertToShares(
    uint256 assets,
    uint256 totalShares,
    uint256 totalAssets,
    Math.Rounding rounding
  ) internal pure returns (uint256) {
    return assets.mulDiv(totalShares + 1, totalAssets + 1, rounding);
  }

  function convertToAssets(
    uint256 shares,
    uint256 totalShares,
    uint256 totalAssets,
    Math.Rounding rounding
  ) internal pure returns (uint256) {
    return shares.mulDiv(totalAssets + 1, totalShares + 1, rounding);
  }
}
