
# BendDAO audit details
- Total Prize Pool: $64000 in USDC
  - HM awards: $53800 in USDC
  - QA awards: $2200 in USDC
  - Judge awards: $7500 in USDC
  - Scout awards: $500 in USDC
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/audits/2024-07-benddao-invitational/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts July 19, 2024 20:00 UTC
- Ends August 16, 2024 20:00 UTC

## This is a Private audit

This audit repo and its Discord channel are accessible to **certified wardens only.** Participation in private audits is bound by:

1. Code4rena's [Certified Contributor Terms and Conditions](https://github.com/code-423n4/code423n4.com/blob/main/_data/pages/certified-contributor-terms-and-conditions.md)
2. Code4rena's [Certified Contributor Code of Professional Conduct](https://code4rena.notion.site/Code-of-Professional-Conduct-657c7d80d34045f19eee510ae06fef55)

*All discussions regarding private audits should be considered private and confidential, unless otherwise indicated.*

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2024-07-benddao/blob/main/4naly3er-report.md).

_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._

- Centralisation Risk on Contracts which has Owner or Administrator.
- Questioning the protocol’s business model is unreasonable.


# Overview

BendDAO V2 Protocol brings you composable lending and leverage. It allows anyone to borrow in an overcollateralized fashion, leverage savings on MakerDAO, leverage stake on Lido, leverage restake with EigenLayer derivatives, bringing together lending and leverage in the same protocol!

V2 Protocol has three user sides to it:

* Lenders deposit assets to earn passive yield.
* Borrowers can use ERC20 & NFT as collaterals to borrow assets in an overcollateralized fashion.
* Leverage users can use NFT as collaterals to borrow assets to create leverage positions, which can be used across DeFi, NFTs, RWA, etc.

## Cool Features

*   #### **Restaking Specialized Loan**

    BendDAO V2 introduces the first restaking service for NFT holders to earn passive income by Specialized Loan. This groundbreaking feature for bluechip NFTs comes with the V2 update—an exciting development in the realm of DeFi and Restaking. This **Restaking Specialized Loan** feature, leveraging liquid staking and restaking, is designed to revolutionize how NFT holders can capture ETH ecosystem development benefits when holding NFTs.
* **Cross Margin Lending**.&#x20;
* **Isolated Margin Lending**.&#x20;
* **Custom Lending Pools**.&#x20;
* **Custom Interest Rates**.&#x20;
* **Modularity**. V2 Protocol is not just a couple of pools, it's an new architecture of smart contracts which are plug-and-play enabled.
* **Composability**. Other protocols can offer leverage to their users with the help of V2 Protocol, without modifying anything in their own architecture.


## Links

- **Previous audits:**  None
- **Documentation:** https://github.com/BendDAO/bend-gitbook-portal-v2
- **Website:** https://www.benddao.xyz/en/
- **X/Twitter:** https://twitter.com/BendDAO
- **Discord:** https://discord.gg/benddao

---

# Scope

