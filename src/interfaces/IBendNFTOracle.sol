// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @title IBendNFTOracle
 * @notice Defines the basic interface for the BendDAO NFT Oracle
 */
interface IBendNFTOracle {
  /* CAUTION: Price uint is ETH based (WEI, 18 decimals) */
  // get asset price
  function getAssetPrice(address _nftContract) external view returns (uint256);
}
