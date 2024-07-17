# ✨ So you want to run an audit

This `README.md` contains a set of checklists for our audit collaboration.

Your audit will use two repos: 
- **an _audit_ repo** (this one), which is used for scoping your audit and for providing information to wardens
- **a _findings_ repo**, where issues are submitted (shared with you after the audit) 

Ultimately, when we launch the audit, this repo will be made public and will contain the smart contracts to be reviewed and all the information needed for audit participants. The findings repo will be made public after the audit report is published and your team has mitigated the identified issues.

Some of the checklists in this doc are for **C4 (🐺)** and some of them are for **you as the audit sponsor (⭐️)**.

---

# Audit setup

## 🐺 C4: Set up repos
- [ ] Create a new private repo named `YYYY-MM-sponsorname` using this repo as a template.
- [ ] Rename this repo to reflect audit date (if applicable)
- [ ] Rename audit H1 below
- [ ] Update pot sizes
  - [ ] Remove the "Bot race findings opt out" section if there's no bot race.
- [ ] Fill in start and end times in audit bullets below
- [ ] Add link to submission form in audit details below
- [ ] Add the information from the scoping form to the "Scoping Details" section at the bottom of this readme.
- [ ] Add matching info to the Code4rena site
- [ ] Add sponsor to this private repo with 'maintain' level access.
- [ ] Send the sponsor contact the url for this repo to follow the instructions below and add contracts here. 
- [ ] Delete this checklist.

# Repo setup

## ⭐️ Sponsor: Add code to this repo

- [ ] Create a PR to this repo with the below changes:
- [ ] Confirm that this repo is a self-contained repository with working commands that will build (at least) all in-scope contracts, and commands that will run tests producing gas reports for the relevant contracts.
- [ ] Please have final versions of contracts and documentation added/updated in this repo **no less than 48 business hours prior to audit start time.**
- [ ] Be prepared for a 🚨code freeze🚨 for the duration of the audit — important because it establishes a level playing field. We want to ensure everyone's looking at the same code, no matter when they look during the audit. (Note: this includes your own repo, since a PR can leak alpha to our wardens!)

## ⭐️ Sponsor: Repo checklist

