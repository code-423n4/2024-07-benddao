// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';
import {ClonesUpgradeable} from '@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol';
import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import {PausableUpgradeable} from '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import {ReentrancyGuardUpgradeable} from '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';

import {IAddressProvider} from 'src/interfaces/IAddressProvider.sol';
import {IACLManager} from 'src/interfaces/IACLManager.sol';
import {IYieldRegistry} from 'src/interfaces/IYieldRegistry.sol';

import {Constants} from 'src/libraries/helpers/Constants.sol';
import {Errors} from 'src/libraries/helpers/Errors.sol';

import {YieldAccount} from './YieldAccount.sol';

contract YieldRegistry is IYieldRegistry, PausableUpgradeable, ReentrancyGuardUpgradeable {
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

  event CreateYieldAccount(address indexed account, address indexed manager);
  event SetYieldAccountImplementation(address indexed implementation);
  event AddYieldManager(address indexed manager);
  event RescueYieldAccount(address indexed account, address indexed target, bytes data);

  IAddressProvider public addressProvider;
  address public yieldAccountImplementation;
  EnumerableSetUpgradeable.AddressSet internal yieldManagers;

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[46] private __gap;

  modifier onlyPoolAdmin() {
    __onlyPoolAdmin();
    _;
  }

  function __onlyPoolAdmin() internal view {
    require(IACLManager(addressProvider.getACLManager()).isPoolAdmin(msg.sender), Errors.CALLER_NOT_POOL_ADMIN);
  }

  constructor() {
    _disableInitializers();
  }

  function initialize(address addressProvider_) public initializer {
    require(addressProvider_ != address(0), Errors.ADDR_PROVIDER_CANNOT_BE_ZERO);

    __Pausable_init();
    __ReentrancyGuard_init();

    addressProvider = IAddressProvider(addressProvider_);
  }

  function createYieldAccount(address _manager) public override returns (address) {
    require(existYieldManager(_manager), Errors.YIELD_MANAGER_IS_NOT_AUTH);
    require(yieldAccountImplementation != address(0), Errors.YIELD_ACCOUNT_IMPL_ZERO);

    address yieldAccount = ClonesUpgradeable.clone(yieldAccountImplementation);
    YieldAccount(payable(yieldAccount)).initialize(address(this), _manager);

    emit CreateYieldAccount(yieldAccount, _manager);

    return yieldAccount;
  }

  function setYieldAccountImplementation(address _implementation) public onlyPoolAdmin {
    require(_implementation != address(0), Errors.INVALID_ADDRESS);
    yieldAccountImplementation = _implementation;

    emit SetYieldAccountImplementation(_implementation);
  }

  function addYieldManager(address _manager) public onlyPoolAdmin {
    bool isAddOk = yieldManagers.add(_manager);
    require(isAddOk, Errors.ENUM_SET_ADD_FAILED);

    emit AddYieldManager(_manager);
  }

  function existYieldManager(address _manager) public view override returns (bool) {
    return yieldManagers.contains(_manager);
  }

  function getAllYieldManagers() public view returns (address[] memory) {
    return yieldManagers.values();
  }

  function rescue(address yieldAccount, address target, bytes calldata data) public onlyPoolAdmin {
    YieldAccount(payable(yieldAccount)).rescue(target, data);

    emit RescueYieldAccount(yieldAccount, target, data);
  }
}
