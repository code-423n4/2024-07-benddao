// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IYield {
  function yieldBorrowERC20(uint32 poolId, address asset, uint256 amount) external;

  function yieldRepayERC20(uint32 poolId, address asset, uint256 amount) external;

  function yieldSetERC721TokenData(
    uint32 poolId,
    address nftAsset,
    uint256 tokenId,
    bool isLock,
    address debtAsset
  ) external;

  function getYieldERC20BorrowBalance(uint32 poolId, address asset, address staker) external view returns (uint256);

  function getERC721TokenData(
    uint32 poolId,
    address asset,
    uint256 tokenId
  ) external view returns (address, uint8, address);
}