*See [scope.txt](https://github.com/code-423n4/2024-07-benddao/blob/main/scope.txt)*


### Files in scope


| File   | Logic Contracts | Interfaces | nSLOC | Purpose | Libraries used |
| ------ | --------------- | ---------- | ----- | -----   | ------------ |
| /src/ACLManager.sol | 1| **** | 44 | |@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol|
| /src/PoolManager.sol | 1| **** | 69 | |src/interfaces/IAddressProvider.sol<br>src/interfaces/IACLManager.sol<br>src/libraries/helpers/Constants.sol<br>src/libraries/helpers/Errors.sol<br>src/libraries/logic/StorageSlot.sol<br>src/libraries/types/DataTypes.sol<br>src/base/Base.sol<br>src/base/Proxy.sol|
| /src/PriceOracle.sol | 1| **** | 89 | |@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@chainlink/contracts/src/v0.8/interfaces/AggregatorV2V3Interface.sol|
| /src/libraries/helpers/KVSortUtils.sol | 1| **** | 42 | ||
| /src/libraries/math/MathUtils.sol | 1| **** | 44 | ||
| /src/libraries/math/PercentageMath.sol | 1| **** | 22 | ||
| /src/libraries/math/ShareUtils.sol | 1| **** | 11 | ||
| /src/libraries/math/WadRayMath.sol | 1| **** | 57 | ||
| /src/libraries/logic/BorrowLogic.sol | 1| **** | 73 | ||
| /src/libraries/logic/ConfigureLogic.sol | 1| **** | 421 | |@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol|
| /src/libraries/logic/FlashLoanLogic.sol | 1| **** | 88 | ||
| /src/libraries/logic/GenericLogic.sol | 1| **** | 264 | |@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol|
| /src/libraries/logic/InterestLogic.sol | 1| **** | 179 | |@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol<br>@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol|
| /src/libraries/logic/IsolateLogic.sol | 1| **** | 335 | ||
| /src/libraries/logic/LiquidationLogic.sol | 1| **** | 308 | |@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol|
| /src/libraries/logic/PoolLogic.sol | 1| **** | 73 | |src/interfaces/IDelegateRegistryV2.sol|
| /src/libraries/logic/StorageSlot.sol | 1| **** | 11 | ||
| /src/libraries/logic/SupplyLogic.sol | 1| **** | 151 | ||
| /src/libraries/logic/ValidateLogic.sol | 1| **** | 437 | |@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol|
| /src/libraries/logic/VaultLogic.sol | 1| **** | 427 | |@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol|
| /src/libraries/logic/YieldLogic.sol | 1| **** | 99 | ||
| /src/modules/BVault.sol | 1| **** | 116 | ||
| /src/modules/Configurator.sol | 1| **** | 162 | |src/base/BaseModule.sol<br>src/libraries/helpers/Constants.sol<br>src/libraries/logic/StorageSlot.sol<br>src/libraries/logic/ConfigureLogic.sol<br>src/libraries/logic/PoolLogic.sol|
| /src/modules/CrossLending.sol | 1| **** | 57 | ||
| /src/modules/CrossLiquidation.sol | 1| **** | 64 | ||
| /src/modules/FlashLoan.sol | 1| **** | 38 | ||
| /src/modules/IsolateLending.sol | 1| **** | 58 | ||
| /src/modules/IsolateLiquidation.sol | 1| **** | 72 | ||
| /src/modules/Yield.sol | 1| **** | 58 | |src/interfaces/IYield.sol|
| /src/yield/YieldAccount.sol | 1| **** | 44 | |@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/token/ERC721/IERC721.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>@openzeppelin/contracts/utils/Address.sol<br>@openzeppelin/contracts/proxy/utils/Initializable.sol<br>src/libraries/helpers/Errors.sol<br>src/interfaces/IYieldRegistry.sol<br>src/interfaces/IYieldAccount.sol|
| /src/yield/YieldRegistry.sol | 1| **** | 67 | |@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol<br>src/interfaces/IAddressProvider.sol<br>src/interfaces/IACLManager.sol<br>src/interfaces/IYieldRegistry.sol<br>src/libraries/helpers/Constants.sol<br>src/libraries/helpers/Errors.sol|
| /src/yield/YieldStakingBase.sol | 1| **** | 140 | |@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>@openzeppelin/contracts/utils/math/Math.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol<br>src/interfaces/IAddressProvider.sol<br>src/interfaces/IACLManager.sol<br>src/interfaces/IPoolManager.sol<br>src/interfaces/IYield.sol<br>src/interfaces/IPriceOracleGetter.sol<br>src/interfaces/IYieldAccount.sol<br>src/interfaces/IYieldRegistry.sol<br>src/libraries/helpers/Constants.sol<br>src/libraries/helpers/Errors.sol<br>src/libraries/math/PercentageMath.sol<br>src/libraries/math/WadRayMath.sol<br>src/libraries/math/MathUtils.sol<br>src/libraries/math/ShareUtils.sol|
| /src/yield/etherfi/YieldEthStakingEtherfi.sol | 1| **** | 102 | |@openzeppelin/contracts/utils/math/Math.sol<br>src/interfaces/IPriceOracleGetter.sol<br>src/interfaces/IYieldAccount.sol<br>src/interfaces/IYieldRegistry.sol<br>src/interfaces/IWETH.sol<br>src/libraries/helpers/Constants.sol<br>src/libraries/helpers/Errors.sol|
| /src/yield/lido/YieldEthStakingLido.sol | 1| **** | 102 | |@openzeppelin/contracts/utils/math/Math.sol<br>src/interfaces/IPriceOracleGetter.sol<br>src/interfaces/IYieldAccount.sol<br>src/interfaces/IYieldRegistry.sol<br>src/interfaces/IWETH.sol<br>src/interfaces/IStETH.sol<br>src/interfaces/IUnstETH.sol<br>src/libraries/helpers/Constants.sol<br>src/libraries/helpers/Errors.sol|
| /src/yield/sdai/YieldSavingsDai.sol | 1| **** | 100 | |@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol<br>@openzeppelin/contracts/utils/math/Math.sol<br>src/interfaces/IPriceOracleGetter.sol<br>src/interfaces/IYieldAccount.sol<br>src/interfaces/IYieldRegistry.sol<br>src/libraries/helpers/Constants.sol<br>src/libraries/helpers/Errors.sol|
| /src/base/Base.sol | 1| **** | 48 | |@openzeppelin/contracts/security/Pausable.sol<br>@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol<br>src/libraries/helpers/Constants.sol<br>src/libraries/helpers/Events.sol<br>src/libraries/helpers/Errors.sol<br>src/base/Storage.sol<br>src/base/Proxy.sol|
| /src/base/BaseModule.sol | 1| **** | 21 | ||
| /src/base/Proxy.sol | 1| **** | 58 | ||
| /src/base/Storage.sol | 1| **** | 17 | |src/libraries/logic/StorageSlot.sol<br>src/libraries/types/DataTypes.sol|
| /src/libraries/types/DataTypes.sol | 1| **** | 96 | |@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol|
| /src/libraries/types/InputTypes.sol | 1| **** | 167 | ||
| /src/libraries/types/ResultTypes.sol | 1| **** | 24 | ||
| **Totals** | **42** | **** | **4855** | | |

### Files out of scope

In addition to beleow, any files not in the list above is Out Of Scope.

*See [out_of_scope.txt](https://github.com/code-423n4/2024-07-benddao/blob/main/out_of_scope.txt)*

| File         |
| ------------ |
| ./config/ConfigLib.sol |
| ./config/Configured.sol |
| ./script/DeployBase.s.sol |
| ./script/DeployPoolFull.s.sol |
| ./script/DeployPriceAdapter.s.sol |
| ./script/DeployYieldMock.s.sol |
| ./script/DeployYieldStaking.s.sol |
| ./script/InitConfigPool.s.sol |
| ./script/InitConfigYield.s.sol |
| ./script/InstallModule.s.sol |
| ./script/QueryBase.s.sol |
| ./script/QueryPool.s.sol |
| ./script/UpgradeContract.s.sol |
| ./src/AddressProvider.sol |
| ./src/interfaces/IACLManager.sol |
| ./src/interfaces/IAddressProvider.sol |
| ./src/interfaces/IBendNFTOracle.sol |
| ./src/interfaces/IDefaultInterestRateModel.sol |
| ./src/interfaces/IDelegateRegistryV2.sol |
| ./src/interfaces/IFlashLoanReceiver.sol |
| ./src/interfaces/IInterestRateModel.sol |
| ./src/interfaces/IPoolLens.sol |
| ./src/interfaces/IPoolManager.sol |
| ./src/interfaces/IPriceOracle.sol |
| ./src/interfaces/IPriceOracleGetter.sol |
| ./src/interfaces/IStETH.sol |
| ./src/interfaces/IUnstETH.sol |
| ./src/interfaces/IWETH.sol |
| ./src/interfaces/IYield.sol |
| ./src/interfaces/IYieldAccount.sol |
| ./src/interfaces/IYieldRegistry.sol |
| ./src/irm/DefaultInterestRateModel.sol |
| ./src/libraries/helpers/Constants.sol |
| ./src/libraries/helpers/Errors.sol |
| ./src/libraries/helpers/Events.sol |
| ./src/libraries/logic/QueryLogic.sol |
| ./src/modules/Installer.sol |
| ./src/modules/PoolLens.sol |
| ./src/oracles/IDAIPot.sol |
| ./src/oracles/SDAIPriceAdapter.sol |
| ./src/yield/etherfi/ILiquidityPool.sol |
| ./src/yield/etherfi/IWithdrawRequestNFT.sol |
| ./src/yield/etherfi/IeETH.sol |
| ./src/yield/sdai/ISavingsDai.sol |
| ./test/helpers/TestUser.sol |
| ./test/integration/TestACLManager.t.sol |
| ./test/integration/TestDelegateERC721.t.sol |
| ./test/integration/TestIntCollectFeeToTreasury.t.sol |
| ./test/integration/TestIntCrossBorrowERC20.t.sol |
| ./test/integration/TestIntCrossLiquidateERC20.t.sol |
| ./test/integration/TestIntCrossLiquidateERC721.t.sol |
| ./test/integration/TestIntCrossNativeToken.t.sol |
| ./test/integration/TestIntCrossOnBehalf.t.sol |
| ./test/integration/TestIntCrossRepayERC20.t.sol |
| ./test/integration/TestIntDepositERC20.t.sol |
| ./test/integration/TestIntDepositERC721.t.sol |
| ./test/integration/TestIntFlashLoanERC20.t.sol |
| ./test/integration/TestIntFlashLoanERC721.t.sol |
| ./test/integration/TestIntIsolateAuction.t.sol |
| ./test/integration/TestIntIsolateBorrow.t.sol |
| ./test/integration/TestIntIsolateLiquidate.t.sol |
| ./test/integration/TestIntIsolateOnBehalf.t.sol |
| ./test/integration/TestIntIsolateRedeem.t.sol |
| ./test/integration/TestIntIsolateRepay.t.sol |
| ./test/integration/TestIntSetERC721SupplyMode.t.sol |
| ./test/integration/TestIntWithdrawERC20.t.sol |
| ./test/integration/TestIntWithdrawERC721.t.sol |
| ./test/integration/TestIntYieldBorrowERC20.t.sol |
| ./test/integration/TestIntYieldRepayERC20.t.sol |
| ./test/integration/TestPoolLens.t.sol |
| ./test/integration/TestPoolManagerConfig.t.sol |
| ./test/integration/TestPriceOracle.t.sol |
| ./test/mocks/MockBendNFTOracle.sol |
| ./test/mocks/MockChainlinkAggregator.sol |
| ./test/mocks/MockDAIPot.sol |
| ./test/mocks/MockDelegateRegistryV2.sol |
| ./test/mocks/MockERC20.sol |
| ./test/mocks/MockERC721.sol |
| ./test/mocks/MockEtherfiLiquidityPool.sol |
| ./test/mocks/MockEtherfiWithdrawRequestNFT.sol |
| ./test/mocks/MockFaucet.sol |
| ./test/mocks/MockFlashLoanReceiver.sol |
| ./test/mocks/MockSDAI.sol |
| ./test/mocks/MockStETH.sol |
| ./test/mocks/MockUnstETH.sol |
| ./test/mocks/MockWETH.sol |
| ./test/mocks/MockeETH.sol |
| ./test/setup/TestWithBaseAction.sol |
| ./test/setup/TestWithCrossAction.sol |
| ./test/setup/TestWithData.sol |
| ./test/setup/TestWithIsolateAction.sol |
| ./test/setup/TestWithPrepare.sol |
| ./test/setup/TestWithSetup.sol |
| ./test/setup/TestWithUtils.sol |
| ./test/unit/TestPercentageMath.t.sol |
| ./test/unit/TestUnitKVSortUtils.t.sol |
| ./test/unit/TestWadRayMath.t.sol |
| ./test/yield/YieldAccount.t.sol |
| ./test/yield/YieldEthStakingEtherfi.t.sol |
| ./test/yield/YieldEthStakingLido.t.sol |
| ./test/yield/YieldSavingsDai.t.sol |
| Totals: 105 |


## Scoping Q &amp; A

### General questions


| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| ERC20 used by the protocol              |  Any (all possible ERC20s)                  |
| Test coverage                           | Lines: 83.12% - Functions: 72.90%                         |
| ERC721 used  by the protocol            |            Any              |
| ERC777 used by the protocol             |           None                |
| ERC1155 used by the protocol            |              None            |
| Chains the protocol will be deployed on | Ethereum, Arbitrum, Optimism, Polygon |

### ERC20 token behaviors in scope

| Question                                                                                                                                                   | Answer |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| [Missing return values](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#missing-return-values)                                                      |   In scope  |
| [Fee on transfer](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#fee-on-transfer)                                                                  |  In scope  |
| [Balance changes outside of transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#balance-modifications-outside-of-transfers-rebasingairdrops) | In scope    |
| [Upgradeability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#upgradable-tokens)                                                                 |   Out of scope  |
| [Flash minting](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#flash-mintable-tokens)                                                              | Out of scope    |
| [Pausability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#pausable-tokens)                                                                      | In scope    |
| [Approval race protections](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#approval-race-protections)                                              | In scope    |
| [Revert on approval to zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-approval-to-zero-address)                            | In scope    |
| [Revert on zero value approvals](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-approvals)                                    | In scope    |
| [Revert on zero value transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                    | In scope    |
| [Revert on transfer to the zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-transfer-to-the-zero-address)                    | In scope    |
| [Revert on large approvals and/or transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-large-approvals--transfers)                  | In scope    |
| [Doesn't revert on failure](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#no-revert-on-failure)                                                   |  In scope   |
| [Multiple token addresses](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                          | In scope    |
| [Low decimals ( < 6)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#low-decimals)                                                                 |   In scope  |
| [High decimals ( > 18)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#high-decimals)                                                              | In scope    |
| [Blocklists](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#tokens-with-blocklists)                                                                | In scope    |

### External integrations (e.g., Uniswap) behavior in scope:


| Question                                                  | Answer |
| --------------------------------------------------------- | ------ |
| Enabling/disabling fees (e.g. Blur disables/enables fees) | Yes   |
| Pausability (e.g. Uniswap pool gets paused)               |  Yes   |
| Upgradeability (e.g. Uniswap gets upgraded)               |   Yes  |


### EIP compliance checklist
N/A


# Additional context

## Main invariants

N/A


## Attack ideas (where to focus for bugs)
1. Index Overflow Attacks: Interest Rate, e.g. SupplyIndex/BorrowIndex;

2. Multiple Services State Management: Lending & Staking for same NFT; Staking & 
ReStaking for the same NFT; Cross & Isolated & Staking the for same account;

3. State Manipulation: Oracle Price; Vault’s Token Balance, e.g. directly sending ETH/ERC20/ERC721 to PoolManager contract;

4. Missing Permission checks, e.g. Token’s Ownership, Contract’s Admin;


## All trusted roles in the protocol

N/A


## Describe any novel or unique curve logic or mathematical models implemented in the contracts:

N/A


## Running tests


```bash
git clone https://github.com/code-423n4/2024-07-benddao.git
git submodule update --init --recursive
yarn
foundryup
forge test
```


To run code coverage
```bash
forge coverage
```
<pre>| File                                         | % Lines            | % Statements       | % Branches         | % Funcs          |
|----------------------------------------------|--------------------|--------------------|--------------------|------------------|
| config/ConfigLib.sol                         |<font color="#F66151"> 0.00% (0/15)       </font>|<font color="#F66151"> 0.00% (0/29)       </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#F66151"> 0.00% (0/13)     </font>|
| config/Configured.sol                        |<font color="#F66151"> 0.00% (0/8)        </font>|<font color="#F66151"> 0.00% (0/12)       </font>|<font color="#F66151"> 0.00% (0/2)        </font>|<font color="#F66151"> 0.00% (0/4)      </font>|
| script/DeployBase.s.sol                      |<font color="#F66151"> 0.00% (0/8)        </font>|<font color="#F66151"> 0.00% (0/8)        </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#F66151"> 0.00% (0/2)      </font>|
| script/DeployPoolFull.s.sol                  |<font color="#F66151"> 0.00% (0/75)       </font>|<font color="#F66151"> 0.00% (0/107)      </font>|<font color="#F66151"> 0.00% (0/18)       </font>|<font color="#F66151"> 0.00% (0/6)      </font>|
| script/DeployPriceAdapter.s.sol              |<font color="#F66151"> 0.00% (0/16)       </font>|<font color="#F66151"> 0.00% (0/20)       </font>|<font color="#F66151"> 0.00% (0/8)        </font>|<font color="#F66151"> 0.00% (0/2)      </font>|
| script/DeployYieldMock.s.sol                 |<font color="#F66151"> 0.00% (0/12)       </font>|<font color="#F66151"> 0.00% (0/18)       </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#F66151"> 0.00% (0/4)      </font>|
| script/DeployYieldStaking.s.sol              |<font color="#F66151"> 0.00% (0/56)       </font>|<font color="#F66151"> 0.00% (0/70)       </font>|<font color="#F66151"> 0.00% (0/16)       </font>|<font color="#F66151"> 0.00% (0/5)      </font>|
| script/InitConfigPool.s.sol                  |<font color="#F66151"> 0.00% (0/103)      </font>|<font color="#F66151"> 0.00% (0/107)      </font>|<font color="#F66151"> 0.00% (0/4)        </font>|<font color="#F66151"> 0.00% (0/7)      </font>|
| script/InitConfigYield.s.sol                 |<font color="#F66151"> 0.00% (0/53)       </font>|<font color="#F66151"> 0.00% (0/54)       </font>|<font color="#F66151"> 0.00% (0/4)        </font>|<font color="#F66151"> 0.00% (0/5)      </font>|
| script/InstallModule.s.sol                   |<font color="#F66151"> 0.00% (0/32)       </font>|<font color="#F66151"> 0.00% (0/46)       </font>|<font color="#F66151"> 0.00% (0/2)        </font>|<font color="#F66151"> 0.00% (0/3)      </font>|
| script/QueryBase.s.sol                       |<font color="#F66151"> 0.00% (0/3)        </font>|<font color="#F66151"> 0.00% (0/3)        </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#F66151"> 0.00% (0/2)      </font>|
| script/QueryPool.s.sol                       |<font color="#F66151"> 0.00% (0/6)        </font>|<font color="#F66151"> 0.00% (0/7)        </font>|<font color="#F66151"> 0.00% (0/2)        </font>|<font color="#F66151"> 0.00% (0/1)      </font>|
| script/UpgradeContract.s.sol                 |<font color="#F66151"> 0.00% (0/24)       </font>|<font color="#F66151"> 0.00% (0/30)       </font>|<font color="#F66151"> 0.00% (0/6)        </font>|<font color="#F66151"> 0.00% (0/5)      </font>|
| src/ACLManager.sol                           |<font color="#33DA7A"> 91.67% (11/12)     </font>|<font color="#33DA7A"> 93.33% (14/15)     </font>|<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#33DA7A"> 90.91% (10/11)   </font>|
| src/AddressProvider.sol                      |<font color="#E9AD0C"> 74.36% (29/39)     </font>|<font color="#E9AD0C"> 73.77% (45/61)     </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#33DA7A"> 75.00% (18/24)   </font>|
| src/PoolManager.sol                          |<font color="#F66151"> 28.00% (7/25)      </font>|<font color="#F66151"> 23.33% (7/30)      </font>|<font color="#E9AD0C"> 50.00% (6/12)      </font>|<font color="#F66151"> 25.00% (2/8)     </font>|
| src/PriceOracle.sol                          |<font color="#33DA7A"> 95.12% (39/41)     </font>|<font color="#33DA7A"> 96.08% (49/51)     </font>|<font color="#33DA7A"> 100.00% (28/28)    </font>|<font color="#33DA7A"> 90.91% (10/11)   </font>|
| src/base/Base.sol                            |<font color="#E9AD0C"> 64.71% (11/17)     </font>|<font color="#E9AD0C"> 57.14% (12/21)     </font>|<font color="#E9AD0C"> 71.43% (10/14)     </font>|<font color="#F66151"> 28.57% (2/7)     </font>|
| src/base/BaseModule.sol                      |<font color="#F66151"> 20.00% (1/5)       </font>|<font color="#F66151"> 20.00% (1/5)       </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#F66151"> 33.33% (1/3)     </font>|
| src/base/Proxy.sol                           |<font color="#F66151"> 42.86% (3/7)       </font>|<font color="#F66151"> 37.50% (3/8)       </font>|<font color="#F66151"> 16.67% (1/6)       </font>|<font color="#F66151"> 33.33% (1/3)     </font>|
| src/base/Storage.sol                         |<font color="#F66151"> 0.00% (0/1)        </font>|<font color="#F66151"> 0.00% (0/2)        </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#F66151"> 0.00% (0/1)      </font>|
| src/irm/DefaultInterestRateModel.sol         |<font color="#F66151"> 43.75% (7/16)      </font>|<font color="#F66151"> 42.11% (8/19)      </font>|<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#F66151"> 16.67% (1/6)     </font>|
| src/libraries/helpers/KVSortUtils.sol        |<font color="#33DA7A"> 100.00% (21/21)    </font>|<font color="#33DA7A"> 100.00% (30/30)    </font>|<font color="#33DA7A"> 100.00% (10/10)    </font>|<font color="#33DA7A"> 100.00% (2/2)    </font>|
| src/libraries/logic/BorrowLogic.sol          |<font color="#33DA7A"> 97.22% (35/36)     </font>|<font color="#33DA7A"> 97.73% (43/44)     </font>|<font color="#E9AD0C"> 50.00% (2/4)       </font>|<font color="#33DA7A"> 100.00% (2/2)    </font>|
| src/libraries/logic/ConfigureLogic.sol       |<font color="#33DA7A"> 98.77% (322/326)   </font>|<font color="#33DA7A"> 98.66% (369/374)   </font>|<font color="#33DA7A"> 97.89% (186/190)   </font>|<font color="#33DA7A"> 100.00% (33/33)  </font>|
| src/libraries/logic/FlashLoanLogic.sol       |<font color="#33DA7A"> 97.14% (34/35)     </font>|<font color="#33DA7A"> 97.73% (43/44)     </font>|<font color="#33DA7A"> 77.78% (14/18)     </font>|<font color="#33DA7A"> 100.00% (2/2)    </font>|
| src/libraries/logic/GenericLogic.sol         |<font color="#33DA7A"> 98.36% (120/122)   </font>|<font color="#33DA7A"> 98.55% (136/138)   </font>|<font color="#33DA7A"> 95.00% (38/40)     </font>|<font color="#33DA7A"> 100.00% (13/13)  </font>|
| src/libraries/logic/InterestLogic.sol        |<font color="#33DA7A"> 98.51% (66/67)     </font>|<font color="#33DA7A"> 98.70% (76/77)     </font>|<font color="#33DA7A"> 100.00% (22/22)    </font>|<font color="#33DA7A"> 100.00% (9/9)    </font>|
| src/libraries/logic/IsolateLogic.sol         |<font color="#33DA7A"> 98.76% (159/161)   </font>|<font color="#33DA7A"> 98.86% (174/176)   </font>|<font color="#33DA7A"> 95.24% (40/42)     </font>|<font color="#33DA7A"> 100.00% (5/5)    </font>|
| src/libraries/logic/LiquidationLogic.sol     |<font color="#33DA7A"> 94.74% (108/114)   </font>|<font color="#33DA7A"> 95.24% (120/126)   </font>|<font color="#33DA7A"> 81.82% (18/22)     </font>|<font color="#33DA7A"> 100.00% (10/10)  </font>|
| src/libraries/logic/PoolLogic.sol            |<font color="#33DA7A"> 97.50% (39/40)     </font>|<font color="#33DA7A"> 98.04% (50/51)     </font>|<font color="#33DA7A"> 100.00% (18/18)    </font>|<font color="#33DA7A"> 100.00% (5/5)    </font>|
| src/libraries/logic/QueryLogic.sol           |<font color="#33DA7A"> 92.77% (231/249)   </font>|<font color="#33DA7A"> 92.26% (286/310)   </font>|<font color="#33DA7A"> 83.33% (35/42)     </font>|<font color="#33DA7A"> 82.14% (23/28)   </font>|
| src/libraries/logic/StorageSlot.sol          |<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#33DA7A"> 100.00% (1/1)    </font>|
| src/libraries/logic/SupplyLogic.sol          |<font color="#33DA7A"> 94.87% (74/78)     </font>|<font color="#33DA7A"> 95.56% (86/90)     </font>|<font color="#33DA7A"> 85.71% (24/28)     </font>|<font color="#33DA7A"> 100.00% (5/5)    </font>|
| src/libraries/logic/ValidateLogic.sol        |<font color="#33DA7A"> 100.00% (245/245)  </font>|<font color="#33DA7A"> 100.00% (287/287)  </font>|<font color="#33DA7A"> 100.00% (288/288)  </font>|<font color="#33DA7A"> 100.00% (31/31)  </font>|
| src/libraries/logic/VaultLogic.sol           |<font color="#33DA7A"> 90.83% (218/240)   </font>|<font color="#33DA7A"> 90.57% (288/318)   </font>|<font color="#33DA7A"> 88.89% (80/90)     </font>|<font color="#33DA7A"> 90.00% (63/70)   </font>|
| src/libraries/logic/YieldLogic.sol           |<font color="#33DA7A"> 92.59% (50/54)     </font>|<font color="#33DA7A"> 92.45% (49/53)     </font>|<font color="#33DA7A"> 85.00% (17/20)     </font>|<font color="#33DA7A"> 100.00% (3/3)    </font>|
| src/libraries/math/MathUtils.sol             |<font color="#33DA7A"> 100.00% (21/21)    </font>|<font color="#33DA7A"> 100.00% (35/35)    </font>|<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#33DA7A"> 100.00% (4/4)    </font>|
| src/libraries/math/PercentageMath.sol        |<font color="#33DA7A"> 100.00% (4/4)      </font>|<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#33DA7A"> 100.00% (2/2)    </font>|
| src/libraries/math/ShareUtils.sol            |<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#33DA7A"> 100.00% (4/4)      </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#33DA7A"> 100.00% (2/2)    </font>|
| src/libraries/math/WadRayMath.sol            |<font color="#33DA7A"> 100.00% (13/13)    </font>|<font color="#33DA7A"> 100.00% (7/7)      </font>|<font color="#33DA7A"> 100.00% (6/6)      </font>|<font color="#33DA7A"> 100.00% (6/6)    </font>|
| src/modules/BVault.sol                       |<font color="#33DA7A"> 100.00% (29/29)    </font>|<font color="#33DA7A"> 100.00% (38/38)    </font>|<font color="#33DA7A"> 100.00% (8/8)      </font>|<font color="#33DA7A"> 88.89% (8/9)     </font>|
| src/modules/Configurator.sol                 |<font color="#33DA7A"> 100.00% (69/69)    </font>|<font color="#33DA7A"> 100.00% (104/104)  </font>|<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#33DA7A"> 97.06% (33/34)   </font>|
| src/modules/CrossLending.sol                 |<font color="#33DA7A"> 100.00% (16/16)    </font>|<font color="#33DA7A"> 100.00% (20/20)    </font>|<font color="#33DA7A"> 100.00% (8/8)      </font>|<font color="#E9AD0C"> 66.67% (2/3)     </font>|
| src/modules/CrossLiquidation.sol             |<font color="#E9AD0C"> 65.00% (13/20)     </font>|<font color="#E9AD0C"> 69.23% (18/26)     </font>|<font color="#33DA7A"> 100.00% (12/12)    </font>|<font color="#E9AD0C"> 66.67% (2/3)     </font>|
| src/modules/FlashLoan.sol                    |<font color="#33DA7A"> 100.00% (4/4)      </font>|<font color="#33DA7A"> 100.00% (6/6)      </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#E9AD0C"> 66.67% (2/3)     </font>|
| src/modules/Installer.sol                    |<font color="#33DA7A"> 100.00% (13/13)    </font>|<font color="#33DA7A"> 100.00% (20/20)    </font>|<font color="#33DA7A"> 100.00% (4/4)      </font>|<font color="#E9AD0C"> 66.67% (2/3)     </font>|
| src/modules/IsolateLending.sol               |<font color="#E9AD0C"> 68.75% (11/16)     </font>|<font color="#33DA7A"> 75.00% (15/20)     </font>|<font color="#33DA7A"> 100.00% (8/8)      </font>|<font color="#E9AD0C"> 66.67% (2/3)     </font>|
| src/modules/IsolateLiquidation.sol           |<font color="#E9AD0C"> 71.43% (15/21)     </font>|<font color="#33DA7A"> 77.78% (21/27)     </font>|<font color="#33DA7A"> 100.00% (12/12)    </font>|<font color="#33DA7A"> 75.00% (3/4)     </font>|
| src/modules/PoolLens.sol                     |<font color="#33DA7A"> 88.00% (44/50)     </font>|<font color="#33DA7A"> 85.71% (72/84)     </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#33DA7A"> 78.12% (25/32)   </font>|
| src/modules/Yield.sol                        |<font color="#33DA7A"> 100.00% (8/8)      </font>|<font color="#33DA7A"> 100.00% (13/13)    </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#33DA7A"> 83.33% (5/6)     </font>|
| src/oracles/SDAIPriceAdapter.sol             |<font color="#F66151"> 24.00% (6/25)      </font>|<font color="#F66151"> 27.50% (11/40)     </font>|<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#F66151"> 16.67% (2/12)    </font>|
| src/yield/YieldAccount.sol                   |<font color="#33DA7A"> 100.00% (12/12)    </font>|<font color="#33DA7A"> 100.00% (13/13)    </font>|<font color="#33DA7A"> 100.00% (6/6)      </font>|<font color="#33DA7A"> 100.00% (10/10)  </font>|
| src/yield/YieldRegistry.sol                  |<font color="#33DA7A"> 78.26% (18/23)     </font>|<font color="#33DA7A"> 77.78% (21/27)     </font>|<font color="#33DA7A"> 100.00% (12/12)    </font>|<font color="#E9AD0C"> 50.00% (5/10)    </font>|
| src/yield/YieldStakingBase.sol               |<font color="#33DA7A"> 79.90% (167/209)   </font>|<font color="#33DA7A"> 80.08% (197/246)   </font>|<font color="#33DA7A"> 80.00% (72/90)     </font>|<font color="#E9AD0C"> 57.14% (28/49)   </font>|
| src/yield/etherfi/YieldEthStakingEtherfi.sol |<font color="#33DA7A"> 82.61% (38/46)     </font>|<font color="#33DA7A"> 84.21% (48/57)     </font>|<font color="#33DA7A"> 77.78% (14/18)     </font>|<font color="#E9AD0C"> 66.67% (8/12)    </font>|
| src/yield/lido/YieldEthStakingLido.sol       |<font color="#33DA7A"> 84.31% (43/51)     </font>|<font color="#33DA7A"> 86.15% (56/65)     </font>|<font color="#33DA7A"> 80.00% (16/20)     </font>|<font color="#E9AD0C"> 66.67% (8/12)    </font>|
| src/yield/sdai/YieldSavingsDai.sol           |<font color="#33DA7A"> 86.96% (40/46)     </font>|<font color="#33DA7A"> 86.89% (53/61)     </font>|<font color="#33DA7A"> 85.00% (17/20)     </font>|<font color="#E9AD0C"> 71.43% (10/14)   </font>|
| test/helpers/TestUser.sol                    |<font color="#F66151"> 48.53% (33/68)     </font>|<font color="#F66151"> 43.21% (35/81)     </font>|<font color="#E9AD0C"> 66.67% (8/12)      </font>|<font color="#E9AD0C"> 72.41% (21/29)   </font>|
| test/mocks/MockBendNFTOracle.sol             |<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#33DA7A"> 100.00% (2/2)    </font>|
| test/mocks/MockChainlinkAggregator.sol       |<font color="#F66151"> 29.41% (5/17)      </font>|<font color="#F66151"> 29.41% (5/17)      </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#F66151"> 23.08% (3/13)    </font>|
| test/mocks/MockDAIPot.sol                    |<font color="#F66151"> 33.33% (1/3)       </font>|<font color="#F66151"> 33.33% (1/3)       </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#F66151"> 33.33% (1/3)     </font>|
| test/mocks/MockDelegateRegistryV2.sol        |<font color="#33DA7A"> 92.86% (13/14)     </font>|<font color="#33DA7A"> 88.89% (16/18)     </font>|<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#33DA7A"> 75.00% (3/4)     </font>|
| test/mocks/MockERC20.sol                     |<font color="#33DA7A"> 75.00% (3/4)       </font>|<font color="#33DA7A"> 75.00% (3/4)       </font>|<font color="#33DA7A"> 100.00% (2/2)      </font>|<font color="#E9AD0C"> 66.67% (2/3)     </font>|
| test/mocks/MockERC721.sol                    |<font color="#F66151"> 45.45% (5/11)      </font>|<font color="#E9AD0C"> 53.85% (7/13)      </font>|<font color="#33DA7A"> 100.00% (6/6)      </font>|<font color="#F66151"> 20.00% (1/5)     </font>|
| test/mocks/MockEtherfiLiquidityPool.sol      |<font color="#E9AD0C"> 72.73% (16/22)     </font>|<font color="#E9AD0C"> 72.00% (18/25)     </font>|<font color="#33DA7A"> 80.00% (8/10)      </font>|<font color="#E9AD0C"> 62.50% (5/8)     </font>|
| test/mocks/MockEtherfiWithdrawRequestNFT.sol |<font color="#33DA7A"> 90.48% (19/21)     </font>|<font color="#33DA7A"> 91.30% (21/23)     </font>|<font color="#33DA7A"> 100.00% (6/6)      </font>|<font color="#E9AD0C"> 71.43% (5/7)     </font>|
| test/mocks/MockFaucet.sol                    |<font color="#E9AD0C"> 67.39% (31/46)     </font>|<font color="#E9AD0C"> 59.38% (38/64)     </font>|<font color="#33DA7A"> 85.71% (12/14)     </font>|<font color="#E9AD0C"> 70.00% (7/10)    </font>|
| test/mocks/MockFlashLoanReceiver.sol         |<font color="#33DA7A"> 100.00% (16/16)    </font>|<font color="#33DA7A"> 100.00% (20/20)    </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#33DA7A"> 100.00% (2/2)    </font>|
| test/mocks/MockSDAI.sol                      |<font color="#E9AD0C"> 52.38% (11/21)     </font>|<font color="#E9AD0C"> 50.00% (12/24)     </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#E9AD0C"> 50.00% (5/10)    </font>|
| test/mocks/MockStETH.sol                     |<font color="#33DA7A"> 87.50% (14/16)     </font>|<font color="#33DA7A"> 88.24% (15/17)     </font>|<font color="#33DA7A"> 100.00% (10/10)    </font>|<font color="#E9AD0C"> 71.43% (5/7)     </font>|
| test/mocks/MockUnstETH.sol                   |<font color="#33DA7A"> 90.91% (20/22)     </font>|<font color="#33DA7A"> 92.59% (25/27)     </font>|<font color="#33DA7A"> 100.00% (6/6)      </font>|<font color="#33DA7A"> 80.00% (4/5)     </font>|
| test/mocks/MockWETH.sol                      |<font color="#33DA7A"> 81.82% (18/22)     </font>|<font color="#33DA7A"> 84.00% (21/25)     </font>|<font color="#33DA7A"> 80.00% (8/10)      </font>|<font color="#E9AD0C"> 71.43% (5/7)     </font>|
| test/mocks/MockeETH.sol                      |<font color="#E9AD0C"> 66.67% (6/9)       </font>|<font color="#E9AD0C"> 60.00% (6/10)      </font>|<font color="#E9AD0C"> 66.67% (4/6)       </font>|<font color="#E9AD0C"> 66.67% (4/6)     </font>|
| test/setup/TestWithBaseAction.sol            |<font color="#33DA7A"> 98.91% (271/274)   </font>|<font color="#33DA7A"> 83.79% (274/327)   </font>|<font color="#33DA7A"> 98.67% (148/150)   </font>|<font color="#33DA7A"> 96.77% (30/31)   </font>|
| test/setup/TestWithCrossAction.sol           |<font color="#33DA7A"> 94.71% (322/340)   </font>|<font color="#33DA7A"> 81.84% (329/402)   </font>|<font color="#33DA7A"> 92.96% (132/142)   </font>|<font color="#33DA7A"> 100.00% (24/24)  </font>|
| test/setup/TestWithData.sol                  |<font color="#33DA7A"> 97.25% (106/109)   </font>|<font color="#33DA7A"> 97.60% (122/125)   </font>|<font color="#33DA7A"> 100.00% (10/10)    </font>|<font color="#F66151"> 38.46% (5/13)    </font>|
| test/setup/TestWithIsolateAction.sol         |<font color="#33DA7A"> 96.45% (163/169)   </font>|<font color="#33DA7A"> 80.51% (157/195)   </font>|<font color="#33DA7A"> 91.43% (64/70)     </font>|<font color="#33DA7A"> 100.00% (13/13)  </font>|
| test/setup/TestWithPrepare.sol               |<font color="#33DA7A"> 100.00% (21/21)    </font>|<font color="#33DA7A"> 100.00% (24/24)    </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#33DA7A"> 100.00% (11/11)  </font>|
| test/setup/TestWithSetup.sol                 |<font color="#33DA7A"> 100.00% (301/301)  </font>|<font color="#33DA7A"> 100.00% (340/340)  </font>|<font color="#8B8A88"> 100.00% (0/0)      </font>|<font color="#33DA7A"> 100.00% (10/10)  </font>|
| Total                                        |<font color="#33DA7A"> 83.12% (3815/4590) </font>|<font color="#33DA7A"> 80.14% (4443/5544) </font>|<font color="#33DA7A"> 89.20% (1470/1648) </font>|<font color="#E9AD0C"> 72.90% (589/808) </font>|
</pre>

To run gas benchmarks:
```bash
npm run gas-report
```

## Miscellaneous
Employees of BendDAO and employees' family members are ineligible to participate in this audit.
