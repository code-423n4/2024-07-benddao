// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'src/interfaces/IBendNFTOracle.sol';

contract MockBendNFTOracle is IBendNFTOracle {
  mapping(address => uint256) public prices;

  function getAssetPrice(address _nftContract) public view returns (uint256 price) {
    price = prices[_nftContract];
  }

  function setAssetPrice(address _nftContract, uint256 price) public {
    prices[_nftContract] = price;
  }
}
