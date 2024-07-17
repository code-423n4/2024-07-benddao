// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IPoolManager {
  function moduleIdToImplementation(uint moduleId) external view returns (address);

  function moduleIdToProxy(uint moduleId) external view returns (address);

  function dispatch() external;
}
