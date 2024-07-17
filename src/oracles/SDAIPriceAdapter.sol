// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {AggregatorV2V3Interface} from '@chainlink/contracts/src/v0.8/interfaces/AggregatorV2V3Interface.sol';

import {IDAIPot} from './IDAIPot.sol';

/**
 * @title SDAIPriceAdapter
 * @notice Price adapter to calculate price of sDAI pair by using
 * @notice Chainlink Data Feed for DAI and rate provider for sDAI.
 */
contract SDAIPriceAdapter {
  /**
   * @notice Price feed for DAI pair
   */
  AggregatorV2V3Interface public immutable DAI_AGGREGATOR;

  /**
   * @notice rate provider for (sDAI / DAI)
   */
  IDAIPot public immutable RATE_PROVIDER;

  /**
   * @notice Number of decimals for sDAI / DAI ratio
   */
  uint8 public constant RATIO_DECIMALS = 27;

  /**
   * @notice Number of decimals in the output of this price adapter
   */
  uint8 public immutable DECIMALS;

  string private _description;

  /**
   * @param daiAggregatorAddress the address of DAI feed
   * @param rateProviderAddress the address of the rate provider
   * @param pairName the name identifier of sDAI paire
   */
  constructor(address daiAggregatorAddress, address rateProviderAddress, string memory pairName) {
    DAI_AGGREGATOR = AggregatorV2V3Interface(daiAggregatorAddress);
    RATE_PROVIDER = IDAIPot(rateProviderAddress);

    DECIMALS = DAI_AGGREGATOR.decimals();

    _description = pairName;
  }

  function description() public view returns (string memory) {
    return _description;
  }

  function decimals() public view returns (uint8) {
    return DECIMALS;
  }

  function version() public view returns (uint256) {
    return DAI_AGGREGATOR.version();
  }

  function latestAnswer() public view virtual returns (int256) {
    int256 daiPrice = DAI_AGGREGATOR.latestAnswer();
    return _convertDAIPrice(daiPrice);
  }

  function latestTimestamp() public view returns (uint256) {
    return DAI_AGGREGATOR.latestTimestamp();
  }

  function latestRound() public view returns (uint256) {
    return DAI_AGGREGATOR.latestRound();
  }

  function getAnswer(uint256 roundId) public view returns (int256) {
    int256 daiPrice = DAI_AGGREGATOR.getAnswer(roundId);
    int256 sdaiPrice = _convertDAIPrice(daiPrice);
    return sdaiPrice;
  }

  function getTimestamp(uint256 roundId) public view returns (uint256) {
    return DAI_AGGREGATOR.getTimestamp(roundId);
  }

  function latestRoundData()
    public
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
  {
    (uint80 roundId_, int256 daiPrice, uint256 startedAt_, uint256 updatedAt_, uint80 answeredInRound_) = DAI_AGGREGATOR
      .latestRoundData();

    int256 sdaiPrice = _convertDAIPrice(daiPrice);

    return (roundId_, sdaiPrice, startedAt_, updatedAt_, answeredInRound_);
  }

  function getRoundData(
    uint80 _roundId
  ) public view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) {
    (uint80 roundId_, int256 daiPrice, uint256 startedAt_, uint256 updatedAt_, uint80 answeredInRound_) = DAI_AGGREGATOR
      .getRoundData(_roundId);

    int256 sdaiPrice = _convertDAIPrice(daiPrice);

    return (roundId_, sdaiPrice, startedAt_, updatedAt_, answeredInRound_);
  }

  function _convertDAIPrice(int256 daiPrice) internal view returns (int256) {
    int256 ratio = int256(RATE_PROVIDER.chi());

    if (daiPrice <= 0 || ratio <= 0) {
      return 0;
    }

    return (daiPrice * ratio) / int256(10 ** RATIO_DECIMALS);
  }
}
