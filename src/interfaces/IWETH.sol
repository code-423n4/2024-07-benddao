// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IWETH {
  function decimals() external view returns (uint8);

  function balanceOf(address account) external view returns (uint256);

  function deposit() external payable;

  function withdraw(uint256) external;

  function totalSupply() external view returns (uint);

  function approve(address guy, uint256 wad) external returns (bool);

  function transfer(address dst, uint wad) external returns (bool);

  function transferFrom(address src, address dst, uint256 wad) external returns (bool);
}
