// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @title IPriceOracleGetter
 * @notice Interface for the price oracle.
 */
interface IPriceOracleGetter {
  /**
   * @notice Returns the base currency address
   * @dev Address 0x0 is reserved for USD as base currency.
   */
  function BASE_CURRENCY() external view returns (address);

  /**
   * @notice Returns the base currency unit
   * @dev 1e18 for ETH, 1e8 for USD.
   */
  function BASE_CURRENCY_UNIT() external view returns (uint256);

  /**
   * @notice Returns the base currency address of nft
   * @dev Address 0x0 is reserved for USD as base currency.
   */
  function NFT_BASE_CURRENCY() external view returns (address);

  /**
   * @notice Returns the base currency unit of nft
   * @dev 1e18 for ETH, 1e8 for USD.
   */
  function NFT_BASE_CURRENCY_UNIT() external view returns (uint256);

  /**
   * @notice Returns the asset price in the base currency
   */
  function getAssetPrice(address asset) external view returns (uint256);
}
