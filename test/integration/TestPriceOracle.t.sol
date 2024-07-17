// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IPriceOracle} from 'src/interfaces/IPriceOracle.sol';

import {Errors} from 'src/libraries/helpers/Errors.sol';
import {PriceOracle} from 'src/PriceOracle.sol';

import 'test/mocks/MockERC20.sol';
import 'test/mocks/MockERC721.sol';
import 'test/mocks/MockChainlinkAggregator.sol';

import 'test/setup/TestWithSetup.sol';
import '@forge-std/Test.sol';

contract TestPriceOracle is TestWithSetup {
  MockERC20 mockErc20NotUsed;
  MockERC20 mockErc20;
  MockChainlinkAggregator mockCLAgg;
  MockERC721 mockErc721;
  MockBendNFTOracle mockNftOracle;

  address[] mockAssetAddrs;
  address[] mockClAggAddrs;

  function onSetUp() public virtual override {
    super.onSetUp();

    mockErc20NotUsed = new MockERC20('NOUSE', 'NOUSE', 18);
    mockErc20 = new MockERC20('TEST', 'TEST', 18);
    mockCLAgg = new MockChainlinkAggregator(8, 'ETH / USD');

    mockErc721 = new MockERC721('TNFT', 'TNFT');
    mockNftOracle = new MockBendNFTOracle();

    mockAssetAddrs = new address[](1);
    mockAssetAddrs[0] = address(mockErc20);

    mockClAggAddrs = new address[](1);
    mockClAggAddrs[0] = address(mockCLAgg);
  }

  function test_RevertIf_CallerNotAdmin() public {
    tsHEVM.expectRevert(bytes(Errors.CALLER_NOT_ORACLE_ADMIN));
    tsHEVM.prank(address(tsHacker1));
    tsPriceOracle.setAssetChainlinkAggregators(mockAssetAddrs, mockClAggAddrs);

    tsHEVM.expectRevert(bytes(Errors.CALLER_NOT_ORACLE_ADMIN));
    tsHEVM.prank(address(tsHacker1));
    tsPriceOracle.setBendNFTOracle(address(mockNftOracle));
  }

  function test_Should_SetAggregators() public {
    tsHEVM.prank(tsOracleAdmin);
    tsPriceOracle.setAssetChainlinkAggregators(mockAssetAddrs, mockClAggAddrs);

    address[] memory retAggs = tsPriceOracle.getAssetChainlinkAggregators(mockAssetAddrs);
    assertEq(retAggs.length, mockAssetAddrs.length, 'retAggs length not match');
    assertEq(retAggs[0], mockClAggAddrs[0], 'retAggs address not match');
  }

  function test_Should_SetNftOracle() public {
    tsHEVM.prank(tsOracleAdmin);
    tsPriceOracle.setBendNFTOracle(address(mockNftOracle));

    address retNftOracle = tsPriceOracle.getBendNFTOracle();
    assertEq(retNftOracle, address(mockNftOracle), 'retNftOracle address not match');
  }

  function test_Should_GetAssetPriceFromChainlink() public {
    IPriceOracle oracle = IPriceOracle(tsPriceOracle);

    tsHEVM.prank(tsOracleAdmin);
    tsPriceOracle.setAssetChainlinkAggregators(mockAssetAddrs, mockClAggAddrs);

    uint256 retPrice0 = tsPriceOracle.getAssetPrice(oracle.BASE_CURRENCY());
    assertEq(retPrice0, oracle.BASE_CURRENCY_UNIT(), 'retPrice0 not match');

    mockCLAgg.updateAnswer(1234);
    uint256 retPrice2 = tsPriceOracle.getAssetPriceFromChainlink(address(mockErc20));
    assertEq(retPrice2, 1234, 'retPrice2 not match');

    mockCLAgg.updateAnswer(4321);
    uint256 retPrice3 = tsPriceOracle.getAssetPriceFromChainlink(address(mockErc20));
    assertEq(retPrice3, 4321, 'retPrice3 not match');
  }

  function test_Should_getAssetPriceFromBendNFTOracle() public {
    IPriceOracle oracle = IPriceOracle(tsPriceOracle);

    tsHEVM.prank(tsOracleAdmin);
    tsPriceOracle.setBendNFTOracle(address(mockNftOracle));

    mockNftOracle.setAssetPrice(oracle.NFT_BASE_CURRENCY(), oracle.NFT_BASE_CURRENCY_UNIT());

    uint256 nftBaseCurrencyInBase = tsPriceOracle.getAssetPrice(oracle.NFT_BASE_CURRENCY());
    uint256 retPrice0 = tsPriceOracle.getAssetPriceFromBendNFTOracle(oracle.NFT_BASE_CURRENCY());
    assertEq(retPrice0, nftBaseCurrencyInBase, 'retPrice0 not match');

    mockNftOracle.setAssetPrice(address(mockErc721), 1234);
    uint256 checkPrice2 = (1234 * nftBaseCurrencyInBase) / oracle.NFT_BASE_CURRENCY_UNIT();
    uint256 retPrice2 = tsPriceOracle.getAssetPriceFromBendNFTOracle(address(mockErc721));
    assertEq(retPrice2, checkPrice2, 'retPrice2 not match');

    mockNftOracle.setAssetPrice(address(mockErc721), 4321);
    uint256 checkPrice3 = (4321 * nftBaseCurrencyInBase) / oracle.NFT_BASE_CURRENCY_UNIT();
    uint256 retPrice3 = tsPriceOracle.getAssetPriceFromBendNFTOracle(address(mockErc721));
    assertEq(retPrice3, checkPrice3, 'retPrice3 not match');
  }
}
