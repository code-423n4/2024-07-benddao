// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';

contract MockDAIPot is Ownable2Step {
  uint256 internal _chi;

  constructor() {
    _chi = 1e27;
  }

  function chi() external view returns (uint256) {
    return _chi;
  }

  function setChi(uint256 chi_) public onlyOwner {
    _chi = chi_;
  }
}
