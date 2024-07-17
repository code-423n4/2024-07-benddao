// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IERC20Metadata} from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';

interface ISavingsDai is IERC20Metadata {
  function dai() external view returns (address);

  function deposit(uint256 assets, address receiver) external returns (uint256 shares);

  function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

  function convertToShares(uint256 assets) external view returns (uint256);

  function convertToAssets(uint256 shares) external view returns (uint256);
}
