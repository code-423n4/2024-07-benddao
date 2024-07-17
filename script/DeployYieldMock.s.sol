// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Constants} from 'src/libraries/helpers/Constants.sol';

import {MockERC20} from 'test/mocks/MockERC20.sol';

import {MockStETH} from 'test/mocks/MockStETH.sol';
import {MockUnstETH} from 'test/mocks/MockUnstETH.sol';

import {MockeETH} from 'test/mocks/MockeETH.sol';
import {MockEtherfiWithdrawRequestNFT} from 'test/mocks/MockEtherfiWithdrawRequestNFT.sol';
import {MockEtherfiLiquidityPool} from 'test/mocks/MockEtherfiLiquidityPool.sol';

import {MockSDAI} from 'test/mocks/MockSDAI.sol';
import {MockDAIPot} from 'test/mocks/MockDAIPot.sol';

import {Configured, ConfigLib, Config} from 'config/Configured.sol';
import {DeployBase} from './DeployBase.s.sol';

import '@forge-std/Script.sol';

contract DeployYieldMock is DeployBase {
  using ConfigLib for Config;

  function _deploy() internal virtual override {
    //_deployMockLido();

    //_deployMockEtherfi();

    _deployMockSDai();
  }

  function _deployMockLido() internal {
    MockStETH stETH = new MockStETH('stETH', 'stETH', 18);
    MockUnstETH unstETH = new MockUnstETH(address(stETH));

    stETH.setUnstETH(address(unstETH));
  }

  function _deployMockEtherfi() internal {
    MockeETH eETH = new MockeETH('eETH', 'eETH', 18);
    MockEtherfiWithdrawRequestNFT nft = new MockEtherfiWithdrawRequestNFT();
    MockEtherfiLiquidityPool pool = new MockEtherfiLiquidityPool(address(eETH), address(nft));

    eETH.setLiquidityPool(address(pool));
    nft.setLiquidityPool(address(pool), address(eETH));
  }

  function _deployMockSDai() internal {
    new MockDAIPot();
    MockERC20 dai = new MockERC20('Dai Stablecoin', 'DAI', 18);
    new MockSDAI(address(dai));
  }
}
