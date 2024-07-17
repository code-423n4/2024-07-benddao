// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Ownable2StepUpgradeable} from '@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol';

import {IACLManager} from 'src/interfaces/IACLManager.sol';
import {IAddressProvider} from 'src/interfaces/IAddressProvider.sol';
import {IPoolManager} from 'src/interfaces/IPoolManager.sol';

/**
 * @title AddressProvider
 * @notice Main registry of addresses part of or connected to the protocol, including permissioned roles
 */
contract AddressProvider is Ownable2StepUpgradeable, IAddressProvider {
  // Main identifiers
  bytes32 public constant WRAPPED_NATIVE_TOKEN = 'WRAPPED_NATIVE_TOKEN';
  bytes32 public constant TREASURY = 'TREASURY';
  bytes32 public constant ACL_ADMIN = 'ACL_ADMIN';
  bytes32 public constant ACL_MANAGER = 'ACL_MANAGER';
  bytes32 public constant PRICE_ORACLE = 'PRICE_ORACLE';
  bytes32 public constant POOL_MANAGER = 'POOL_MANAGER';
  bytes32 public constant YIELD_REGISTRY = 'YIELD_REGISTRY';
  bytes32 public constant DELEGATE_REGISTRY_V2 = 'DELEGATE_REGISTRY_V2';

  // Map of registered addresses (identifier => registeredAddress)
  mapping(bytes32 => address) private _addresses;

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[49] private __gap;

  constructor() {
    _disableInitializers();
  }

  function initialize() public initializer {
    __Ownable2Step_init();
  }

  function getAddress(bytes32 id) public view override returns (address) {
    return _addresses[id];
  }

  function setAddress(bytes32 id, address newAddress) public override onlyOwner {
    address oldAddress = _setAddress(id, newAddress);
    emit AddressSet(id, oldAddress, newAddress);
  }

  function getWrappedNativeToken() public view override returns (address) {
    return getAddress(WRAPPED_NATIVE_TOKEN);
  }

  function setWrappedNativeToken(address newAddress) public override onlyOwner {
    address oldAddress = _setAddress(WRAPPED_NATIVE_TOKEN, newAddress);
    emit WrappedNativeTokenUpdated(oldAddress, newAddress);
  }

  function getTreasury() public view override returns (address) {
    return getAddress(TREASURY);
  }

  function setTreasury(address newAddress) public override onlyOwner {
    address oldAddress = _setAddress(TREASURY, newAddress);
    emit TreasuryUpdated(oldAddress, newAddress);
  }

  function getACLAdmin() public view override returns (address) {
    return getAddress(ACL_ADMIN);
  }

  function setACLAdmin(address newAddress) public override onlyOwner {
    address oldAddress = _setAddress(ACL_ADMIN, newAddress);
    emit ACLAdminUpdated(oldAddress, newAddress);
  }

  function getACLManager() public view override returns (address) {
    return getAddress(ACL_MANAGER);
  }

  function setACLManager(address newAddress) public override onlyOwner {
    address oldAddress = _setAddress(ACL_MANAGER, newAddress);
    emit ACLManagerUpdated(oldAddress, newAddress);
  }

  function getPriceOracle() public view override returns (address) {
    return getAddress(PRICE_ORACLE);
  }

  function setPriceOracle(address newAddress) public override onlyOwner {
    address oldAddress = _setAddress(PRICE_ORACLE, newAddress);
    emit PriceOracleUpdated(oldAddress, newAddress);
  }

  function getPoolManager() public view override returns (address) {
    return getAddress(POOL_MANAGER);
  }

  function setPoolManager(address newAddress) public override onlyOwner {
    address oldAddress = _setAddress(POOL_MANAGER, newAddress);
    emit PoolManagerUpdated(oldAddress, newAddress);
  }

  function getPoolModuleImplementation(uint moduleId) public view override returns (address) {
    return IPoolManager(getPoolManager()).moduleIdToImplementation(moduleId);
  }

  function getPoolModuleProxy(uint moduleId) public view override returns (address) {
    return IPoolManager(getPoolManager()).moduleIdToProxy(moduleId);
  }

  function getPoolModuleProxies(uint[] memory moduleIds) public view override returns (address[] memory) {
    IPoolManager poolManager = IPoolManager(getPoolManager());
    address[] memory proxies = new address[](moduleIds.length);
    for (uint i = 0; i < moduleIds.length; i++) {
      proxies[i] = poolManager.moduleIdToProxy(moduleIds[i]);
    }
    return proxies;
  }

  function getYieldRegistry() public view override returns (address) {
    return getAddress(YIELD_REGISTRY);
  }

  function setYieldRegistry(address newAddress) public override onlyOwner {
    address oldAddress = _setAddress(YIELD_REGISTRY, newAddress);
    emit YieldRegistryUpdated(oldAddress, newAddress);
  }

  function getDelegateRegistryV2() public view override returns (address) {
    return getAddress(DELEGATE_REGISTRY_V2);
  }

  function setDelegateRegistryV2(address newAddress) public override onlyOwner {
    address oldAddress = _setAddress(DELEGATE_REGISTRY_V2, newAddress);
    emit YieldRegistryUpdated(oldAddress, newAddress);
  }

  // internal methods

  function _setAddress(bytes32 id, address newAddress) internal returns (address) {
    address oldAddress = _addresses[id];
    _addresses[id] = newAddress;
    return oldAddress;
  }
}
