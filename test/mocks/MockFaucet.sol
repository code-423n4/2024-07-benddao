// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {EnumerableSet} from '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

import {MockERC20} from './MockERC20.sol';
import {MockWETH} from './MockWETH.sol';
import {MockERC721} from './MockERC721.sol';
import {MockStETH} from './MockStETH.sol';
import {MockUnstETH} from './MockUnstETH.sol';
import {MockeETH} from './MockeETH.sol';

contract MockFaucet is Ownable2Step {
  using EnumerableSet for EnumerableSet.AddressSet;

  uint256 public constant MAX_ERC20_BALANCE_PER_USER = 1_000;
  uint256 public constant MAX_ERC721_BALANCE_PER_USER = 1;

  EnumerableSet.AddressSet private mockERC20Set;
  EnumerableSet.AddressSet private mockERC721Set;

  mapping(string => address) public symbolToERC20s;
  mapping(string => address) public symbolToERC721s;

  mapping(address => uint256) public erc721NextTokenIds;

  mapping(address => bool) public mintedUsers;

  function publicMintAllTokens(address to) public {
    require(!mintedUsers[to], 'MockFaucet: user already minted');

    address[] memory mockERC20Addrs = mockERC20Set.values();
    for (uint i = 0; i < mockERC20Addrs.length; i++) {
      _publicMintERC20(mockERC20Addrs[i], to);
    }

    address[] memory mockERC721Addrs = mockERC721Set.values();
    for (uint i = 0; i < mockERC721Addrs.length; i++) {
      _publicMintERC721(mockERC721Addrs[i], to);
    }
  }

  function _publicMintERC20(address token, address to) private {
    uint8 decimals = MockERC20(token).decimals();
    uint256 amount = MAX_ERC20_BALANCE_PER_USER * (10 ** decimals);

    MockERC20(token).mint(to, amount);
  }

  function _publicMintERC721(address token, address to) private {
    uint256[] memory tokenIds = new uint256[](MAX_ERC721_BALANCE_PER_USER);
    for (uint256 i = 0; i < MAX_ERC721_BALANCE_PER_USER; i++) {
      tokenIds[i] = erc721NextTokenIds[token];
      erc721NextTokenIds[token] += 1;
    }

    MockERC721(token).mint(to, tokenIds);
  }

  function privateMintERC20(address token, address to, uint256 amount) public onlyOwner {
    MockERC20(token).mint(to, amount);
  }

  function privateMintERC721(address token, address to, uint256[] calldata tokenIds) public onlyOwner {
    MockERC721(token).mint(to, tokenIds);
  }

  function createMockERC20(
    string memory name_,
    string memory symbol_,
    uint8 decimals_
  ) public onlyOwner returns (address) {
    require(symbolToERC20s[symbol_] == address(0), 'MockFaucet: symbol already exist');

    MockERC20 token;
    if (keccak256(abi.encodePacked(symbol_)) == keccak256(abi.encodePacked('WETH'))) {
      MockWETH weth = new MockWETH();
      token = MockERC20(address(weth));
    } else {
      token = new MockERC20(name_, symbol_, decimals_);
    }

    symbolToERC20s[symbol_] = address(token);
    mockERC20Set.add(address(token));

    return address(token);
  }

  function createMockStETH() public onlyOwner returns (address) {
    require(symbolToERC20s['stETH'] == address(0), 'MockFaucet: symbol already exist');

    MockStETH stETH = new MockStETH('stETH', 'stETH', 18);

    symbolToERC20s['stETH'] = address(stETH);
    mockERC20Set.add(address(stETH));

    return address(stETH);
  }

  function createMockUnstETH(address stETH) public onlyOwner returns (address) {
    require(symbolToERC721s['unstETH'] == address(0), 'MockFaucet: symbol already exist');

    MockUnstETH unstETH = new MockUnstETH(stETH);

    symbolToERC721s['unstETH'] = address(unstETH);
    mockERC721Set.add(address(unstETH));

    return address(unstETH);
  }

  function createMockERC721(string memory name_, string memory symbol_) public onlyOwner returns (address) {
    require(symbolToERC721s[symbol_] == address(0), 'MockFaucet: symbol already exist');

    MockERC721 token = new MockERC721(name_, symbol_);

    symbolToERC721s[symbol_] = address(token);
    mockERC721Set.add(address(token));

    return address(token);
  }

  function createMockeETH() public onlyOwner returns (address) {
    require(symbolToERC20s['eETH'] == address(0), 'MockFaucet: symbol already exist');

    MockeETH eETH = new MockeETH('eETH', 'eETH', 18);

    symbolToERC20s['eETH'] = address(eETH);
    mockERC20Set.add(address(eETH));

    return address(eETH);
  }
}
