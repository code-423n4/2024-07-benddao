// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

import {ISavingsDai, IERC20Metadata} from 'src/yield/sdai/ISavingsDai.sol';

contract MockSDAI is ISavingsDai, ERC20, Ownable2Step {
  uint256 private constant RAY = 10 ** 27;

  address private _dai;
  uint8 private _decimals;
  uint256 private _ratio;

  constructor(address dai_) ERC20('Savings Dai', 'sDAI') {
    _dai = dai_;
    _decimals = 18;
    _ratio = RAY;
  }

  function dai() public view returns (address) {
    return _dai;
  }

  function deposit(uint256 assets, address receiver) public returns (uint256 shares) {
    ERC20(_dai).transferFrom(msg.sender, address(this), assets);

    shares = (assets * RAY) / _ratio;
    _mint(receiver, shares);

    return shares;
  }

  function redeem(uint256 shares, address receiver, address owner) public returns (uint256 assets) {
    _burn(owner, shares);

    assets = (shares * _ratio) / RAY;
    ERC20(_dai).transfer(receiver, assets);

    return assets;
  }

  function convertToShares(uint256 assets) public view returns (uint256) {
    return (assets * RAY) / _ratio;
  }

  function convertToAssets(uint256 shares) public view returns (uint256) {
    return (shares * _ratio) / RAY;
  }

  function rebase(address receiver, uint256 amount) public returns (uint256) {
    ERC20(_dai).transferFrom(msg.sender, address(this), amount);

    _mint(receiver, amount);

    return amount;
  }

  function decimals() public view override(ERC20, IERC20Metadata) returns (uint8) {
    return _decimals;
  }

  function setRatio(uint256 ratio_) public onlyOwner {
    _ratio = ratio_;
  }

  function transferDAI(address receiver) public onlyOwner {
    uint256 amount = ERC20(_dai).balanceOf(address(this));
    ERC20(_dai).transfer(receiver, amount);
  }
}
