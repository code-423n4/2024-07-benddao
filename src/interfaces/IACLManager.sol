// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @title IACLManager
 * @notice Defines the basic interface for the ACL Manager
 */
interface IACLManager {
  /**
   * @notice Returns the identifier of the PoolAdmin role
   * @return The id of the PoolAdmin role
   */
  function POOL_ADMIN_ROLE() external view returns (bytes32);

  /**
   * @notice Returns the identifier of the EmergencyAdmin role
   * @return The id of the EmergencyAdmin role
   */
  function EMERGENCY_ADMIN_ROLE() external view returns (bytes32);

  /**
   * @notice Returns the identifier of the OracleAdmin role
   * @return The id of the OracleAdmin role
   */
  function ORACLE_ADMIN_ROLE() external view returns (bytes32);

  /**
   * @notice Adds a new admin as PoolAdmin
   * @param admin The address of the new admin
   */
  function addPoolAdmin(address admin) external;

  /**
   * @notice Removes an admin as PoolAdmin
   * @param admin The address of the admin to remove
   */
  function removePoolAdmin(address admin) external;

  /**
   * @notice Returns true if the address is PoolAdmin, false otherwise
   * @param admin The address to check
   * @return True if the given address is PoolAdmin, false otherwise
   */
  function isPoolAdmin(address admin) external view returns (bool);

  /**
   * @notice Adds a new admin as EmergencyAdmin
   * @param admin The address of the new admin
   */
  function addEmergencyAdmin(address admin) external;

  /**
   * @notice Removes an admin as EmergencyAdmin
   * @param admin The address of the admin to remove
   */
  function removeEmergencyAdmin(address admin) external;

  /**
   * @notice Returns true if the address is EmergencyAdmin, false otherwise
   * @param admin The address to check
   * @return True if the given address is EmergencyAdmin, false otherwise
   */
  function isEmergencyAdmin(address admin) external view returns (bool);

  /**
   * @notice Adds a new admin as OracleAdmin
   * @param admin The address of the new admin
   */
  function addOracleAdmin(address admin) external;

  /**
   * @notice Removes an admin as OracleAdmin
   * @param admin The address of the admin to remove
   */
  function removeOracleAdmin(address admin) external;

  /**
   * @notice Returns true if the address is OracleAdmin, false otherwise
   * @param admin The address to check
   * @return True if the given address is OracleAdmin, false otherwise
   */
  function isOracleAdmin(address admin) external view returns (bool);
}
