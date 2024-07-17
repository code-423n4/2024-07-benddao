// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IERC20Metadata} from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

import {IPriceOracleGetter} from 'src/interfaces/IPriceOracleGetter.sol';
import {IYieldAccount} from 'src/interfaces/IYieldAccount.sol';
import {IYieldRegistry} from 'src/interfaces/IYieldRegistry.sol';

import {ISavingsDai} from './ISavingsDai.sol';

import {Constants} from 'src/libraries/helpers/Constants.sol';
import {Errors} from 'src/libraries/helpers/Errors.sol';

import {YieldStakingBase} from '../YieldStakingBase.sol';

contract YieldSavingsDai is YieldStakingBase {
  using SafeERC20 for IERC20Metadata;
  using Math for uint256;

  IERC20Metadata public dai;
  ISavingsDai public sdai;

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[20] private __gap;

  constructor() {
    _disableInitializers();
  }

  function initialize(address addressProvider_, address dai_, address sdai_) public initializer {
    require(addressProvider_ != address(0), Errors.ADDR_PROVIDER_CANNOT_BE_ZERO);

    require(dai_ != address(0), Errors.INVALID_ADDRESS);
    require(sdai_ != address(0), Errors.INVALID_ADDRESS);

    __YieldStakingBase_init(addressProvider_, dai_);

    dai = IERC20Metadata(dai_);
    sdai = ISavingsDai(sdai_);
  }

  function createYieldAccount(address user) public virtual override returns (address) {
    super.createYieldAccount(user);

    IYieldAccount yieldAccount = IYieldAccount(yieldAccounts[user]);
    yieldAccount.safeApprove(address(dai), address(sdai), type(uint256).max);

    return address(yieldAccount);
  }

  function batchUnstakeAndRepay(
    uint32 poolId,
    address[] calldata nfts,
    uint256[] calldata tokenIds
  ) public virtual whenNotPaused nonReentrant {
    require(nfts.length == tokenIds.length, Errors.INCONSISTENT_PARAMS_LENGTH);

    for (uint i = 0; i < nfts.length; i++) {
      _unstake(poolId, nfts[i], tokenIds[i], 0);

      _repay(poolId, nfts[i], tokenIds[i]);
    }
  }

  function unstakeAndRepay(uint32 poolId, address nft, uint256 tokenId) public virtual whenNotPaused nonReentrant {
    _unstake(poolId, nft, tokenId, 0);

    _repay(poolId, nft, tokenId);
  }

  function protocolDeposit(YieldStakeData storage /*sd*/, uint256 amount) internal virtual override returns (uint256) {
    IYieldAccount yieldAccount = IYieldAccount(yieldAccounts[msg.sender]);

    dai.safeTransfer(address(yieldAccount), amount);

    bytes memory result = yieldAccount.execute(
      address(sdai),
      abi.encodeWithSelector(ISavingsDai.deposit.selector, amount, address(yieldAccount))
    );
    uint256 yieldAmount = abi.decode(result, (uint256));
    require(yieldAmount > 0, Errors.YIELD_ETH_DEPOSIT_FAILED);

    return yieldAmount;
  }

  /* @dev SavingsDAI no need 2 steps so keep it empty */
  function protocolRequestWithdrawal(YieldStakeData storage sd) internal virtual override {
    require(sd.withdrawAmount > 0, Errors.YIELD_ETH_WITHDRAW_FAILED);
  }

  function protocolClaimWithdraw(YieldStakeData storage sd) internal virtual override returns (uint256) {
    IYieldAccount yieldAccount = IYieldAccount(yieldAccounts[msg.sender]);

    uint256 claimedDai = dai.balanceOf(address(this));

    bytes memory result = yieldAccount.execute(
      address(sdai),
      abi.encodeWithSelector(ISavingsDai.redeem.selector, sd.withdrawAmount, address(this), address(yieldAccount))
    );
    uint256 assetAmount = abi.decode(result, (uint256));
    require(assetAmount > 0, Errors.YIELD_ETH_CLAIM_FAILED);

    claimedDai = dai.balanceOf(address(this)) - claimedDai;
    require(claimedDai > 0, Errors.YIELD_ETH_CLAIM_FAILED);

    return claimedDai;
  }

  function protocolIsClaimReady(YieldStakeData storage sd) internal view virtual override returns (bool) {
    if (sd.state == Constants.YIELD_STATUS_UNSTAKE) {
      return true;
    }
    return false;
  }

  function getAccountTotalUnstakedYield(address account) public view virtual override returns (uint256) {
    /* The withdrawing dai still in account when user do the unstake and waiting for claim (repay) */
    uint256 balance = getAccountYieldBalance(account);
    uint256 inWithdraw = accountYieldInWithdraws[account];

    require(balance >= inWithdraw, Errors.YIELD_ETH_ACCOUNT_INSUFFICIENT);
    return balance - inWithdraw;
  }

  function getAccountYieldBalance(address account) public view virtual override returns (uint256) {
    return sdai.balanceOf(account);
  }

  function getProtocolTokenPriceInUnderlyingAsset() internal view virtual override returns (uint256) {
    IPriceOracleGetter priceOracle = IPriceOracleGetter(addressProvider.getPriceOracle());
    uint256 sDaiPriceInBase = priceOracle.getAssetPrice(address(sdai));
    uint256 daiPriceInBase = priceOracle.getAssetPrice(address(underlyingAsset));
    return sDaiPriceInBase.mulDiv(10 ** underlyingAsset.decimals(), daiPriceInBase);
  }

  function getProtocolTokenAmountInUnderlyingAsset(
    uint256 yieldAmount
  ) internal view virtual override returns (uint256) {
    return sdai.convertToAssets(yieldAmount);
  }

  function getProtocolTokenDecimals() internal view virtual override returns (uint8) {
    return sdai.decimals();
  }
}
