// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {AggregatorV2V3Interface} from '@chainlink/contracts/src/v0.8/interfaces/AggregatorV2V3Interface.sol';

contract MockChainlinkAggregator is AggregatorV2V3Interface {
  uint256 private _version;
  uint8 private _decimals;
  string private _description;

  struct RoundData {
    int192 answer; // 192 bits ought to be enough for anyone
    uint64 timestamp;
  }
  uint80 private _latestRoundId;
  mapping(uint80 => RoundData) private _roundDatas;

  constructor(uint8 decimals_, string memory description_) {
    _decimals = decimals_;
    _description = description_;
  }

  function latestAnswer() public view returns (int256) {
    return _roundDatas[_latestRoundId].answer;
  }

  function latestTimestamp() public view returns (uint256) {
    return _roundDatas[_latestRoundId].timestamp;
  }

  function latestRound() public view returns (uint256) {
    return _latestRoundId;
  }

  function getAnswer(uint256 roundId) public view returns (int256) {
    return _roundDatas[uint80(roundId)].answer;
  }

  function getTimestamp(uint256 roundId) public view returns (uint256) {
    return _roundDatas[uint80(roundId)].timestamp;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }

  function description() public view returns (string memory) {
    return _description;
  }

  function version() public view returns (uint256) {
    return _version;
  }

  function getRoundData(
    uint80 _roundId
  ) public view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) {
    return (
      roundId,
      _roundDatas[_roundId].answer,
      _roundDatas[_roundId].timestamp,
      _roundDatas[_roundId].timestamp,
      roundId
    );
  }

  function latestRoundData()
    public
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
  {
    uint80 _roundId = _latestRoundId;
    return (
      roundId,
      _roundDatas[_roundId].answer,
      _roundDatas[_roundId].timestamp,
      _roundDatas[_roundId].timestamp,
      roundId
    );
  }

  function setRoundData(int256 answer, uint64 timestamp) public {
    _latestRoundId++;
    _roundDatas[_latestRoundId] = RoundData(int192(answer), timestamp);
  }

  function updateAnswer(int256 answer) public {
    _latestRoundId++;
    _roundDatas[_latestRoundId] = RoundData(int192(answer), uint64(block.timestamp));
  }
}
