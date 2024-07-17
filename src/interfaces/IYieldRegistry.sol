// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IYieldRegistry {
  function createYieldAccount(address _manager) external returns (address);

  function existYieldManager(address _manager) external returns (bool);
}
