// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {ERC721} from '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import {ERC721Enumerable} from '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

import {IeETH} from 'src/yield/etherfi/IeETH.sol';
import {ILiquidityPool} from 'src/yield/etherfi/ILiquidityPool.sol';
import {IWithdrawRequestNFT} from 'src/yield/etherfi/IWithdrawRequestNFT.sol';

contract MockEtherfiWithdrawRequestNFT is IWithdrawRequestNFT, ERC721Enumerable, Ownable2Step {
  IeETH private _eETH;
  ILiquidityPool private _liquidityPool;

  uint256 private _nextRequestId;
  mapping(uint256 => WithdrawRequest) private _withdrawRequests;
  mapping(uint256 => bool) private _isFinalizeds;
  mapping(uint256 => bool) private _isClaimeds;

  constructor() ERC721('MockEtherfiWithdrawRequestNFT', 'WithdrawRequestNFT') {
    _nextRequestId = 1;
  }

  function requestWithdraw(
    uint96 amountOfEEth,
    uint96 shareOfEEth,
    address requester,
    uint256 fee
  ) external payable override returns (uint256) {
    require(msg.sender == address(_liquidityPool), 'Incorrect Caller');

    uint256 reqId = _nextRequestId++;

    _withdrawRequests[reqId].amountOfEEth = amountOfEEth;
    _withdrawRequests[reqId].shareOfEEth = shareOfEEth;
    _withdrawRequests[reqId].isValid = true;
    _withdrawRequests[reqId].feeGwei = uint32(fee / 1 gwei);

    _mint(requester, reqId);

    return reqId;
  }

  function claimWithdraw(uint256 requestId) external override {
    address reqOwner = ownerOf(requestId);
    require(reqOwner == msg.sender, 'Not Owner');
    require(!_isClaimeds[requestId], 'Already Claimed');

    _liquidityPool.withdraw(reqOwner, _withdrawRequests[requestId].amountOfEEth);

    _isClaimeds[requestId] = true;

    _burn(requestId);
  }

  function getRequest(uint256 requestId) external view override returns (WithdrawRequest memory) {
    return _withdrawRequests[requestId];
  }

  function isFinalized(uint256 requestId) external view override returns (bool) {
    return _isFinalizeds[requestId];
  }

  function setWithdrawalStatus(uint256 requestId, bool isFinalized_, bool isClaimed_) public {
    _isFinalizeds[requestId] = isFinalized_;
    _isClaimeds[requestId] = isClaimed_;
  }

  function setLiquidityPool(address pool, address eETH_) public onlyOwner {
    _liquidityPool = ILiquidityPool(pool);
    _eETH = IeETH(eETH_);
  }
}
