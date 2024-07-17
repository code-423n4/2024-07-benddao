// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {ERC721} from '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import {ERC721Enumerable} from '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

contract MockERC721 is ERC721Enumerable, Ownable2Step {
  uint256 public maxSupply;
  uint256 public maxTokenId;
  string private __baseURI;

  constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
    maxSupply = 20_000;
    maxTokenId = maxSupply - 1;
  }

  function mint(address to, uint256[] calldata tokenIds) public {
    require(msg.sender == owner(), 'MockERC721: caller not owner');
    require(totalSupply() + tokenIds.length <= maxSupply, 'MockERC721: exceed max supply');

    for (uint256 i = 0; i < tokenIds.length; i++) {
      require(tokenIds[i] <= maxTokenId, 'MockERC721: exceed max token id');
      _mint(to, tokenIds[i]);
    }
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return __baseURI;
  }

  function setBaseURI(string memory baseURI_) public onlyOwner {
    __baseURI = baseURI_;
  }

  function setMaxSupplyAndTokenId(uint256 maxSupply_, uint256 maxTokenId_) public onlyOwner {
    maxSupply = maxSupply_;
    maxTokenId = maxTokenId_;
  }
}
