// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library Errors {
  string public constant OK = '0';
  string public constant EMPTY_ERROR = '1';
  string public constant ETH_TRANSFER_FAILED = '2';
  string public constant TOKEN_TRANSFER_FAILED = '3';
  string public constant MSG_VALUE_NOT_ZERO = '4';

  string public constant REENTRANCY_ALREADY_LOCKED = '10';

  string public constant PROXY_INVALID_MODULE = '30';
  string public constant PROXY_INTERNAL_MODULE = '31';
  string public constant PROXY_SENDER_NOT_TRUST = '32';
  string public constant PROXY_MSGDATA_TOO_SHORT = '33';

  string public constant INVALID_AMOUNT = '100';
  string public constant INVALID_SCALED_AMOUNT = '101';
  string public constant INVALID_TRANSFER_AMOUNT = '102';
  string public constant INVALID_ADDRESS = '103';
  string public constant INVALID_FROM_ADDRESS = '104';
  string public constant INVALID_TO_ADDRESS = '105';
  string public constant INVALID_SUPPLY_MODE = '106';
  string public constant INVALID_ASSET_TYPE = '107';
  string public constant INVALID_POOL_ID = '108';
  string public constant INVALID_GROUP_ID = '109';
  string public constant INVALID_ASSET_ID = '110';
  string public constant INVALID_ASSET_DECIMALS = '111';
  string public constant INVALID_IRM_ADDRESS = '112';
  string public constant INVALID_CALLER = '113';
  string public constant INVALID_ID_LIST = '114';
  string public constant INVALID_COLLATERAL_AMOUNT = '115';
  string public constant INVALID_BORROW_AMOUNT = '116';
  string public constant INVALID_TOKEN_OWNER = '117';
  string public constant INVALID_YIELD_STAKER = '118';
  string public constant INCONSISTENT_PARAMS_LENGTH = '119';
  string public constant INVALID_LOAN_STATUS = '120';
  string public constant ARRAY_HAS_DUP_ELEMENT = '121';
  string public constant INVALID_ONBEHALF_ADDRESS = '122';
  string public constant SAME_ONBEHALF_ADDRESS = '123';

  string public constant ENUM_SET_ADD_FAILED = '150';
  string public constant ENUM_SET_REMOVE_FAILED = '151';

  string public constant ACL_ADMIN_CANNOT_BE_ZERO = '200';
  string public constant ACL_MANAGER_CANNOT_BE_ZERO = '201';
  string public constant CALLER_NOT_ORACLE_ADMIN = '202';
  string public constant CALLER_NOT_POOL_ADMIN = '203';
  string public constant CALLER_NOT_EMERGENCY_ADMIN = '204';
  string public constant OWNER_CANNOT_BE_ZERO = '205';
  string public constant INVALID_ASSET_PARAMS = '206';
  string public constant FLASH_LOAN_EXEC_FAILED = '207';
  string public constant TREASURY_CANNOT_BE_ZERO = '208';
  string public constant PRICE_ORACLE_CANNOT_BE_ZERO = '209';
  string public constant ADDR_PROVIDER_CANNOT_BE_ZERO = '210';
  string public constant SENDER_NOT_APPROVED = '211';

  string public constant POOL_ALREADY_EXISTS = '300';
  string public constant POOL_NOT_EXISTS = '301';
  string public constant POOL_IS_PAUSED = '302';
  string public constant POOL_YIELD_ALREADY_ENABLE = '303';
  string public constant POOL_YIELD_NOT_ENABLE = '304';
  string public constant POOL_YIELD_IS_PAUSED = '305';

  string public constant GROUP_ALREADY_EXISTS = '320';
  string public constant GROUP_NOT_EXISTS = '321';
  string public constant GROUP_LIST_NOT_EMPTY = '322';
  string public constant GROUP_LIST_IS_EMPTY = '323';
  string public constant GROUP_NUMBER_EXCEED_MAX_LIMIT = '324';
  string public constant GROUP_USED_BY_ASSET = '325';

  string public constant ASSET_ALREADY_EXISTS = '340';
  string public constant ASSET_NOT_EXISTS = '341';
  string public constant ASSET_LIST_NOT_EMPTY = '342';
  string public constant ASSET_NUMBER_EXCEED_MAX_LIMIT = '343';
  string public constant ASSET_AGGREGATOR_NOT_EXIST = '344';
  string public constant ASSET_PRICE_IS_ZERO = '345';
  string public constant ASSET_TYPE_NOT_ERC20 = '346';
  string public constant ASSET_TYPE_NOT_ERC721 = '347';
  string public constant ASSET_NOT_ACTIVE = '348';
  string public constant ASSET_IS_PAUSED = '349';
  string public constant ASSET_IS_FROZEN = '350';
  string public constant ASSET_IS_BORROW_DISABLED = '351';
  string public constant ASSET_NOT_CROSS_MODE = '352';
  string public constant ASSET_NOT_ISOLATE_MODE = '353';
  string public constant ASSET_YIELD_ALREADY_ENABLE = '354';
  string public constant ASSET_YIELD_NOT_ENABLE = '355';
  string public constant ASSET_YIELD_IS_PAUSED = '356';
  string public constant ASSET_INSUFFICIENT_LIQUIDITY = '357';
  string public constant ASSET_INSUFFICIENT_BIDAMOUNT = '358';
  string public constant ASSET_ALREADY_LOCKED_IN_USE = '359';
  string public constant ASSET_SUPPLY_CAP_EXCEEDED = '360';
  string public constant ASSET_BORROW_CAP_EXCEEDED = '361';
  string public constant ASSET_IS_FLASHLOAN_DISABLED = '362';
  string public constant ASSET_SUPPLY_MODE_IS_SAME = '363';
  string public constant ASSET_TOKEN_ALREADY_EXISTS = '364';

  string public constant HEALTH_FACTOR_BELOW_LIQUIDATION_THRESHOLD = '400';
  string public constant HEALTH_FACTOR_NOT_BELOW_LIQUIDATION_THRESHOLD = '401';
  string public constant CROSS_SUPPLY_NOT_EMPTY = '402';
  string public constant ISOLATE_SUPPLY_NOT_EMPTY = '403';
  string public constant CROSS_BORROW_NOT_EMPTY = '404';
  string public constant ISOLATE_BORROW_NOT_EMPTY = '405';
  string public constant COLLATERAL_BALANCE_IS_ZERO = '406';
  string public constant BORROW_BALANCE_IS_ZERO = '407';
  string public constant LTV_VALIDATION_FAILED = '408';
  string public constant COLLATERAL_CANNOT_COVER_NEW_BORROW = '409';
  string public constant LIQUIDATE_REPAY_DEBT_FAILED = '410';
  string public constant ORACLE_PRICE_IS_STALE = '411';
  string public constant LIQUIDATION_EXCEED_MAX_TOKEN_NUM = '412';
  string public constant USER_COLLATERAL_SUPPLY_ZERO = '413';
  string public constant ACTUAL_COLLATERAL_TO_LIQUIDATE_ZERO = '414';
  string public constant ACTUAL_DEBT_TO_LIQUIDATE_ZERO = '415';
  string public constant USER_DEBT_BORROWED_ZERO = '416';

  string public constant YIELD_EXCEED_ASSET_CAP_LIMIT = '500';
  string public constant YIELD_EXCEED_STAKER_CAP_LIMIT = '501';
  string public constant YIELD_TOKEN_ALREADY_LOCKED = '502';
  string public constant YIELD_ACCOUNT_NOT_EXIST = '503';
  string public constant YIELD_ACCOUNT_ALREADY_EXIST = '504';
  string public constant YIELD_REGISTRY_IS_NOT_AUTH = '505';
  string public constant YIELD_MANAGER_IS_NOT_AUTH = '506';
  string public constant YIELD_ACCOUNT_IMPL_ZERO = '507';

  string public constant ISOLATE_LOAN_ASSET_NOT_MATCH = '600';
  string public constant ISOLATE_LOAN_GROUP_NOT_MATCH = '601';
  string public constant ISOLATE_LOAN_OWNER_NOT_MATCH = '602';
  string public constant ISOLATE_BORROW_NOT_EXCEED_LIQUIDATION_THRESHOLD = '603';
  string public constant ISOLATE_BID_PRICE_LESS_THAN_BORROW = '604';
  string public constant ISOLATE_BID_PRICE_LESS_THAN_LIQUIDATION_PRICE = '605';
  string public constant ISOLATE_BID_PRICE_LESS_THAN_HIGHEST_PRICE = '606';
  string public constant ISOLATE_BID_AUCTION_DURATION_HAS_END = '607';
  string public constant ISOLATE_BID_AUCTION_DURATION_NOT_END = '608';
  string public constant ISOLATE_LOAN_BORROW_AMOUNT_NOT_COVER = '609';
  string public constant ISOLATE_LOAN_EXISTS = '610';

  // Yield Staking, don't care about the ETH
  string public constant YIELD_ETH_NFT_NOT_ACTIVE = '1000';
  string public constant YIELD_ETH_POOL_NOT_SAME = '1001';
  string public constant YIELD_ETH_STATUS_NOT_ACTIVE = '1002';
  string public constant YIELD_ETH_STATUS_NOT_UNSTAKE = '1003';
  string public constant YIELD_ETH_NFT_ALREADY_USED = '1004';
  string public constant YIELD_ETH_NFT_NOT_USED_BY_ME = '1005';
  string public constant YIELD_ETH_EXCEED_MAX_BORROWABLE = '1006';
  string public constant YIELD_ETH_HEATH_FACTOR_TOO_LOW = '1007';
  string public constant YIELD_ETH_HEATH_FACTOR_TOO_HIGH = '1008';
  string public constant YIELD_ETH_EXCEED_MAX_FINE = '1009';
  string public constant YIELD_ETH_WITHDRAW_NOT_READY = '1010';
  string public constant YIELD_ETH_DEPOSIT_FAILED = '1011';
  string public constant YIELD_ETH_WITHDRAW_FAILED = '1012';
  string public constant YIELD_ETH_CLAIM_FAILED = '1013';
  string public constant YIELD_ETH_ACCOUNT_INSUFFICIENT = '1014';
}
