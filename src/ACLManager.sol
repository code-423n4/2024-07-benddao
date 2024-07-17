// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {AccessControlUpgradeable} from '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';
import {IACLManager} from './interfaces/IACLManager.sol';
import {Errors} from './libraries/helpers/Errors.sol';

/**
 * @title ACLManager
 * @notice Access Control List Manager. Main registry of system roles and permissions.
 */
contract ACLManager is AccessControlUpgradeable, IACLManager {
  bytes32 public constant override POOL_ADMIN_ROLE = keccak256('POOL_ADMIN');
  bytes32 public constant override EMERGENCY_ADMIN_ROLE = keccak256('EMERGENCY_ADMIN');
  bytes32 public constant override ORACLE_ADMIN_ROLE = keccak256('ORACLE_ADMIN');

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[50] private __gap;

  constructor() {
    _disableInitializers();
  }

  /**
   * @dev initialize
   * @dev The ACL admin should be initialized at the addressesProvider beforehand
   * @param aclAdmin The address of the ACL admin
   */
  function initialize(address aclAdmin) public initializer {
    require(aclAdmin != address(0), Errors.ACL_ADMIN_CANNOT_BE_ZERO);
    _setupRole(DEFAULT_ADMIN_ROLE, aclAdmin);
  }

  /// @inheritdoc IACLManager
  function addPoolAdmin(address admin) public override {
    grantRole(POOL_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function removePoolAdmin(address admin) public override {
    revokeRole(POOL_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function isPoolAdmin(address admin) public view override returns (bool) {
    return hasRole(POOL_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function addEmergencyAdmin(address admin) public override {
    grantRole(EMERGENCY_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function removeEmergencyAdmin(address admin) public override {
    revokeRole(EMERGENCY_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function isEmergencyAdmin(address admin) public view override returns (bool) {
    return hasRole(EMERGENCY_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function addOracleAdmin(address admin) public override {
    grantRole(ORACLE_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function removeOracleAdmin(address admin) public override {
    revokeRole(ORACLE_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function isOracleAdmin(address admin) public view override returns (bool) {
    return hasRole(ORACLE_ADMIN_ROLE, admin);
  }
}
