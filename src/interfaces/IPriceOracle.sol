// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IPriceOracleGetter} from './IPriceOracleGetter.sol';

/**
 * @title IPriceOracle
 * @notice Defines the basic interface for a Price oracle.
 */
interface IPriceOracle is IPriceOracleGetter {
  function setAssetChainlinkAggregators(address[] calldata assets, address[] calldata aggregators) external;

  function getAssetChainlinkAggregators(address[] calldata assets) external view returns (address[] memory aggregators);

  function setBendNFTOracle(address bendNFTOracle_) external;

  function getBendNFTOracle() external view returns (address);
}