- [ ] Modify the [Overview](#overview) section of this `README.md` file. Describe how your code is supposed to work with links to any relevent documentation and any other criteria/details that the auditors should keep in mind when reviewing. (Here are two well-constructed examples: [Ajna Protocol](https://github.com/code-423n4/2023-05-ajna) and [Maia DAO Ecosystem](https://github.com/code-423n4/2023-05-maia))
- [ ] Review the Gas award pool amount, if applicable. This can be adjusted up or down, based on your preference - just flag it for Code4rena staff so we can update the pool totals across all comms channels.
- [ ] Optional: pre-record a high-level overview of your protocol (not just specific smart contract functions). This saves wardens a lot of time wading through documentation.
- [ ] [This checklist in Notion](https://code4rena.notion.site/Key-info-for-Code4rena-sponsors-f60764c4c4574bbf8e7a6dbd72cc49b4#0cafa01e6201462e9f78677a39e09746) provides some best practices for Code4rena audit repos.

## ⭐️ Sponsor: Final touches
- [ ] Review and confirm the pull request created by the Scout (technical reviewer) who was assigned to your contest. *Note: any files not listed as "in scope" will be considered out of scope for the purposes of judging, even if the file will be part of the deployed contracts.*
- [ ] Check that images and other files used in this README have been uploaded to the repo as a file and then linked in the README using absolute path (e.g. `https://github.com/code-423n4/yourrepo-url/filepath.png`)
- [ ] Ensure that *all* links and image/file paths in this README use absolute paths, not relative paths
- [ ] Check that all README information is in markdown format (HTML does not render on Code4rena.com)
- [ ] Delete this checklist and all text above the line below when you're ready.

---

# BendDAO audit details
- Total Prize Pool: $64000 in USDC
  - HM awards: $53800 in USDC
  - (remove this line if there is no Analysis pool) Analysis awards: XXX XXX USDC (Notion: Analysis pool)
  - QA awards: $2200 in USDC
  - (remove this line if there is no Bot race) Bot Race awards: XXX XXX USDC (Notion: Bot Race pool)
 
  - Judge awards: $7500 in USDC
  - Validator awards: XXX XXX USDC (Notion: Triage fee - final)
  - Scout awards: $500 in USDC
  - (this line can be removed if there is no mitigation) Mitigation Review: XXX XXX USDC (*Opportunity goes to top 3 backstage wardens based on placement in this audit who RSVP.*)
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2024-07-benddao/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts July 19, 2024 20:00 UTC
- Ends August 16, 2024 20:00 UTC

## This is a Private audit

This audit repo and its Discord channel are accessible to **certified wardens only.** Participation in private audits is bound by:

1. Code4rena's [Certified Contributor Terms and Conditions](https://github.com/code-423n4/code423n4.com/blob/main/_data/pages/certified-contributor-terms-and-conditions.md)
2. C4's [Certified Contributor Code of Professional Conduct](https://code4rena.notion.site/Code-of-Professional-Conduct-657c7d80d34045f19eee510ae06fef55)

*All discussions regarding private audits should be considered private and confidential, unless otherwise indicated.*

Please review the following confidentiality requirements carefully, and if anything is unclear, ask questions in the private audit channel in the C4 Discord.

>>DRAG IN CLASSIFIED IMAGE HERE

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2024-07-benddao/blob/main/4naly3er-report.md).



_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._
## 🐺 C4: Begin Gist paste here (and delete this line)





# Scope

*See [scope.txt](https://github.com/code-423n4/2024-07-benddao/blob/main/scope.txt)*

### Files in scope


| File   | Logic Contracts | Interfaces | nSLOC | Purpose | Libraries used |
| ------ | --------------- | ---------- | ----- | -----   | ------------ |
| /src/ACLManager.sol | 1| **** | 44 | |@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol|
| /src/PoolManager.sol | 1| **** | 69 | |src/interfaces/IAddressProvider.sol<br>src/interfaces/IACLManager.sol<br>src/libraries/helpers/Constants.sol<br>src/libraries/helpers/Errors.sol<br>src/libraries/logic/StorageSlot.sol<br>src/libraries/types/DataTypes.sol<br>src/base/Base.sol<br>src/base/Proxy.sol|
| /src/PriceOracle.sol | 1| **** | 89 | |@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@chainlink/contracts/src/v0.8/interfaces/AggregatorV2V3Interface.sol|
| /src/libraries/logic/BorrowLogic.sol | 1| **** | 73 | ||
| /src/libraries/logic/ConfigureLogic.sol | 1| **** | 421 | |@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol|
| /src/libraries/logic/FlashLoanLogic.sol | 1| **** | 88 | ||
| /src/libraries/logic/GenericLogic.sol | 1| **** | 264 | |@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol|
| /src/libraries/logic/InterestLogic.sol | 1| **** | 179 | |@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol<br>@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol|
| /src/libraries/logic/IsolateLogic.sol | 1| **** | 335 | ||
| /src/libraries/logic/LiquidationLogic.sol | 1| **** | 308 | |@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol|
| /src/libraries/logic/PoolLogic.sol | 1| **** | 73 | |src/interfaces/IDelegateRegistryV2.sol|
| /src/libraries/logic/QueryLogic.sol | 1| **** | 431 | |@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol<br>src/interfaces/IDelegateRegistryV2.sol|
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
| **Totals** | **38** | **** | **5110** | | |

### Files out of scope

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
| ./src/libraries/helpers/KVSortUtils.sol |
| ./src/libraries/math/MathUtils.sol |
| ./src/libraries/math/PercentageMath.sol |
| ./src/libraries/math/ShareUtils.sol |
| ./src/libraries/math/WadRayMath.sol |
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

