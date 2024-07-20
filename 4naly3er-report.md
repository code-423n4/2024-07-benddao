# Report


## Gas Optimizations


| |Issue|Instances|
|-|:-|:-:|
| [GAS-1](#GAS-1) | Use ERC721A instead ERC721 | 1 |
| [GAS-2](#GAS-2) | `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings) | 57 |
| [GAS-3](#GAS-3) | Comparing to a Boolean constant | 3 |
| [GAS-4](#GAS-4) | Using bools for storage incurs overhead | 2 |
| [GAS-5](#GAS-5) | Cache array length outside of loop | 64 |
| [GAS-6](#GAS-6) | For Operations that will not overflow, you could use unchecked | 609 |
| [GAS-7](#GAS-7) | Avoid contract existence checks by using low level calls | 20 |
| [GAS-8](#GAS-8) | Functions guaranteed to revert when called by normal users can be marked `payable` | 22 |
| [GAS-9](#GAS-9) | `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`) | 67 |
| [GAS-10](#GAS-10) | Using `private` rather than `public` for constants, saves gas | 4 |
| [GAS-11](#GAS-11) | Use shift right/left instead of division/multiplication if possible | 1 |
| [GAS-12](#GAS-12) | Splitting require() statements that use && saves gas | 3 |
| [GAS-13](#GAS-13) | Increments/decrements can be unchecked in for-loops | 66 |
| [GAS-14](#GAS-14) | Use != 0 instead of > 0 for unsigned integer comparison | 65 |
### <a name="GAS-1"></a>[GAS-1] Use ERC721A instead ERC721
ERC721A standard, ERC721A is an improvement standard for ERC721 tokens. It was proposed by the Azuki team and used for developing their NFT collection. Compared with ERC721, ERC721A is a more gas-efficient standard to mint a lot of of NFTs simultaneously. It allows developers to mint multiple NFTs at the same gas price. This has been a great improvement due to Ethereum's sky-rocketing gas fee.

    Reference: https://nextrope.com/erc721-vs-erc721a-2/

*Instances (1)*:
```solidity
File: src/yield/YieldAccount.sol

5: import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldAccount.sol)

### <a name="GAS-2"></a>[GAS-2] `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings)
This saves **16 gas per instance.**

*Instances (57)*:
```solidity
File: src/libraries/logic/BorrowLogic.sol

45:       totalBorrowAmount += params.amounts[gidx];

94:       totalRepayAmount += params.amounts[gidx];

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/BorrowLogic.sol)

```solidity
File: src/libraries/logic/ConfigureLogic.sol

42:     ps.nextPoolId += 1;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ConfigureLogic.sol)

```solidity
File: src/libraries/logic/GenericLogic.sol

116:         result.totalCollateralInBaseCurrency += vars.userBalanceInBaseCurrency;

119:           result.inputCollateralInBaseCurrency += vars.userBalanceInBaseCurrency;

122:         result.allGroupsCollateralInBaseCurrency[currentAssetData.classGroup] += vars.userBalanceInBaseCurrency;

125:           result.avgLtv += vars.userBalanceInBaseCurrency * currentAssetData.collateralFactor;

127:           result.allGroupsAvgLtv[currentAssetData.classGroup] +=

132:         result.avgLiquidationThreshold += vars.userBalanceInBaseCurrency * currentAssetData.liquidationThreshold;

134:         result.allGroupsAvgLiquidationThreshold[currentAssetData.classGroup] +=

168:         vars.userAssetDebtInBaseCurrency += vars.userGroupDebtInBaseCurrency;

170:         result.allGroupsDebtInBaseCurrency[vars.currentGroupId] += vars.userGroupDebtInBaseCurrency;

173:       result.totalDebtInBaseCurrency += vars.userAssetDebtInBaseCurrency;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/GenericLogic.sol)

```solidity
File: src/libraries/logic/InterestLogic.sol

159:       vars.totalAssetDebt += vars.loopGroupDebt;

185:         vars.nextAssetBorrowRate += vars.nextGroupBorrowRate.rayMul(vars.allGroupDebtList[vars.i]).rayDiv(

251:       assetData.accruedFee += vars.amountToMint.rayDiv(assetData.supplyIndex).toUint128();

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/InterestLogic.sol)

```solidity
File: src/libraries/logic/IsolateLogic.sol

77:         loanData.scaledAmount += vars.amountScaled;

82:       vars.totalBorrowAmount += params.amounts[vars.nidx];

153:       vars.totalRepayAmount += params.amounts[vars.nidx];

265:       vars.totalBidAmount += params.amounts[vars.nidx];

361:       vars.totalRedeemAmount += vars.redeemAmounts[vars.nidx];

447:       vars.totalBorrowAmount += vars.borrowAmount;

448:       vars.totalBidAmount += loanData.bidAmount;

449:       vars.totalExtraAmount += vars.extraBorrowAmounts[vars.nidx];

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/IsolateLogic.sol)

```solidity
File: src/libraries/logic/ValidateLogic.sol

212:         vars.totalNewBorrowAmount += inputParams.amounts[vars.gidx];

270:       vars.totalNewBorrowAmount += inputParams.amounts[vars.gidx];

404:       vars.totalNewBorrowAmount += inputParams.amounts[vars.i];

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ValidateLogic.sol)

```solidity
File: src/libraries/logic/VaultLogic.sol

215:     assetData.totalScaledCrossSupply += amountScaled;

216:     assetData.userScaledCrossSupply[account] += amountScaled;

243:     assetData.userScaledCrossSupply[to] += amountScaled;

267:       totalBorrow += groupData.totalScaledCrossBorrow.rayMul(groupData.borrowIndex);

293:       totalBorrow += groupData.totalScaledIsolateBorrow.rayMul(groupData.borrowIndex);

321:       totalScaledBorrow += groupData.userScaledCrossBorrow[account];

351:       totalBorrow += groupData.userScaledCrossBorrow[account].rayMul(groupData.borrowIndex);

379:     groupData.totalScaledCrossBorrow += amountScaled;

380:     groupData.userScaledCrossBorrow[account] += amountScaled;

387:     groupData.totalScaledIsolateBorrow += amountScaled;

388:     groupData.userScaledIsolateBorrow[account] += amountScaled;

396:     groupData.totalScaledIsolateBorrow += amountScaled;

397:     groupData.userScaledIsolateBorrow[account] += amountScaled;

432:     assetData.availableLiquidity += amount;

472:     assetData.totalBidAmout += amount;

498:     assetData.availableLiquidity += amount;

574:     assetData.totalScaledCrossSupply += tokenIds.length;

575:     assetData.userScaledCrossSupply[user] += tokenIds.length;

589:     assetData.totalScaledIsolateSupply += tokenIds.length;

590:     assetData.userScaledIsolateSupply[user] += tokenIds.length;

661:     assetData.userScaledCrossSupply[to] += tokenIds.length;

679:     assetData.userScaledIsolateSupply[to] += tokenIds.length;

692:       assetData.userScaledIsolateSupply[to] += 1;

706:     assetData.availableLiquidity += tokenIds.length;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/yield/YieldStakingBase.sol

263:     sd.debtShare += vars.debtShare;

264:     sd.yieldShare += vars.yieldShare;

267:     totalDebtShare += vars.debtShare;

268:     accountYieldShares[address(vars.yieldAccout)] += vars.yieldShare;

336:       totalUnstakeFine += unstakeFine;

341:     accountYieldInWithdraws[address(vars.yieldAccout)] += sd.withdrawAmount;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

### <a name="GAS-3"></a>[GAS-3] Comparing to a Boolean constant
Comparing to a constant (`true` or `false`) is a bit more expensive than directly checking the returned boolean value.

Consider using `if(directValue)` instead of `if(directValue == true)` and `if(!directValue)` instead of `if(directValue == false)`

*Instances (3)*:
```solidity
File: src/libraries/logic/ConfigureLogic.sol

100:     require(poolData.enabledGroups[groupId] == false, Errors.GROUP_ALREADY_EXISTS);

118:     require(poolData.enabledGroups[groupId] == true, Errors.GROUP_NOT_EXISTS);

284:     require(poolData.enabledGroups[groupId] == true, Errors.GROUP_NOT_EXISTS);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ConfigureLogic.sol)

### <a name="GAS-4"></a>[GAS-4] Using bools for storage incurs overhead
Use uint256(1) and uint256(2) for true/false to avoid a Gwarmaccess (100 gas), and to avoid Gsset (20000 gas) when changing from ‘false’ to ‘true’, after having been ‘true’ in the past. See [source](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/58f635312aa21f947cae5f8578638a85aa2519f5/contracts/security/ReentrancyGuard.sol#L23-L27).

*Instances (2)*:
```solidity
File: src/libraries/types/DataTypes.sol

15:     mapping(uint8 => bool) enabledGroups;

37:     mapping(address => mapping(address => bool)) operatorApprovals;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/types/DataTypes.sol)

### <a name="GAS-5"></a>[GAS-5] Cache array length outside of loop
If not cached, the solidity compiler will always read the length of the array during each iteration. That is, if it is a storage array, this is an extra sload operation (100 additional extra gas for each iteration except for the first) and if it is a memory array, this is an extra mload operation (3 additional gas for each iteration except for the first).

*Instances (64)*:
```solidity
File: src/PriceOracle.sol

78:     for (uint256 i = 0; i < assets.length; i++) {

88:     for (uint256 i = 0; i < assets.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/libraries/logic/BorrowLogic.sol

41:     for (uint256 gidx = 0; gidx < params.groups.length; gidx++) {

82:     for (uint256 gidx = 0; gidx < params.groups.length; gidx++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/BorrowLogic.sol)

```solidity
File: src/libraries/logic/ConfigureLogic.sol

122:     for (uint256 i = 0; i < allAssets.length; i++) {

158:       for (uint256 i = 0; i < allAssets.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ConfigureLogic.sol)

```solidity
File: src/libraries/logic/FlashLoanLogic.sol

30:     for (i = 0; i < inputParams.assets.length; i++) {

72:     for (i = 0; i < inputParams.nftTokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/FlashLoanLogic.sol)

```solidity
File: src/libraries/logic/GenericLogic.sol

89:     for (vars.assetIndex = 0; vars.assetIndex < vars.userSuppliedAssets.length; vars.assetIndex++) {

142:     for (vars.assetIndex = 0; vars.assetIndex < vars.userBorrowedAssets.length; vars.assetIndex++) {

157:       for (vars.groupIndex = 0; vars.groupIndex < vars.assetGroupIds.length; vars.groupIndex++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/GenericLogic.sol)

```solidity
File: src/libraries/logic/InterestLogic.sol

109:     for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {

152:     for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {

173:     for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/InterestLogic.sol)

```solidity
File: src/libraries/logic/IsolateLogic.sol

53:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

129:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

205:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

314:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

413:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/IsolateLogic.sol)

```solidity
File: src/libraries/logic/LiquidationLogic.sol

312:     for (uint256 i = 0; i < groupRateList.length; i++) {

321:     for (uint256 i = 0; i < groupRateList.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/LiquidationLogic.sol)

```solidity
File: src/libraries/logic/PoolLogic.sol

46:     for (uint256 i = 0; i < assets.length; i++) {

85:     for (uint256 i = 0; i < params.tokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/PoolLogic.sol)

```solidity
File: src/libraries/logic/SupplyLogic.sol

131:       for (uint256 i = 0; i < params.tokenIds.length; i++) {

168:     for (uint256 i = 0; i < params.tokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/SupplyLogic.sol)

```solidity
File: src/libraries/logic/ValidateLogic.sol

51:     for (uint i = 0; i < values.length; i++) {

52:       for (uint j = i + 1; j < values.length; j++) {

59:     for (uint i = 0; i < values.length; i++) {

60:       for (uint j = i + 1; j < values.length; j++) {

134:     for (uint256 i = 0; i < inputParams.tokenIds.length; i++) {

166:     for (uint256 i = 0; i < inputParams.tokenIds.length; i++) {

211:       for (vars.gidx = 0; vars.gidx < inputParams.groups.length; vars.gidx++) {

243:     for (vars.gidx = 0; vars.gidx < inputParams.groups.length; vars.gidx++) {

292:     for (uint256 gidx = 0; gidx < inputParams.groups.length; gidx++) {

341:     for (uint256 i = 0; i < inputParams.collateralTokenIds.length; i++) {

402:     for (vars.i = 0; vars.i < inputParams.nftTokenIds.length; vars.i++) {

498:     for (uint256 i = 0; i < inputParams.amounts.length; i++) {

532:     for (uint256 i = 0; i < inputParams.amounts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ValidateLogic.sol)

```solidity
File: src/libraries/logic/VaultLogic.sol

265:     for (uint256 i = 0; i < groupIds.length; i++) {

291:     for (uint256 i = 0; i < groupIds.length; i++) {

319:     for (uint256 i = 0; i < groupIds.length; i++) {

349:     for (uint256 i = 0; i < groupIds.length; i++) {

502:     for (uint256 i = 0; i < amounts.length; i++) {

510:     for (uint256 i = 0; i < amounts.length; i++) {

568:     for (uint256 i = 0; i < tokenIds.length; i++) {

583:     for (uint256 i = 0; i < tokenIds.length; i++) {

598:     for (uint256 i = 0; i < tokenIds.length; i++) {

615:     for (uint256 i = 0; i < tokenIds.length; i++) {

631:     for (uint256 i = 0; i < tokenIds.length; i++) {

653:     for (uint256 i = 0; i < tokenIds.length; i++) {

670:     for (uint256 i = 0; i < tokenIds.length; i++) {

687:     for (uint256 i = 0; i < tokenIds.length; i++) {

708:     for (uint256 i = 0; i < tokenIds.length; i++) {

730:     for (uint256 i = 0; i < tokenIds.length; i++) {

740:     for (uint256 i = 0; i < tokenIds.length; i++) {

748:     for (uint256 i = 0; i < tokenIds.length; i++) {

764:     for (uint256 gidx = 0; gidx < assetGroupIds.length; gidx++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/yield/YieldStakingBase.sol

197:     for (uint i = 0; i < nfts.length; i++) {

295:     for (uint i = 0; i < nfts.length; i++) {

372:     for (uint i = 0; i < nfts.length; i++) {

534:     for (uint i = 0; i < nfts.length; i++) {

577:     for (uint i = 0; i < nfts.length; i++) {

603:     for (uint i = 0; i < nfts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

65:     for (uint i = 0; i < nfts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="GAS-6"></a>[GAS-6] For Operations that will not overflow, you could use unchecked

*Instances (609)*:
```solidity
File: src/ACLManager.sol

4: import {AccessControlUpgradeable} from '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';

5: import {IACLManager} from './interfaces/IACLManager.sol';

6: import {Errors} from './libraries/helpers/Errors.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/ACLManager.sol)

```solidity
File: src/PoolManager.sol

4: import {IAddressProvider} from 'src/interfaces/IAddressProvider.sol';

5: import {IACLManager} from 'src/interfaces/IACLManager.sol';

7: import {Constants} from 'src/libraries/helpers/Constants.sol';

8: import {Errors} from 'src/libraries/helpers/Errors.sol';

9: import {StorageSlot} from 'src/libraries/logic/StorageSlot.sol';

10: import {DataTypes} from 'src/libraries/types/DataTypes.sol';

12: import {Base} from 'src/base/Base.sol';

13: import {Proxy} from 'src/base/Proxy.sol';

59:     require(msgDataLength >= (4 + 4 + 20), Errors.PROXY_MSGDATA_TOO_SHORT);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PoolManager.sol)

```solidity
File: src/PriceOracle.sol

4: import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

6: import {AggregatorV2V3Interface} from '@chainlink/contracts/src/v0.8/interfaces/AggregatorV2V3Interface.sol';

7: import {IBendNFTOracle} from './interfaces/IBendNFTOracle.sol';

9: import {IAddressProvider} from './interfaces/IAddressProvider.sol';

10: import {IACLManager} from './interfaces/IACLManager.sol';

11: import {IPriceOracle} from './interfaces/IPriceOracle.sol';

12: import {Constants} from './libraries/helpers/Constants.sol';

13: import {Errors} from './libraries/helpers/Errors.sol';

14: import {Events} from './libraries/helpers/Events.sol';

78:     for (uint256 i = 0; i < assets.length; i++) {

88:     for (uint256 i = 0; i < assets.length; i++) {

142:     uint256 nftPriceInBase = (nftPriceInNftBase * nftBaseCurrencyPriceInBase) / NFT_BASE_CURRENCY_UNIT;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/base/Base.sol

4: import {Pausable} from '@openzeppelin/contracts/security/Pausable.sol';

5: import {ERC721Holder} from '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';

7: import {Constants} from 'src/libraries/helpers/Constants.sol';

8: import {Events} from 'src/libraries/helpers/Events.sol';

9: import {Errors} from 'src/libraries/helpers/Errors.sol';

11: import {Storage} from 'src/base/Storage.sol';

12: import {Proxy} from 'src/base/Proxy.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Base.sol)

```solidity
File: src/base/BaseModule.sol

4: import {Base} from './Base.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/BaseModule.sol)

```solidity
File: src/base/Proxy.sol

24:         switch mload(0) // numTopics

48:         mstore(0, 0xe9c4a3ac00000000000000000000000000000000000000000000000000000000) // dispatch() selector

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Proxy.sol)

```solidity
File: src/base/Storage.sol

4: import {StorageSlot} from 'src/libraries/logic/StorageSlot.sol';

5: import {DataTypes} from 'src/libraries/types/DataTypes.sol';

12:   mapping(uint => address) moduleLookup; // moduleId => module implementation

13:   mapping(uint => address) proxyLookup; // moduleId => proxy address (only for single-proxy modules)

16:     uint32 moduleId; // 0 = un-trusted

17:     address moduleImpl; // only non-zero for external single-proxy modules

20:   mapping(address => TrustedSenderInfo) trustedSenders; // sender address => moduleId (0 = un-trusted)

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Storage.sol)

```solidity
File: src/libraries/helpers/KVSortUtils.sol

25:       for (uint256 i = length / 2; i-- > 0; ) {

30:       while (--length != 0) {

47:         uint256 childIdx = (emptyIdx << 1) + 1;

53:         uint256 otherChildIdx = childIdx + 1;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/helpers/KVSortUtils.sol)

```solidity
File: src/libraries/logic/BorrowLogic.sol

4: import {IAddressProvider} from '../../interfaces/IAddressProvider.sol';

6: import {Constants} from '../helpers/Constants.sol';

7: import {Errors} from '../helpers/Errors.sol';

8: import {Events} from '../helpers/Events.sol';

10: import {PercentageMath} from '../math/PercentageMath.sol';

12: import {InputTypes} from '../types/InputTypes.sol';

13: import {DataTypes} from '../types/DataTypes.sol';

14: import {StorageSlot} from './StorageSlot.sol';

16: import {VaultLogic} from './VaultLogic.sol';

17: import {InterestLogic} from './InterestLogic.sol';

18: import {ValidateLogic} from './ValidateLogic.sol';

41:     for (uint256 gidx = 0; gidx < params.groups.length; gidx++) {

45:       totalBorrowAmount += params.amounts[gidx];

82:     for (uint256 gidx = 0; gidx < params.groups.length; gidx++) {

94:       totalRepayAmount += params.amounts[gidx];

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/BorrowLogic.sol)

```solidity
File: src/libraries/logic/ConfigureLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {IERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';

6: import {IERC20MetadataUpgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol';

7: import {SafeCastUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol';

9: import {IInterestRateModel} from '../../interfaces/IInterestRateModel.sol';

11: import {MathUtils} from '..//math/MathUtils.sol';

12: import {WadRayMath} from '../math/WadRayMath.sol';

13: import {PercentageMath} from '../math/PercentageMath.sol';

14: import {Errors} from '../helpers/Errors.sol';

15: import {Constants} from '../helpers/Constants.sol';

16: import {Events} from '../helpers/Events.sol';

18: import {DataTypes} from '../types/DataTypes.sol';

19: import {InputTypes} from '../types/InputTypes.sol';

21: import {StorageSlot} from './StorageSlot.sol';

22: import {InterestLogic} from './InterestLogic.sol';

23: import {VaultLogic} from './VaultLogic.sol';

24: import {PoolLogic} from './PoolLogic.sol';

42:     ps.nextPoolId += 1;

122:     for (uint256 i = 0; i < allAssets.length; i++) {

158:       for (uint256 i = 0; i < allAssets.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ConfigureLogic.sol)

```solidity
File: src/libraries/logic/FlashLoanLogic.sol

4: import {IFlashLoanReceiver} from '../../interfaces/IFlashLoanReceiver.sol';

6: import {Constants} from '../helpers/Constants.sol';

7: import {Errors} from '../helpers/Errors.sol';

8: import {Events} from '../helpers/Events.sol';

10: import {PercentageMath} from '../math/PercentageMath.sol';

12: import {InputTypes} from '../types/InputTypes.sol';

13: import {DataTypes} from '../types/DataTypes.sol';

14: import {StorageSlot} from './StorageSlot.sol';

16: import {VaultLogic} from './VaultLogic.sol';

17: import {ValidateLogic} from './ValidateLogic.sol';

30:     for (i = 0; i < inputParams.assets.length; i++) {

72:     for (i = 0; i < inputParams.nftTokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/FlashLoanLogic.sol)

```solidity
File: src/libraries/logic/GenericLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

6: import {IPriceOracleGetter} from '../../interfaces/IPriceOracleGetter.sol';

8: import {PercentageMath} from '../math/PercentageMath.sol';

9: import {WadRayMath} from '../math/WadRayMath.sol';

10: import {DataTypes} from '../types/DataTypes.sol';

11: import {ResultTypes} from '../types/ResultTypes.sol';

12: import {Constants} from '../helpers/Constants.sol';

13: import {Errors} from '../helpers/Errors.sol';

15: import {VaultLogic} from './VaultLogic.sol';

16: import {InterestLogic} from './InterestLogic.sol';

89:     for (vars.assetIndex = 0; vars.assetIndex < vars.userSuppliedAssets.length; vars.assetIndex++) {

116:         result.totalCollateralInBaseCurrency += vars.userBalanceInBaseCurrency;

119:           result.inputCollateralInBaseCurrency += vars.userBalanceInBaseCurrency;

122:         result.allGroupsCollateralInBaseCurrency[currentAssetData.classGroup] += vars.userBalanceInBaseCurrency;

125:           result.avgLtv += vars.userBalanceInBaseCurrency * currentAssetData.collateralFactor;

127:           result.allGroupsAvgLtv[currentAssetData.classGroup] +=

128:             vars.userBalanceInBaseCurrency *

132:         result.avgLiquidationThreshold += vars.userBalanceInBaseCurrency * currentAssetData.liquidationThreshold;

134:         result.allGroupsAvgLiquidationThreshold[currentAssetData.classGroup] +=

135:           vars.userBalanceInBaseCurrency *

142:     for (vars.assetIndex = 0; vars.assetIndex < vars.userBorrowedAssets.length; vars.assetIndex++) {

157:       for (vars.groupIndex = 0; vars.groupIndex < vars.assetGroupIds.length; vars.groupIndex++) {

168:         vars.userAssetDebtInBaseCurrency += vars.userGroupDebtInBaseCurrency;

170:         result.allGroupsDebtInBaseCurrency[vars.currentGroupId] += vars.userGroupDebtInBaseCurrency;

173:       result.totalDebtInBaseCurrency += vars.userAssetDebtInBaseCurrency;

182:       result.avgLtv = result.avgLtv / result.totalCollateralInBaseCurrency;

183:       result.avgLiquidationThreshold = result.avgLiquidationThreshold / result.totalCollateralInBaseCurrency;

190:     for (vars.groupIndex = 0; vars.groupIndex < Constants.MAX_NUMBER_OF_GROUP; vars.groupIndex++) {

193:           result.allGroupsAvgLtv[vars.groupIndex] /

197:           result.allGroupsAvgLiquidationThreshold[vars.groupIndex] /

283:       (vars.thresholdPrice * (10 ** debtAssetData.underlyingDecimals)) /

288:         PercentageMath.PERCENTAGE_FACTOR - nftAssetData.liquidationBonus

291:         (vars.liquidatePrice * (10 ** debtAssetData.underlyingDecimals)) /

330:       (vars.minBidFineInBaseCurrency * (10 ** debtAssetData.underlyingDecimals)) /

373:     availableBorrowsInBaseCurrency = availableBorrowsInBaseCurrency - totalDebtInBaseCurrency;

391:       userTotalDebt = assetPrice * userTotalDebt;

394:     return userTotalDebt / (10 ** assetData.underlyingDecimals);

410:       userTotalBalance = assetPrice * userTotalBalance;

413:     return userTotalBalance / (10 ** assetData.underlyingDecimals);

423:       userTotalBalance = assetPrice * userTotalBalance;

441:       loanDebtAmount = debtAssetPrice * loanDebtAmount;

442:       loanDebtAmount = loanDebtAmount / (10 ** debtAssetData.underlyingDecimals);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/GenericLogic.sol)

```solidity
File: src/libraries/logic/InterestLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {IERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';

6: import {SafeCastUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol';

8: import {IInterestRateModel} from '../../interfaces/IInterestRateModel.sol';

10: import {MathUtils} from '..//math/MathUtils.sol';

11: import {WadRayMath} from '../math/WadRayMath.sol';

12: import {PercentageMath} from '../math/PercentageMath.sol';

14: import {Constants} from '../helpers/Constants.sol';

15: import {Errors} from '../helpers/Errors.sol';

16: import {Events} from '../helpers/Events.sol';

17: import {DataTypes} from '../types/DataTypes.sol';

18: import {InputTypes} from '../types/InputTypes.sol';

94:     DataTypes.PoolData storage /*poolData*/,

109:     for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {

152:     for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {

155:       vars.loopGroupScaledDebt = loopGroupData.totalScaledCrossBorrow + loopGroupData.totalScaledIsolateBorrow;

159:       vars.totalAssetDebt += vars.loopGroupDebt;

164:       assetData.availableLiquidity +

165:       liquidityAdded -

166:       liquidityTaken +

173:     for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {

185:         vars.nextAssetBorrowRate += vars.nextGroupBorrowRate.rayMul(vars.allGroupDebtList[vars.i]).rayDiv(

202:       PercentageMath.PERCENTAGE_FACTOR - assetData.feeFactor

237:     vars.totalScaledBorrow = groupData.totalScaledCrossBorrow + groupData.totalScaledIsolateBorrow;

246:     vars.totalDebtAccrued = vars.currTotalBorrow - vars.prevTotalBorrow;

251:       assetData.accruedFee += vars.amountToMint.rayDiv(assetData.supplyIndex).toUint128();

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/InterestLogic.sol)

```solidity
File: src/libraries/logic/IsolateLogic.sol

4: import {IAddressProvider} from '../../interfaces/IAddressProvider.sol';

6: import {Constants} from '../helpers/Constants.sol';

7: import {Errors} from '../helpers/Errors.sol';

8: import {Events} from '../helpers/Events.sol';

10: import {PercentageMath} from '../math/PercentageMath.sol';

11: import {WadRayMath} from '../math/WadRayMath.sol';

12: import {InputTypes} from '../types/InputTypes.sol';

13: import {DataTypes} from '../types/DataTypes.sol';

14: import {StorageSlot} from './StorageSlot.sol';

16: import {VaultLogic} from './VaultLogic.sol';

17: import {GenericLogic} from './GenericLogic.sol';

18: import {InterestLogic} from './InterestLogic.sol';

19: import {ValidateLogic} from './ValidateLogic.sol';

53:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

77:         loanData.scaledAmount += vars.amountScaled;

82:       vars.totalBorrowAmount += params.amounts[vars.nidx];

129:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

148:         loanData.scaledAmount -= vars.scaledRepayAmount;

153:       vars.totalRepayAmount += params.amounts[vars.nidx];

205:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

242:         vars.auctionEndTimestamp = loanData.bidStartTimestamp + nftAssetData.auctionDuration;

251:           params.amounts[vars.nidx] >= (loanData.bidAmount + vars.minBidDelta),

265:       vars.totalBidAmount += params.amounts[vars.nidx];

314:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

320:       vars.auctionEndTimestamp = loanData.bidStartTimestamp + nftAssetData.auctionDuration;

357:       loanData.scaledAmount -= vars.amountScaled;

361:       vars.totalRedeemAmount += vars.redeemAmounts[vars.nidx];

413:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

423:       vars.auctionEndTimestamp = loanData.bidStartTimestamp + nftAssetData.auctionDuration;

431:         vars.extraBorrowAmounts[vars.nidx] = vars.borrowAmount - loanData.bidAmount;

436:         vars.remainBidAmounts[vars.nidx] = loanData.bidAmount - vars.borrowAmount;

447:       vars.totalBorrowAmount += vars.borrowAmount;

448:       vars.totalBidAmount += loanData.bidAmount;

449:       vars.totalExtraAmount += vars.extraBorrowAmounts[vars.nidx];

456:       (vars.totalBidAmount + vars.totalExtraAmount) >= vars.totalBorrowAmount,

461:     InterestLogic.updateInterestRates(poolData, debtAssetData, (vars.totalBorrowAmount + vars.totalExtraAmount), 0);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/IsolateLogic.sol)

```solidity
File: src/libraries/logic/LiquidationLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

6: import {IAddressProvider} from '../../interfaces/IAddressProvider.sol';

7: import {IPriceOracleGetter} from '../../interfaces/IPriceOracleGetter.sol';

9: import {Constants} from '../helpers/Constants.sol';

10: import {Errors} from '../helpers/Errors.sol';

11: import {Events} from '../helpers/Events.sol';

13: import {InputTypes} from '../types/InputTypes.sol';

14: import {DataTypes} from '../types/DataTypes.sol';

15: import {ResultTypes} from '../types/ResultTypes.sol';

17: import {WadRayMath} from '../math/WadRayMath.sol';

18: import {PercentageMath} from '../math/PercentageMath.sol';

19: import {KVSortUtils} from '../helpers/KVSortUtils.sol';

21: import {StorageSlot} from './StorageSlot.sol';

22: import {VaultLogic} from './VaultLogic.sol';

23: import {InterestLogic} from './InterestLogic.sol';

24: import {GenericLogic} from './GenericLogic.sol';

25: import {ValidateLogic} from './ValidateLogic.sol';

304:     DataTypes.PoolData storage /*poolData*/,

312:     for (uint256 i = 0; i < groupRateList.length; i++) {

321:     for (uint256 i = 0; i < groupRateList.length; i++) {

322:       uint256 reverseIdx = (groupRateList.length - 1) - i;

340:         remainDebtToLiquidate -= curDebtRepayAmount;

404:     vars.collateralAssetUnit = 10 ** collateralAssetData.underlyingDecimals;

405:     vars.debtAssetUnit = 10 ** debtAssetData.underlyingDecimals;

409:       ((debtToCover * vars.debtAssetPrice * vars.collateralAssetUnit)) /

410:       (vars.debtAssetUnit * vars.collateralPrice);

413:       PercentageMath.PERCENTAGE_FACTOR + collateralAssetData.liquidationBonus

418:       vars.debtAmountNeeded = ((vars.collateralAmount * vars.collateralPrice * vars.debtAssetUnit) /

419:         (vars.collateralAssetUnit * vars.debtAssetPrice)).percentDiv(

420:           PercentageMath.PERCENTAGE_FACTOR + collateralAssetData.liquidationBonus

490:       PercentageMath.PERCENTAGE_FACTOR - collateralAssetData.liquidationBonus

493:     vars.debtAssetUnit = 10 ** debtAssetData.underlyingDecimals;

498:       (liqVars.userAccountResult.inputCollateralInBaseCurrency * liqVars.userAccountResult.totalDebtInBaseCurrency) /

500:     vars.collateralItemDebtToCover = vars.collateralTotalDebtToCover / liqVars.userCollateralBalance;

509:     vars.collateralTotalValue = vars.collateralLiquidatePrice * params.collateralTokenIds.length;

510:     vars.debtAmountNeeded = (vars.collateralTotalValue * vars.debtAssetUnit) / vars.debtAssetPrice;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/LiquidationLogic.sol)

```solidity
File: src/libraries/logic/PoolLogic.sol

4: import {Constants} from '../helpers/Constants.sol';

5: import {Errors} from '../helpers/Errors.sol';

6: import {Events} from '../helpers/Events.sol';

8: import {InputTypes} from '../types/InputTypes.sol';

9: import {DataTypes} from '../types/DataTypes.sol';

10: import {StorageSlot} from './StorageSlot.sol';

11: import {WadRayMath} from '../math/WadRayMath.sol';

13: import {IAddressProvider} from '../../interfaces/IAddressProvider.sol';

14: import {IACLManager} from '../../interfaces/IACLManager.sol';

15: import {IWETH} from '../../interfaces/IWETH.sol';

16: import {IDelegateRegistryV2} from 'src/interfaces/IDelegateRegistryV2.sol';

18: import {VaultLogic} from './VaultLogic.sol';

19: import {InterestLogic} from './InterestLogic.sol';

20: import {ValidateLogic} from './ValidateLogic.sol';

46:     for (uint256 i = 0; i < assets.length; i++) {

85:     for (uint256 i = 0; i < params.tokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/PoolLogic.sol)

```solidity
File: src/libraries/logic/StorageSlot.sol

4: import {DataTypes} from '../types/DataTypes.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/StorageSlot.sol)

```solidity
File: src/libraries/logic/SupplyLogic.sol

4: import {IAddressProvider} from '../../interfaces/IAddressProvider.sol';

6: import {Constants} from '../helpers/Constants.sol';

7: import {Errors} from '../helpers/Errors.sol';

8: import {Events} from '../helpers/Events.sol';

10: import {InputTypes} from '../types/InputTypes.sol';

11: import {DataTypes} from '../types/DataTypes.sol';

12: import {StorageSlot} from './StorageSlot.sol';

14: import {VaultLogic} from './VaultLogic.sol';

15: import {InterestLogic} from './InterestLogic.sol';

16: import {ValidateLogic} from './ValidateLogic.sol';

131:       for (uint256 i = 0; i < params.tokenIds.length; i++) {

168:     for (uint256 i = 0; i < params.tokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/SupplyLogic.sol)

```solidity
File: src/libraries/logic/ValidateLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {IERC721Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';

6: import {IPriceOracleGetter} from '../../interfaces/IPriceOracleGetter.sol';

8: import {Constants} from '../helpers/Constants.sol';

9: import {Errors} from '../helpers/Errors.sol';

11: import {WadRayMath} from '../math/WadRayMath.sol';

12: import {PercentageMath} from '../math/PercentageMath.sol';

13: import {DataTypes} from '../types/DataTypes.sol';

14: import {ResultTypes} from '../types/ResultTypes.sol';

15: import {InputTypes} from '../types/InputTypes.sol';

17: import {GenericLogic} from './GenericLogic.sol';

18: import {VaultLogic} from './VaultLogic.sol';

51:     for (uint i = 0; i < values.length; i++) {

52:       for (uint j = i + 1; j < values.length; j++) {

59:     for (uint i = 0; i < values.length; i++) {

60:       for (uint j = i + 1; j < values.length; j++) {

94:       uint256 totalSupplyWithFee = (totalScaledSupply + assetData.accruedFee).rayMul(assetData.supplyIndex);

95:       require((inputParams.amount + totalSupplyWithFee) <= assetData.supplyCap, Errors.ASSET_SUPPLY_CAP_EXCEEDED);

134:     for (uint256 i = 0; i < inputParams.tokenIds.length; i++) {

140:       uint256 totalSupply = VaultLogic.erc721GetTotalCrossSupply(assetData) +

142:       require((totalSupply + inputParams.tokenIds.length) <= assetData.supplyCap, Errors.ASSET_SUPPLY_CAP_EXCEEDED);

166:     for (uint256 i = 0; i < inputParams.tokenIds.length; i++) {

208:         VaultLogic.erc20GetTotalCrossBorrowInAsset(assetData) +

211:       for (vars.gidx = 0; vars.gidx < inputParams.groups.length; vars.gidx++) {

212:         vars.totalNewBorrowAmount += inputParams.amounts[vars.gidx];

216:         (vars.totalAssetBorrowAmount + vars.totalNewBorrowAmount) <= assetData.borrowCap,

243:     for (vars.gidx = 0; vars.gidx < inputParams.groups.length; vars.gidx++) {

255:         (vars.assetPrice * inputParams.amounts[vars.gidx]) /

256:         (10 ** assetData.underlyingDecimals);

262:       ] + vars.amountInBaseCurrency).percentDiv(userAccountResult.allGroupsAvgLtv[inputParams.groups[vars.gidx]]);

270:       vars.totalNewBorrowAmount += inputParams.amounts[vars.gidx];

292:     for (uint256 gidx = 0; gidx < inputParams.groups.length; gidx++) {

341:     for (uint256 i = 0; i < inputParams.collateralTokenIds.length; i++) {

402:     for (vars.i = 0; vars.i < inputParams.nftTokenIds.length; vars.i++) {

404:       vars.totalNewBorrowAmount += inputParams.amounts[vars.i];

422:         VaultLogic.erc20GetTotalCrossBorrowInAsset(debtAssetData) +

426:         (vars.totalAssetBorrowAmount + vars.totalNewBorrowAmount) <= debtAssetData.borrowCap,

465:     uint256 amountInBaseCurrency = (assetPrice * inputParams.amounts[nftIndex]) /

466:       (10 ** debtAssetData.underlyingDecimals);

469:     uint256 collateralNeededInBaseCurrency = (nftLoanResult.totalDebtInBaseCurrency + amountInBaseCurrency).percentDiv(

498:     for (uint256 i = 0; i < inputParams.amounts.length; i++) {

532:     for (uint256 i = 0; i < inputParams.amounts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ValidateLogic.sol)

```solidity
File: src/libraries/logic/VaultLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {IERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';

6: import {SafeERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol';

7: import {IERC721Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';

9: import {Constants} from '../helpers/Constants.sol';

10: import {Errors} from '../helpers/Errors.sol';

11: import {InputTypes} from '../types/InputTypes.sol';

12: import {DataTypes} from '../types/DataTypes.sol';

13: import {StorageSlot} from './StorageSlot.sol';

14: import {WadRayMath} from '../math/WadRayMath.sol';

16: import {IWETH} from '../../interfaces/IWETH.sol';

215:     assetData.totalScaledCrossSupply += amountScaled;

216:     assetData.userScaledCrossSupply[account] += amountScaled;

226:     assetData.totalScaledCrossSupply -= amountScaled;

227:     assetData.userScaledCrossSupply[account] -= amountScaled;

242:     assetData.userScaledCrossSupply[from] -= amountScaled;

243:     assetData.userScaledCrossSupply[to] += amountScaled;

265:     for (uint256 i = 0; i < groupIds.length; i++) {

267:       totalBorrow += groupData.totalScaledCrossBorrow.rayMul(groupData.borrowIndex);

291:     for (uint256 i = 0; i < groupIds.length; i++) {

293:       totalBorrow += groupData.totalScaledIsolateBorrow.rayMul(groupData.borrowIndex);

312:     DataTypes.PoolData storage /*poolData*/,

319:     for (uint256 i = 0; i < groupIds.length; i++) {

321:       totalScaledBorrow += groupData.userScaledCrossBorrow[account];

342:     DataTypes.PoolData storage /*poolData*/,

349:     for (uint256 i = 0; i < groupIds.length; i++) {

351:       totalBorrow += groupData.userScaledCrossBorrow[account].rayMul(groupData.borrowIndex);

379:     groupData.totalScaledCrossBorrow += amountScaled;

380:     groupData.userScaledCrossBorrow[account] += amountScaled;

387:     groupData.totalScaledIsolateBorrow += amountScaled;

388:     groupData.userScaledIsolateBorrow[account] += amountScaled;

396:     groupData.totalScaledIsolateBorrow += amountScaled;

397:     groupData.userScaledIsolateBorrow[account] += amountScaled;

407:     groupData.totalScaledCrossBorrow -= amountScaled;

408:     groupData.userScaledCrossBorrow[account] -= amountScaled;

415:     groupData.totalScaledIsolateBorrow -= amountScaled;

416:     groupData.userScaledIsolateBorrow[account] -= amountScaled;

424:     groupData.totalScaledIsolateBorrow -= amountScaled;

425:     groupData.userScaledIsolateBorrow[account] -= amountScaled;

432:     assetData.availableLiquidity += amount;

437:     require(poolSizeAfter == (poolSizeBefore + amount), Errors.INVALID_TRANSFER_AMOUNT);

448:     assetData.availableLiquidity -= amount;

453:     require(poolSizeBefore == (poolSizeAfter + amount), Errors.INVALID_TRANSFER_AMOUNT);

465:     require(userSizeAfter == (userSizeBefore + amount), Errors.INVALID_TRANSFER_AMOUNT);

472:     assetData.totalBidAmout += amount;

477:     require(poolSizeAfter == (poolSizeBefore + amount), Errors.INVALID_TRANSFER_AMOUNT);

488:     assetData.totalBidAmout -= amount;

493:     require(poolSizeBefore == (poolSizeAfter + amount), Errors.INVALID_TRANSFER_AMOUNT);

497:     assetData.totalBidAmout -= amount;

498:     assetData.availableLiquidity += amount;

502:     for (uint256 i = 0; i < amounts.length; i++) {

510:     for (uint256 i = 0; i < amounts.length; i++) {

568:     for (uint256 i = 0; i < tokenIds.length; i++) {

574:     assetData.totalScaledCrossSupply += tokenIds.length;

575:     assetData.userScaledCrossSupply[user] += tokenIds.length;

583:     for (uint256 i = 0; i < tokenIds.length; i++) {

589:     assetData.totalScaledIsolateSupply += tokenIds.length;

590:     assetData.userScaledIsolateSupply[user] += tokenIds.length;

598:     for (uint256 i = 0; i < tokenIds.length; i++) {

606:     assetData.totalScaledCrossSupply -= tokenIds.length;

607:     assetData.userScaledCrossSupply[user] -= tokenIds.length;

615:     for (uint256 i = 0; i < tokenIds.length; i++) {

623:     assetData.totalScaledIsolateSupply -= tokenIds.length;

624:     assetData.userScaledIsolateSupply[user] -= tokenIds.length;

631:     for (uint256 i = 0; i < tokenIds.length; i++) {

635:       assetData.userScaledIsolateSupply[tokenData.owner] -= 1;

641:     assetData.totalScaledIsolateSupply -= tokenIds.length;

653:     for (uint256 i = 0; i < tokenIds.length; i++) {

660:     assetData.userScaledCrossSupply[from] -= tokenIds.length;

661:     assetData.userScaledCrossSupply[to] += tokenIds.length;

670:     for (uint256 i = 0; i < tokenIds.length; i++) {

678:     assetData.userScaledIsolateSupply[from] -= tokenIds.length;

679:     assetData.userScaledIsolateSupply[to] += tokenIds.length;

687:     for (uint256 i = 0; i < tokenIds.length; i++) {

691:       assetData.userScaledIsolateSupply[tokenData.owner] -= 1;

692:       assetData.userScaledIsolateSupply[to] += 1;

706:     assetData.availableLiquidity += tokenIds.length;

708:     for (uint256 i = 0; i < tokenIds.length; i++) {

714:     require(poolSizeAfter == (poolSizeBefore + tokenIds.length), Errors.INVALID_TRANSFER_AMOUNT);

726:     assetData.availableLiquidity -= tokenIds.length;

730:     for (uint256 i = 0; i < tokenIds.length; i++) {

736:     require(poolSizeBefore == (poolSizeAfter + tokenIds.length), Errors.INVALID_TRANSFER_AMOUNT);

740:     for (uint256 i = 0; i < tokenIds.length; i++) {

748:     for (uint256 i = 0; i < tokenIds.length; i++) {

757:     DataTypes.PoolData storage /*poolData*/,

764:     for (uint256 gidx = 0; gidx < assetGroupIds.length; gidx++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/libraries/logic/YieldLogic.sol

4: import {Constants} from '../helpers/Constants.sol';

5: import {Errors} from '../helpers/Errors.sol';

6: import {Events} from '../helpers/Events.sol';

8: import {PercentageMath} from '../math/PercentageMath.sol';

10: import {InputTypes} from '../types/InputTypes.sol';

11: import {DataTypes} from '../types/DataTypes.sol';

12: import {StorageSlot} from './StorageSlot.sol';

14: import {VaultLogic} from './VaultLogic.sol';

15: import {InterestLogic} from './InterestLogic.sol';

16: import {ValidateLogic} from './ValidateLogic.sol';

56:       (vars.totalBorrow + params.amount) <= vars.totalSupply.percentMul(assetData.yieldCap),

63:       (vars.stakerBorrow + params.amount) <= vars.totalSupply.percentMul(ymData.yieldCap),

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/YieldLogic.sol)

```solidity
File: src/libraries/math/MathUtils.sol

4: import {WadRayMath} from './WadRayMath.sol';

28:     uint256 result = rate * (currentTimestamp - lastUpdateTimestamp);

30:       result = result / SECONDS_PER_YEAR;

33:     return WadRayMath.RAY + result;

66:     uint256 exp = currentTimestamp - lastUpdateTimestamp;

77:       expMinusOne = exp - 1;

79:       expMinusTwo = exp > 2 ? exp - 2 : 0;

81:       basePowerTwo = rate.rayMul(rate) / (SECONDS_PER_YEAR * SECONDS_PER_YEAR);

82:       basePowerThree = basePowerTwo.rayMul(rate) / SECONDS_PER_YEAR;

85:     uint256 secondTerm = exp * expMinusOne * basePowerTwo;

87:       secondTerm /= 2;

89:     uint256 thirdTerm = exp * expMinusOne * expMinusTwo * basePowerThree;

91:       thirdTerm /= 6;

94:     return WadRayMath.RAY + (rate * exp) / SECONDS_PER_YEAR + secondTerm + thirdTerm;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/math/MathUtils.sol)

```solidity
File: src/libraries/math/ShareUtils.sol

4: import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

15:     return assets.mulDiv(totalShares + 1, totalAssets + 1, rounding);

24:     return shares.mulDiv(totalAssets + 1, totalShares + 1, rounding);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/math/ShareUtils.sol)

```solidity
File: src/libraries/types/DataTypes.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

58:     uint8 supplyMode; // 0=cross margin, 1=isolate

69:     uint8 assetType; // See ASSET_TYPE_xxx

70:     uint8 underlyingDecimals; // only for ERC20

96:     uint256 totalScaledCrossSupply; // total supplied balance in cross margin mode

97:     uint256 totalScaledIsolateSupply; // total supplied balance in isolate mode, only for ERC721

100:     mapping(address => uint256) userScaledCrossSupply; // user supplied balance in cross margin mode

101:     mapping(address => uint256) userScaledIsolateSupply; // user supplied balance in isolate mode, only for ERC721

102:     mapping(uint256 => ERC721TokenData) erc721TokenData; // token -> data, only for ERC721

107:     uint256 accruedFee; // as treasury supplied balance in cross mode

130:     address wrappedNativeToken; // WETH

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/types/DataTypes.sol)

```solidity
File: src/modules/BVault.sol

4: import {BaseModule} from '../base/BaseModule.sol';

6: import {Constants} from '../libraries/helpers/Constants.sol';

7: import {Errors} from '../libraries/helpers/Errors.sol';

8: import {DataTypes} from '../libraries/types/DataTypes.sol';

9: import {InputTypes} from '../libraries/types/InputTypes.sol';

11: import {StorageSlot} from '../libraries/logic/StorageSlot.sol';

12: import {VaultLogic} from '../libraries/logic/VaultLogic.sol';

13: import {SupplyLogic} from '../libraries/logic/SupplyLogic.sol';

14: import {PoolLogic} from '../libraries/logic/PoolLogic.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/modules/BVault.sol)

```solidity
File: src/modules/Configurator.sol

4: import {BaseModule} from 'src/base/BaseModule.sol';

6: import {Constants} from 'src/libraries/helpers/Constants.sol';

7: import {DataTypes} from '../libraries/types/DataTypes.sol';

9: import {StorageSlot} from 'src/libraries/logic/StorageSlot.sol';

10: import {ConfigureLogic} from 'src/libraries/logic/ConfigureLogic.sol';

11: import {PoolLogic} from 'src/libraries/logic/PoolLogic.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/modules/Configurator.sol)

```solidity
File: src/modules/CrossLending.sol

4: import {BaseModule} from '../base/BaseModule.sol';

6: import {Constants} from '../libraries/helpers/Constants.sol';

7: import {Errors} from '../libraries/helpers/Errors.sol';

8: import {DataTypes} from '../libraries/types/DataTypes.sol';

9: import {InputTypes} from '../libraries/types/InputTypes.sol';

11: import {StorageSlot} from '../libraries/logic/StorageSlot.sol';

12: import {VaultLogic} from '../libraries/logic/VaultLogic.sol';

13: import {BorrowLogic} from '../libraries/logic/BorrowLogic.sol';

14: import {LiquidationLogic} from '../libraries/logic/LiquidationLogic.sol';

15: import {QueryLogic} from '../libraries/logic/QueryLogic.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/modules/CrossLending.sol)

```solidity
File: src/modules/CrossLiquidation.sol

4: import {BaseModule} from '../base/BaseModule.sol';

6: import {Constants} from '../libraries/helpers/Constants.sol';

7: import {Errors} from '../libraries/helpers/Errors.sol';

8: import {DataTypes} from '../libraries/types/DataTypes.sol';

9: import {InputTypes} from '../libraries/types/InputTypes.sol';

11: import {StorageSlot} from '../libraries/logic/StorageSlot.sol';

12: import {VaultLogic} from '../libraries/logic/VaultLogic.sol';

13: import {BorrowLogic} from '../libraries/logic/BorrowLogic.sol';

14: import {LiquidationLogic} from '../libraries/logic/LiquidationLogic.sol';

15: import {QueryLogic} from '../libraries/logic/QueryLogic.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/modules/CrossLiquidation.sol)

```solidity
File: src/modules/FlashLoan.sol

4: import {BaseModule} from '../base/BaseModule.sol';

6: import {Constants} from '../libraries/helpers/Constants.sol';

7: import {Errors} from '../libraries/helpers/Errors.sol';

8: import {DataTypes} from '../libraries/types/DataTypes.sol';

9: import {InputTypes} from '../libraries/types/InputTypes.sol';

11: import {StorageSlot} from '../libraries/logic/StorageSlot.sol';

12: import {VaultLogic} from '../libraries/logic/VaultLogic.sol';

13: import {FlashLoanLogic} from '../libraries/logic/FlashLoanLogic.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/modules/FlashLoan.sol)

```solidity
File: src/modules/IsolateLending.sol

4: import {BaseModule} from '../base/BaseModule.sol';

6: import {Constants} from '../libraries/helpers/Constants.sol';

7: import {Errors} from '../libraries/helpers/Errors.sol';

8: import {DataTypes} from '../libraries/types/DataTypes.sol';

9: import {InputTypes} from '../libraries/types/InputTypes.sol';

11: import {StorageSlot} from '../libraries/logic/StorageSlot.sol';

12: import {VaultLogic} from '../libraries/logic/VaultLogic.sol';

13: import {IsolateLogic} from '../libraries/logic/IsolateLogic.sol';

14: import {QueryLogic} from '../libraries/logic/QueryLogic.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/modules/IsolateLending.sol)

```solidity
File: src/modules/IsolateLiquidation.sol

4: import {BaseModule} from '../base/BaseModule.sol';

6: import {Constants} from '../libraries/helpers/Constants.sol';

7: import {Errors} from '../libraries/helpers/Errors.sol';

8: import {DataTypes} from '../libraries/types/DataTypes.sol';

9: import {InputTypes} from '../libraries/types/InputTypes.sol';

11: import {StorageSlot} from '../libraries/logic/StorageSlot.sol';

12: import {VaultLogic} from '../libraries/logic/VaultLogic.sol';

13: import {IsolateLogic} from '../libraries/logic/IsolateLogic.sol';

14: import {QueryLogic} from '../libraries/logic/QueryLogic.sol';

53:     uint256[] calldata /*amounts*/

80:     uint256[] calldata /*amounts*/,

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/modules/IsolateLiquidation.sol)

```solidity
File: src/modules/Yield.sol

4: import {IYield} from 'src/interfaces/IYield.sol';

6: import {Constants} from '../libraries/helpers/Constants.sol';

7: import {Errors} from '../libraries/helpers/Errors.sol';

8: import {DataTypes} from '../libraries/types/DataTypes.sol';

9: import {InputTypes} from '../libraries/types/InputTypes.sol';

11: import {StorageSlot} from '../libraries/logic/StorageSlot.sol';

12: import {VaultLogic} from '../libraries/logic/VaultLogic.sol';

13: import {YieldLogic} from '../libraries/logic/YieldLogic.sol';

14: import {QueryLogic} from '../libraries/logic/QueryLogic.sol';

16: import {BaseModule} from '../base/BaseModule.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/modules/Yield.sol)

```solidity
File: src/yield/YieldAccount.sol

4: import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

5: import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';

6: import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

7: import {Address} from '@openzeppelin/contracts/utils/Address.sol';

8: import {Initializable} from '@openzeppelin/contracts/proxy/utils/Initializable.sol';

10: import {Errors} from 'src/libraries/helpers/Errors.sol';

12: import {IYieldRegistry} from 'src/interfaces/IYieldRegistry.sol';

13: import {IYieldAccount} from 'src/interfaces/IYieldAccount.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldAccount.sol)

```solidity
File: src/yield/YieldRegistry.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {ClonesUpgradeable} from '@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol';

6: import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

7: import {PausableUpgradeable} from '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';

8: import {ReentrancyGuardUpgradeable} from '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';

10: import {IAddressProvider} from 'src/interfaces/IAddressProvider.sol';

11: import {IACLManager} from 'src/interfaces/IACLManager.sol';

12: import {IYieldRegistry} from 'src/interfaces/IYieldRegistry.sol';

14: import {Constants} from 'src/libraries/helpers/Constants.sol';

15: import {Errors} from 'src/libraries/helpers/Errors.sol';

17: import {YieldAccount} from './YieldAccount.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldRegistry.sol)

```solidity
File: src/yield/YieldStakingBase.sol

4: import {IERC20Metadata} from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';

5: import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

7: import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

8: import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

9: import {PausableUpgradeable} from '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';

10: import {ReentrancyGuardUpgradeable} from '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';

12: import {IAddressProvider} from 'src/interfaces/IAddressProvider.sol';

13: import {IACLManager} from 'src/interfaces/IACLManager.sol';

14: import {IPoolManager} from 'src/interfaces/IPoolManager.sol';

15: import {IYield} from 'src/interfaces/IYield.sol';

16: import {IPriceOracleGetter} from 'src/interfaces/IPriceOracleGetter.sol';

17: import {IYieldAccount} from 'src/interfaces/IYieldAccount.sol';

18: import {IYieldRegistry} from 'src/interfaces/IYieldRegistry.sol';

20: import {Constants} from 'src/libraries/helpers/Constants.sol';

21: import {Errors} from 'src/libraries/helpers/Errors.sol';

23: import {PercentageMath} from 'src/libraries/math/PercentageMath.sol';

24: import {WadRayMath} from 'src/libraries/math/WadRayMath.sol';

25: import {MathUtils} from 'src/libraries/math/MathUtils.sol';

26: import {ShareUtils} from 'src/libraries/math/ShareUtils.sol';

47:     uint16 leverageFactor; // e.g. 50000 -> 500%

48:     uint16 liquidationThreshold; // e.g. 9000 -> 90%

49:     uint16 maxUnstakeFine; // e.g. 1ether -> 1e18

50:     uint256 unstakeHeathFactor; // 18 decimals, e.g. 1.0 -> 1e18

197:     for (uint i = 0; i < nfts.length; i++) {

235:       vars.totalDebtAmount = convertToDebtAssets(poolId, sd.debtShare) + borrowAmount;

263:     sd.debtShare += vars.debtShare;

264:     sd.yieldShare += vars.yieldShare;

267:     totalDebtShare += vars.debtShare;

268:     accountYieldShares[address(vars.yieldAccout)] += vars.yieldShare;

295:     for (uint i = 0; i < nfts.length; i++) {

336:       totalUnstakeFine += unstakeFine;

341:     accountYieldInWithdraws[address(vars.yieldAccout)] += sd.withdrawAmount;

346:     accountYieldShares[address(vars.yieldAccout)] -= sd.yieldShare;

372:     for (uint i = 0; i < nfts.length; i++) {

407:     vars.nftDebtWithFine = vars.nftDebt + sd.unstakeFine;

411:       vars.remainAmount = vars.claimedYield - vars.nftDebtWithFine;

413:       vars.extraAmount = vars.nftDebtWithFine - vars.claimedYield;

431:     accountYieldInWithdraws[address(vars.yieldAccout)] -= sd.withdrawAmount;

432:     totalDebtShare -= sd.debtShare;

515:       availabeBorrow = availabeBorrow - totalBorrow;

534:     for (uint i = 0; i < nfts.length; i++) {

577:     for (uint i = 0; i < nfts.length; i++) {

603:     for (uint i = 0; i < nfts.length; i++) {

656:     return (underAmount, yieldAmount.mulDiv(yieldPrice, 10 ** getProtocolTokenDecimals()));

677:     return nftPriceInBase.mulDiv(10 ** underlyingAsset.decimals(), underlyingAssetPriceInBase);

691:     return (totalNftValue + totalYieldValue).wadDiv(totalDebtValue);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

4: import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

6: import {IPriceOracleGetter} from 'src/interfaces/IPriceOracleGetter.sol';

7: import {IYieldAccount} from 'src/interfaces/IYieldAccount.sol';

8: import {IYieldRegistry} from 'src/interfaces/IYieldRegistry.sol';

9: import {IWETH} from 'src/interfaces/IWETH.sol';

11: import {IeETH} from './IeETH.sol';

12: import {IWithdrawRequestNFT} from './IWithdrawRequestNFT.sol';

13: import {ILiquidityPool} from './ILiquidityPool.sol';

15: import {Constants} from 'src/libraries/helpers/Constants.sol';

16: import {Errors} from 'src/libraries/helpers/Errors.sol';

18: import {YieldStakingBase} from '../YieldStakingBase.sol';

68:   function protocolDeposit(YieldStakeData storage /*sd*/, uint256 amount) internal virtual override returns (uint256) {

102:     claimedEth = address(yieldAccount).balance - claimedEth;

128:     return eEthPriceInBase.mulDiv(10 ** underlyingAsset.decimals(), ethPriceInBase);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

4: import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

6: import {IPriceOracleGetter} from 'src/interfaces/IPriceOracleGetter.sol';

7: import {IYieldAccount} from 'src/interfaces/IYieldAccount.sol';

8: import {IYieldRegistry} from 'src/interfaces/IYieldRegistry.sol';

10: import {IWETH} from 'src/interfaces/IWETH.sol';

11: import {IStETH} from 'src/interfaces/IStETH.sol';

12: import {IUnstETH} from 'src/interfaces/IUnstETH.sol';

14: import {Constants} from 'src/libraries/helpers/Constants.sol';

15: import {Errors} from 'src/libraries/helpers/Errors.sol';

17: import {YieldStakingBase} from '../YieldStakingBase.sol';

66:   function protocolDeposit(YieldStakeData storage /*sd*/, uint256 amount) internal virtual override returns (uint256) {

100:     claimedEth = address(yieldAccount).balance - claimedEth;

128:     return stETHPriceInBase.mulDiv(10 ** underlyingAsset.decimals(), ethPriceInBase);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

4: import {IERC20Metadata} from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';

5: import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

6: import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

8: import {IPriceOracleGetter} from 'src/interfaces/IPriceOracleGetter.sol';

9: import {IYieldAccount} from 'src/interfaces/IYieldAccount.sol';

10: import {IYieldRegistry} from 'src/interfaces/IYieldRegistry.sol';

12: import {ISavingsDai} from './ISavingsDai.sol';

14: import {Constants} from 'src/libraries/helpers/Constants.sol';

15: import {Errors} from 'src/libraries/helpers/Errors.sol';

17: import {YieldStakingBase} from '../YieldStakingBase.sol';

65:     for (uint i = 0; i < nfts.length; i++) {

78:   function protocolDeposit(YieldStakeData storage /*sd*/, uint256 amount) internal virtual override returns (uint256) {

110:     claimedDai = dai.balanceOf(address(this)) - claimedDai;

129:     return balance - inWithdraw;

140:     return sDaiPriceInBase.mulDiv(10 ** underlyingAsset.decimals(), daiPriceInBase);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="GAS-7"></a>[GAS-7] Avoid contract existence checks by using low level calls
Prior to 0.8.10 the compiler inserted extra code, including `EXTCODESIZE` (**100 gas**), to check for contract existence for external function calls. In more recent solidity versions, the compiler will not insert these checks if the external call has a return value. Similar behavior can be achieved in earlier versions by using low-level calls, since low level calls never check for contract existence

*Instances (20)*:
```solidity
File: src/base/Base.sol

43:     (bool success, bytes memory result) = moduleLookup[moduleId].delegatecall(input);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Base.sol)

```solidity
File: src/libraries/logic/VaultLogic.sol

430:     uint256 poolSizeBefore = IERC20Upgradeable(asset).balanceOf(address(this));

436:     uint256 poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

445:     uint256 poolSizeBefore = IERC20Upgradeable(asset).balanceOf(address(this));

452:     uint poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

460:     uint256 userSizeBefore = IERC20Upgradeable(asset).balanceOf(to);

464:     uint userSizeAfter = IERC20Upgradeable(asset).balanceOf(to);

470:     uint256 poolSizeBefore = IERC20Upgradeable(asset).balanceOf(address(this));

476:     uint256 poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

485:     uint256 poolSizeBefore = IERC20Upgradeable(asset).balanceOf(address(this));

492:     uint poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

704:     uint256 poolSizeBefore = IERC721Upgradeable(asset).balanceOf(address(this));

712:     uint256 poolSizeAfter = IERC721Upgradeable(asset).balanceOf(address(this));

728:     uint256 poolSizeBefore = IERC721Upgradeable(asset).balanceOf(address(this));

734:     uint poolSizeAfter = IERC721Upgradeable(asset).balanceOf(address(this));

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

121:     return eETH.balanceOf(account);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

121:     return stETH.balanceOf(account);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

101:     uint256 claimedDai = dai.balanceOf(address(this));

110:     claimedDai = dai.balanceOf(address(this)) - claimedDai;

133:     return sdai.balanceOf(account);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="GAS-8"></a>[GAS-8] Functions guaranteed to revert when called by normal users can be marked `payable`
If a function modifier such as `onlyOwner` is used, the function will revert if a normal user tries to pay the function. Marking the function as `payable` will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided.

*Instances (22)*:
```solidity
File: src/PoolManager.sol

88:   function _onlyPoolAdmin() internal view {

96:   function emergencyEtherTransfer(address to, uint256 amount) public onlyPoolAdmin {

102:   function emergencyProxyEtherTransfer(address proxyAddr, address to, uint256 amount) public onlyPoolAdmin {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PoolManager.sol)

```solidity
File: src/PriceOracle.sol

43:   function _onlyOracleAdmin() internal view {

94:   function setBendNFTOracle(address bendNFTOracle_) public onlyOracleAdmin {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/yield/YieldAccount.sol

32:   function _onlyManager() internal view {

41:   function safeApprove(address token, address spender, uint256 amount) public override onlyManager {

46:   function safeTransferNativeToken(address to, uint256 amount) public override onlyManager {

52:   function safeTransfer(address token, address to, uint256 amount) public override onlyManager {

58:   function execute(address target, bytes calldata data) public override onlyManager returns (bytes memory result) {

73:   function rescue(address target, bytes calldata data) public override onlyRegistry {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldAccount.sol)

```solidity
File: src/yield/YieldRegistry.sol

43:   function __onlyPoolAdmin() internal view {

72:   function setYieldAccountImplementation(address _implementation) public onlyPoolAdmin {

79:   function addYieldManager(address _manager) public onlyPoolAdmin {

94:   function rescue(address yieldAccount, address target, bytes calldata data) public onlyPoolAdmin {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldRegistry.sol)

```solidity
File: src/yield/YieldStakingBase.sol

90:   function __onlyPoolAdmin() internal view {

94:   function __YieldStakingBase_init(address addressProvider_, address underlyingAsset_) internal onlyInitializing {

113:   function setNftActive(address nft, bool active) public virtual onlyPoolAdmin {

144:   function setBotAdmin(address newAdmin) public virtual onlyPoolAdmin {

153:   function setPause(bool paused) public virtual onlyPoolAdmin {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

138:   function emergencyEtherTransfer(address to, uint256 amount) public onlyPoolAdmin {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

138:   function emergencyEtherTransfer(address to, uint256 amount) public onlyPoolAdmin {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

### <a name="GAS-9"></a>[GAS-9] `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`)
Pre-increments and pre-decrements are cheaper.

For a `uint256 i` variable, the following is true with the Optimizer enabled at 10k:

**Increment:**

- `i += 1` is the most expensive form
- `i++` costs 6 gas less than `i += 1`
- `++i` costs 5 gas less than `i++` (11 gas less than `i += 1`)

**Decrement:**

- `i -= 1` is the most expensive form
- `i--` costs 11 gas less than `i -= 1`
- `--i` costs 5 gas less than `i--` (16 gas less than `i -= 1`)

Note that post-increments (or post-decrements) return the old value before incrementing or decrementing, hence the name *post-increment*:

```solidity
uint i = 1;  
uint j = 2;
require(j == i++, "This will be false as i is incremented after the comparison");
```
  
However, pre-increments (or pre-decrements) return the new value:
  
```solidity
uint i = 1;  
uint j = 2;
require(j == ++i, "This will be true as i is incremented before the comparison");
```

In the pre-increment case, the compiler has to create a temporary variable (when used) for returning `1` instead of `2`.

Consider using pre-increments and pre-decrements where they are relevant (meaning: not where post-increments/decrements logic are relevant).

*Saves 5 gas per instance*

*Instances (67)*:
```solidity
File: src/PriceOracle.sol

78:     for (uint256 i = 0; i < assets.length; i++) {

88:     for (uint256 i = 0; i < assets.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/libraries/helpers/KVSortUtils.sol

25:       for (uint256 i = length / 2; i-- > 0; ) {

30:       while (--length != 0) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/helpers/KVSortUtils.sol)

```solidity
File: src/libraries/logic/BorrowLogic.sol

41:     for (uint256 gidx = 0; gidx < params.groups.length; gidx++) {

82:     for (uint256 gidx = 0; gidx < params.groups.length; gidx++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/BorrowLogic.sol)

```solidity
File: src/libraries/logic/ConfigureLogic.sol

122:     for (uint256 i = 0; i < allAssets.length; i++) {

158:       for (uint256 i = 0; i < allAssets.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ConfigureLogic.sol)

```solidity
File: src/libraries/logic/FlashLoanLogic.sol

30:     for (i = 0; i < inputParams.assets.length; i++) {

72:     for (i = 0; i < inputParams.nftTokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/FlashLoanLogic.sol)

```solidity
File: src/libraries/logic/GenericLogic.sol

89:     for (vars.assetIndex = 0; vars.assetIndex < vars.userSuppliedAssets.length; vars.assetIndex++) {

142:     for (vars.assetIndex = 0; vars.assetIndex < vars.userBorrowedAssets.length; vars.assetIndex++) {

157:       for (vars.groupIndex = 0; vars.groupIndex < vars.assetGroupIds.length; vars.groupIndex++) {

190:     for (vars.groupIndex = 0; vars.groupIndex < Constants.MAX_NUMBER_OF_GROUP; vars.groupIndex++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/GenericLogic.sol)

```solidity
File: src/libraries/logic/InterestLogic.sol

109:     for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {

152:     for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {

173:     for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/InterestLogic.sol)

```solidity
File: src/libraries/logic/IsolateLogic.sol

53:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

129:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

205:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

314:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

413:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/IsolateLogic.sol)

```solidity
File: src/libraries/logic/LiquidationLogic.sol

312:     for (uint256 i = 0; i < groupRateList.length; i++) {

321:     for (uint256 i = 0; i < groupRateList.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/LiquidationLogic.sol)

```solidity
File: src/libraries/logic/PoolLogic.sol

46:     for (uint256 i = 0; i < assets.length; i++) {

85:     for (uint256 i = 0; i < params.tokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/PoolLogic.sol)

```solidity
File: src/libraries/logic/SupplyLogic.sol

131:       for (uint256 i = 0; i < params.tokenIds.length; i++) {

168:     for (uint256 i = 0; i < params.tokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/SupplyLogic.sol)

```solidity
File: src/libraries/logic/ValidateLogic.sol

51:     for (uint i = 0; i < values.length; i++) {

52:       for (uint j = i + 1; j < values.length; j++) {

59:     for (uint i = 0; i < values.length; i++) {

60:       for (uint j = i + 1; j < values.length; j++) {

134:     for (uint256 i = 0; i < inputParams.tokenIds.length; i++) {

166:     for (uint256 i = 0; i < inputParams.tokenIds.length; i++) {

211:       for (vars.gidx = 0; vars.gidx < inputParams.groups.length; vars.gidx++) {

243:     for (vars.gidx = 0; vars.gidx < inputParams.groups.length; vars.gidx++) {

292:     for (uint256 gidx = 0; gidx < inputParams.groups.length; gidx++) {

341:     for (uint256 i = 0; i < inputParams.collateralTokenIds.length; i++) {

402:     for (vars.i = 0; vars.i < inputParams.nftTokenIds.length; vars.i++) {

498:     for (uint256 i = 0; i < inputParams.amounts.length; i++) {

532:     for (uint256 i = 0; i < inputParams.amounts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ValidateLogic.sol)

```solidity
File: src/libraries/logic/VaultLogic.sol

265:     for (uint256 i = 0; i < groupIds.length; i++) {

291:     for (uint256 i = 0; i < groupIds.length; i++) {

319:     for (uint256 i = 0; i < groupIds.length; i++) {

349:     for (uint256 i = 0; i < groupIds.length; i++) {

502:     for (uint256 i = 0; i < amounts.length; i++) {

510:     for (uint256 i = 0; i < amounts.length; i++) {

568:     for (uint256 i = 0; i < tokenIds.length; i++) {

583:     for (uint256 i = 0; i < tokenIds.length; i++) {

598:     for (uint256 i = 0; i < tokenIds.length; i++) {

615:     for (uint256 i = 0; i < tokenIds.length; i++) {

631:     for (uint256 i = 0; i < tokenIds.length; i++) {

653:     for (uint256 i = 0; i < tokenIds.length; i++) {

670:     for (uint256 i = 0; i < tokenIds.length; i++) {

687:     for (uint256 i = 0; i < tokenIds.length; i++) {

708:     for (uint256 i = 0; i < tokenIds.length; i++) {

730:     for (uint256 i = 0; i < tokenIds.length; i++) {

740:     for (uint256 i = 0; i < tokenIds.length; i++) {

748:     for (uint256 i = 0; i < tokenIds.length; i++) {

764:     for (uint256 gidx = 0; gidx < assetGroupIds.length; gidx++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/yield/YieldStakingBase.sol

197:     for (uint i = 0; i < nfts.length; i++) {

295:     for (uint i = 0; i < nfts.length; i++) {

372:     for (uint i = 0; i < nfts.length; i++) {

534:     for (uint i = 0; i < nfts.length; i++) {

577:     for (uint i = 0; i < nfts.length; i++) {

603:     for (uint i = 0; i < nfts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

65:     for (uint i = 0; i < nfts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="GAS-10"></a>[GAS-10] Using `private` rather than `public` for constants, saves gas
If needed, the values can be read from the verified contract source code, or if there are multiple values there can be a single getter function that [returns a tuple](https://github.com/code-423n4/2022-08-frax/blob/90f55a9ce4e25bceed3a74290b854341d8de6afa/src/contracts/FraxlendPair.sol#L156-L178) of the values of all currently-public constants. Saves **3406-3606 gas** in deployment gas due to the compiler not having to create non-payable getter functions for deployment calldata, not having to store the bytes of the value outside of where it's used, and not adding another entry to the method ID table

*Instances (4)*:
```solidity
File: src/ACLManager.sol

13:   bytes32 public constant override POOL_ADMIN_ROLE = keccak256('POOL_ADMIN');

14:   bytes32 public constant override EMERGENCY_ADMIN_ROLE = keccak256('EMERGENCY_ADMIN');

15:   bytes32 public constant override ORACLE_ADMIN_ROLE = keccak256('ORACLE_ADMIN');

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/ACLManager.sol)

```solidity
File: src/PoolManager.sol

17:   string public constant name = 'Bend Protocol V2';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PoolManager.sol)

### <a name="GAS-11"></a>[GAS-11] Use shift right/left instead of division/multiplication if possible
While the `DIV` / `MUL` opcode uses 5 gas, the `SHR` / `SHL` opcode only uses 3 gas. Furthermore, beware that Solidity's division operation also includes a division-by-0 prevention which is bypassed using shifting. Eventually, overflow checks are never performed for shift operations as they are done for arithmetic operations. Instead, the result is always truncated, so the calculation can be unchecked in Solidity version `0.8+`
- Use `>> 1` instead of `/ 2`
- Use `>> 2` instead of `/ 4`
- Use `<< 3` instead of `* 8`
- ...
- Use `>> 5` instead of `/ 2^5 == / 32`
- Use `<< 6` instead of `* 2^6 == * 64`

TL;DR:
- Shifting left by N is like multiplying by 2^N (Each bits to the left is an increased power of 2)
- Shifting right by N is like dividing by 2^N (Each bits to the right is a decreased power of 2)

*Saves around 2 gas + 20 for unchecked per instance*

*Instances (1)*:
```solidity
File: src/libraries/helpers/KVSortUtils.sol

25:       for (uint256 i = length / 2; i-- > 0; ) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/helpers/KVSortUtils.sol)

### <a name="GAS-12"></a>[GAS-12] Splitting require() statements that use && saves gas

*Instances (3)*:
```solidity
File: src/libraries/logic/ConfigureLogic.sol

129:       require((groupData.groupId == 0) && (groupData.rateModel == address(0)), Errors.GROUP_USED_BY_ASSET);

163:         require((groupData.groupId == 0) && (groupData.rateModel == address(0)), Errors.GROUP_USED_BY_ASSET);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ConfigureLogic.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

91:     require(withdrawReqIds.length > 0 && withdrawReqIds[0] > 0, Errors.YIELD_ETH_WITHDRAW_FAILED);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

### <a name="GAS-13"></a>[GAS-13] Increments/decrements can be unchecked in for-loops
In Solidity 0.8+, there's a default overflow check on unsigned integers. It's possible to uncheck this in for-loops and save some gas at each iteration, but at the cost of some code readability, as this uncheck cannot be made inline.

[ethereum/solidity#10695](https://github.com/ethereum/solidity/issues/10695)

The change would be:

```diff
- for (uint256 i; i < numIterations; i++) {
+ for (uint256 i; i < numIterations;) {
 // ...  
+   unchecked { ++i; }
}  
```

These save around **25 gas saved** per instance.

The same can be applied with decrements (which should use `break` when `i == 0`).

The risk of overflow is non-existent for `uint256`.

*Instances (66)*:
```solidity
File: src/PriceOracle.sol

78:     for (uint256 i = 0; i < assets.length; i++) {

88:     for (uint256 i = 0; i < assets.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/libraries/helpers/KVSortUtils.sol

25:       for (uint256 i = length / 2; i-- > 0; ) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/helpers/KVSortUtils.sol)

```solidity
File: src/libraries/logic/BorrowLogic.sol

41:     for (uint256 gidx = 0; gidx < params.groups.length; gidx++) {

82:     for (uint256 gidx = 0; gidx < params.groups.length; gidx++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/BorrowLogic.sol)

```solidity
File: src/libraries/logic/ConfigureLogic.sol

122:     for (uint256 i = 0; i < allAssets.length; i++) {

158:       for (uint256 i = 0; i < allAssets.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ConfigureLogic.sol)

```solidity
File: src/libraries/logic/FlashLoanLogic.sol

30:     for (i = 0; i < inputParams.assets.length; i++) {

72:     for (i = 0; i < inputParams.nftTokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/FlashLoanLogic.sol)

```solidity
File: src/libraries/logic/GenericLogic.sol

89:     for (vars.assetIndex = 0; vars.assetIndex < vars.userSuppliedAssets.length; vars.assetIndex++) {

142:     for (vars.assetIndex = 0; vars.assetIndex < vars.userBorrowedAssets.length; vars.assetIndex++) {

157:       for (vars.groupIndex = 0; vars.groupIndex < vars.assetGroupIds.length; vars.groupIndex++) {

190:     for (vars.groupIndex = 0; vars.groupIndex < Constants.MAX_NUMBER_OF_GROUP; vars.groupIndex++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/GenericLogic.sol)

```solidity
File: src/libraries/logic/InterestLogic.sol

109:     for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {

152:     for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {

173:     for (vars.i = 0; vars.i < vars.assetGroupIds.length; vars.i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/InterestLogic.sol)

```solidity
File: src/libraries/logic/IsolateLogic.sol

53:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

129:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

205:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

314:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

413:     for (vars.nidx = 0; vars.nidx < params.nftTokenIds.length; vars.nidx++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/IsolateLogic.sol)

```solidity
File: src/libraries/logic/LiquidationLogic.sol

312:     for (uint256 i = 0; i < groupRateList.length; i++) {

321:     for (uint256 i = 0; i < groupRateList.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/LiquidationLogic.sol)

```solidity
File: src/libraries/logic/PoolLogic.sol

46:     for (uint256 i = 0; i < assets.length; i++) {

85:     for (uint256 i = 0; i < params.tokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/PoolLogic.sol)

```solidity
File: src/libraries/logic/SupplyLogic.sol

131:       for (uint256 i = 0; i < params.tokenIds.length; i++) {

168:     for (uint256 i = 0; i < params.tokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/SupplyLogic.sol)

```solidity
File: src/libraries/logic/ValidateLogic.sol

51:     for (uint i = 0; i < values.length; i++) {

52:       for (uint j = i + 1; j < values.length; j++) {

59:     for (uint i = 0; i < values.length; i++) {

60:       for (uint j = i + 1; j < values.length; j++) {

134:     for (uint256 i = 0; i < inputParams.tokenIds.length; i++) {

166:     for (uint256 i = 0; i < inputParams.tokenIds.length; i++) {

211:       for (vars.gidx = 0; vars.gidx < inputParams.groups.length; vars.gidx++) {

243:     for (vars.gidx = 0; vars.gidx < inputParams.groups.length; vars.gidx++) {

292:     for (uint256 gidx = 0; gidx < inputParams.groups.length; gidx++) {

341:     for (uint256 i = 0; i < inputParams.collateralTokenIds.length; i++) {

402:     for (vars.i = 0; vars.i < inputParams.nftTokenIds.length; vars.i++) {

498:     for (uint256 i = 0; i < inputParams.amounts.length; i++) {

532:     for (uint256 i = 0; i < inputParams.amounts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ValidateLogic.sol)

```solidity
File: src/libraries/logic/VaultLogic.sol

265:     for (uint256 i = 0; i < groupIds.length; i++) {

291:     for (uint256 i = 0; i < groupIds.length; i++) {

319:     for (uint256 i = 0; i < groupIds.length; i++) {

349:     for (uint256 i = 0; i < groupIds.length; i++) {

502:     for (uint256 i = 0; i < amounts.length; i++) {

510:     for (uint256 i = 0; i < amounts.length; i++) {

568:     for (uint256 i = 0; i < tokenIds.length; i++) {

583:     for (uint256 i = 0; i < tokenIds.length; i++) {

598:     for (uint256 i = 0; i < tokenIds.length; i++) {

615:     for (uint256 i = 0; i < tokenIds.length; i++) {

631:     for (uint256 i = 0; i < tokenIds.length; i++) {

653:     for (uint256 i = 0; i < tokenIds.length; i++) {

670:     for (uint256 i = 0; i < tokenIds.length; i++) {

687:     for (uint256 i = 0; i < tokenIds.length; i++) {

708:     for (uint256 i = 0; i < tokenIds.length; i++) {

730:     for (uint256 i = 0; i < tokenIds.length; i++) {

740:     for (uint256 i = 0; i < tokenIds.length; i++) {

748:     for (uint256 i = 0; i < tokenIds.length; i++) {

764:     for (uint256 gidx = 0; gidx < assetGroupIds.length; gidx++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/yield/YieldStakingBase.sol

197:     for (uint i = 0; i < nfts.length; i++) {

295:     for (uint i = 0; i < nfts.length; i++) {

372:     for (uint i = 0; i < nfts.length; i++) {

534:     for (uint i = 0; i < nfts.length; i++) {

577:     for (uint i = 0; i < nfts.length; i++) {

603:     for (uint i = 0; i < nfts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

65:     for (uint i = 0; i < nfts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="GAS-14"></a>[GAS-14] Use != 0 instead of > 0 for unsigned integer comparison

*Instances (65)*:
```solidity
File: src/PriceOracle.sol

123:     require(answer > 0, Errors.ASSET_PRICE_IS_ZERO);

133:     require(nftPriceInNftBase > 0, Errors.ASSET_PRICE_IS_ZERO);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/base/Base.sol

73:     if (errMsg.length > 0) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Base.sol)

```solidity
File: src/libraries/helpers/KVSortUtils.sol

25:       for (uint256 i = length / 2; i-- > 0; ) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/helpers/KVSortUtils.sol)

```solidity
File: src/libraries/logic/BorrowLogic.sol

86:       require(debtAmount > 0, Errors.BORROW_BALANCE_IS_ZERO);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/BorrowLogic.sol)

```solidity
File: src/libraries/logic/ConfigureLogic.sol

39:     require(ps.nextPoolId > 0, Errors.INVALID_POOL_ID);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ConfigureLogic.sol)

```solidity
File: src/libraries/logic/GenericLogic.sol

437:     if (nftLoanData.scaledAmount > 0) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/GenericLogic.sol)

```solidity
File: src/libraries/logic/InterestLogic.sol

168:     if (vars.availableLiquidityPlusDebt > 0) {

184:       if (vars.totalAssetDebt > 0) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/InterestLogic.sol)

```solidity
File: src/libraries/logic/IsolateLogic.sol

261:       if ((vars.oldLastBidder != address(0)) && (vars.oldBidAmount > 0)) {

443:       if (vars.remainBidAmounts[vars.nidx] > 0) {

466:     if (vars.totalExtraAmount > 0) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/IsolateLogic.sol)

```solidity
File: src/libraries/logic/LiquidationLogic.sol

90:     require(vars.userTotalDebt > 0, Errors.USER_DEBT_BORROWED_ZERO);

97:     require(vars.userCollateralBalance > 0, Errors.USER_COLLATERAL_SUPPLY_ZERO);

106:     require(vars.actualCollateralToLiquidate > 0, Errors.ACTUAL_COLLATERAL_TO_LIQUIDATE_ZERO);

107:     require(vars.actualDebtToLiquidate > 0, Errors.ACTUAL_DEBT_TO_LIQUIDATE_ZERO);

199:     require(vars.userCollateralBalance > 0, Errors.USER_COLLATERAL_SUPPLY_ZERO);

209:     require(vars.actualCollateralToLiquidate > 0, Errors.ACTUAL_COLLATERAL_TO_LIQUIDATE_ZERO);

210:     require(vars.actualDebtToLiquidate > 0, Errors.ACTUAL_DEBT_TO_LIQUIDATE_ZERO);

219:     if (vars.remainDebtToLiquidate > 0) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/LiquidationLogic.sol)

```solidity
File: src/libraries/logic/PoolLogic.sol

74:     require(params.tokenIds.length > 0, Errors.INVALID_ID_LIST);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/PoolLogic.sol)

```solidity
File: src/libraries/logic/ValidateLogic.sol

36:       require(assetData.underlyingDecimals > 0, Errors.INVALID_ASSET_DECIMALS);

90:     require(inputParams.amount > 0, Errors.INVALID_AMOUNT);

111:     require(inputParams.amount > 0, Errors.INVALID_AMOUNT);

126:     require(inputParams.tokenIds.length > 0, Errors.INVALID_ID_LIST);

158:     require(inputParams.tokenIds.length > 0, Errors.INVALID_ID_LIST);

202:     require(inputParams.groups.length > 0, Errors.GROUP_LIST_IS_EMPTY);

244:       require(inputParams.amounts[vars.gidx] > 0, Errors.INVALID_AMOUNT);

249:         userAccountResult.allGroupsCollateralInBaseCurrency[inputParams.groups[vars.gidx]] > 0,

252:       require(userAccountResult.allGroupsAvgLtv[inputParams.groups[vars.gidx]] > 0, Errors.LTV_VALIDATION_FAILED);

288:     require(inputParams.groups.length > 0, Errors.GROUP_LIST_IS_EMPTY);

293:       require(inputParams.amounts[gidx] > 0, Errors.INVALID_AMOUNT);

315:     require(inputParams.debtToCover > 0, Errors.INVALID_BORROW_AMOUNT);

333:     require(inputParams.collateralTokenIds.length > 0, Errors.INVALID_ID_LIST);

398:     require(inputParams.nftTokenIds.length > 0, Errors.INVALID_ID_LIST);

403:       require(inputParams.amounts[vars.i] > 0, Errors.INVALID_AMOUNT);

462:     require(nftLoanResult.totalCollateralInBaseCurrency > 0, Errors.COLLATERAL_BALANCE_IS_ZERO);

494:     require(inputParams.nftTokenIds.length > 0, Errors.INVALID_ID_LIST);

499:       require(inputParams.amounts[i] > 0, Errors.INVALID_AMOUNT);

528:     require(inputParams.nftTokenIds.length > 0, Errors.INVALID_ID_LIST);

533:       require(inputParams.amounts[i] > 0, Errors.INVALID_AMOUNT);

568:     require(inputParams.nftTokenIds.length > 0, Errors.INVALID_ID_LIST);

597:     require(inputParams.nftTokenIds.length > 0, Errors.INVALID_ID_LIST);

630:     require(inputParams.amount > 0, Errors.INVALID_AMOUNT);

649:     require(inputParams.amount > 0, Errors.INVALID_AMOUNT);

681:     require(inputParams.assets.length > 0, Errors.INVALID_ID_LIST);

693:     require(inputParams.nftTokenIds.length > 0, Errors.INVALID_ID_LIST);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ValidateLogic.sol)

```solidity
File: src/libraries/logic/VaultLogic.sol

785:     require(amount > 0, Errors.INVALID_AMOUNT);

794:     require(amount > 0, Errors.INVALID_AMOUNT);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/libraries/logic/YieldLogic.sol

104:     require(vars.stakerBorrow > 0, Errors.BORROW_BALANCE_IS_ZERO);

138:     require(ymData.yieldCap > 0, Errors.YIELD_EXCEED_STAKER_CAP_LIMIT);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/YieldLogic.sol)

```solidity
File: src/yield/YieldStakingBase.sol

417:     if (vars.extraAmount > 0) {

421:     if (vars.remainAmount > 0) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

60:     if (msg.value > 0) {

79:     require(yieldAmount > 0, Errors.YIELD_ETH_DEPOSIT_FAILED);

90:     require(withdrawReqId > 0, Errors.YIELD_ETH_WITHDRAW_FAILED);

103:     require(claimedEth > 0, Errors.YIELD_ETH_CLAIM_FAILED);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

58:     if (msg.value > 0) {

77:     require(yieldAmount > 0, Errors.YIELD_ETH_DEPOSIT_FAILED);

91:     require(withdrawReqIds.length > 0 && withdrawReqIds[0] > 0, Errors.YIELD_ETH_WITHDRAW_FAILED);

101:     require(claimedEth > 0, Errors.YIELD_ETH_CLAIM_FAILED);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

88:     require(yieldAmount > 0, Errors.YIELD_ETH_DEPOSIT_FAILED);

95:     require(sd.withdrawAmount > 0, Errors.YIELD_ETH_WITHDRAW_FAILED);

108:     require(assetAmount > 0, Errors.YIELD_ETH_CLAIM_FAILED);

111:     require(claimedDai > 0, Errors.YIELD_ETH_CLAIM_FAILED);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)


## Non Critical Issues


| |Issue|Instances|
|-|:-|:-:|
| [NC-1](#NC-1) | Replace `abi.encodeWithSignature` and `abi.encodeWithSelector` with `abi.encodeCall` which keeps the code typo/type safe | 8 |
| [NC-2](#NC-2) | Constants should be in CONSTANT_CASE | 1 |
| [NC-3](#NC-3) | `constant`s should be defined rather than using magic numbers | 30 |
| [NC-4](#NC-4) | Control structures do not follow the Solidity Style Guide | 13 |
| [NC-5](#NC-5) | Critical Changes Should Use Two-step Procedure | 1 |
| [NC-6](#NC-6) | Dangerous `while(true)` loop | 1 |
| [NC-7](#NC-7) | Default Visibility for constants | 1 |
| [NC-8](#NC-8) | Functions should not be longer than 50 lines | 238 |
| [NC-9](#NC-9) | Change int to int256 | 2 |
| [NC-10](#NC-10) | Change uint to uint256 | 30 |
| [NC-11](#NC-11) | Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor | 12 |
| [NC-12](#NC-12) | Consider using named mappings | 22 |
| [NC-13](#NC-13) | Take advantage of Custom Error's return value property | 2 |
| [NC-14](#NC-14) | Strings should use double quotes rather than single quotes | 9 |
| [NC-15](#NC-15) | Use Underscores for Number Literals (add an underscore every 3 digits) | 2 |
| [NC-16](#NC-16) | Constants should be defined rather than using magic numbers | 11 |
| [NC-17](#NC-17) | Variables need not be initialized to zero | 46 |
### <a name="NC-1"></a>[NC-1] Replace `abi.encodeWithSignature` and `abi.encodeWithSelector` with `abi.encodeCall` which keeps the code typo/type safe
When using `abi.encodeWithSignature`, it is possible to include a typo for the correct function signature.
When using `abi.encodeWithSignature` or `abi.encodeWithSelector`, it is also possible to provide parameters that are not of the correct type for the function.

To avoid these pitfalls, it would be best to use [`abi.encodeCall`](https://solidity-by-example.org/abi-encode/) instead.

*Instances (8)*:
```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

75:       abi.encodeWithSelector(ILiquidityPool.deposit.selector),

87:       abi.encodeWithSelector(ILiquidityPool.requestWithdraw.selector, address(yieldAccount), sd.withdrawAmount)

100:       abi.encodeWithSelector(IWithdrawRequestNFT.claimWithdraw.selector, sd.withdrawReqId)

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

73:       abi.encodeWithSelector(IStETH.submit.selector, address(0)),

88:       abi.encodeWithSelector(IUnstETH.requestWithdrawals.selector, requestAmounts, address(yieldAccount))

99:     yieldAccount.execute(address(unstETH), abi.encodeWithSelector(IUnstETH.claimWithdrawal.selector, sd.withdrawReqId));

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

85:       abi.encodeWithSelector(ISavingsDai.deposit.selector, amount, address(yieldAccount))

105:       abi.encodeWithSelector(ISavingsDai.redeem.selector, sd.withdrawAmount, address(this), address(yieldAccount))

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="NC-2"></a>[NC-2] Constants should be in CONSTANT_CASE
For `constant` variable names, each word should use all capital letters, with underscores separating each word (CONSTANT_CASE)

*Instances (1)*:
```solidity
File: src/PoolManager.sol

17:   string public constant name = 'Bend Protocol V2';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PoolManager.sol)

### <a name="NC-3"></a>[NC-3] `constant`s should be defined rather than using magic numbers
Even [assembly](https://github.com/code-423n4/2022-05-opensea-seaport/blob/9d7ce4d08bf3c3010304a0476a785c70c0e90ae7/contracts/lib/TokenTransferrer.sol#L35-L39) can benefit from using readable constants instead of hex/numeric literals

*Instances (30)*:
```solidity
File: src/PoolManager.sol

59:     require(msgDataLength >= (4 + 4 + 20), Errors.PROXY_MSGDATA_TOO_SHORT);

62:       let payloadSize := sub(calldatasize(), 4)

63:       calldatacopy(0, 4, payloadSize)

66:       let result := delegatecall(gas(), moduleImpl, 0, add(payloadSize, 20), 0, 0)

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PoolManager.sol)

```solidity
File: src/base/BaseModule.sol

23:       msgSender := shr(96, calldataload(sub(calldatasize(), 40)))

29:       msgSender := shr(96, calldataload(sub(calldatasize(), 40)))

30:       proxyAddr := shr(96, calldataload(sub(calldatasize(), 20)))

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/BaseModule.sol)

```solidity
File: src/base/Proxy.sol

29:           log1(64, sub(calldatasize(), 33), mload(32))

31:         case 2 {

32:           log2(96, sub(calldatasize(), 65), mload(32), mload(64))

34:         case 3 {

35:           log3(128, sub(calldatasize(), 97), mload(32), mload(64), mload(96))

37:         case 4 {

38:           log4(160, sub(calldatasize(), 129), mload(32), mload(64), mload(96), mload(128))

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Proxy.sol)

```solidity
File: src/libraries/helpers/KVSortUtils.sol

22:       if (length < 2) return;

25:       for (uint256 i = length / 2; i-- > 0; ) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/helpers/KVSortUtils.sol)

```solidity
File: src/libraries/logic/LiquidationLogic.sol

404:     vars.collateralAssetUnit = 10 ** collateralAssetData.underlyingDecimals;

405:     vars.debtAssetUnit = 10 ** debtAssetData.underlyingDecimals;

493:     vars.debtAssetUnit = 10 ** debtAssetData.underlyingDecimals;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/LiquidationLogic.sol)

```solidity
File: src/libraries/math/MathUtils.sol

79:       expMinusTwo = exp > 2 ? exp - 2 : 0;

87:       secondTerm /= 2;

91:       thirdTerm /= 6;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/math/MathUtils.sol)

```solidity
File: src/libraries/math/PercentageMath.sol

48:       if or(iszero(percentage), iszero(iszero(gt(value, div(sub(not(0), div(percentage, 2)), PERCENTAGE_FACTOR))))) {

52:       result := div(add(mul(value, PERCENTAGE_FACTOR), div(percentage, 2)), percentage)

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/math/PercentageMath.sol)

```solidity
File: src/libraries/math/WadRayMath.sol

49:       if or(iszero(b), iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), WAD))))) {

53:       c := div(add(mul(a, WAD), div(b, 2)), b)

85:       if or(iszero(b), iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), RAY))))) {

89:       c := div(add(mul(a, RAY), div(b, 2)), b)

103:       if iszero(lt(remainder, div(WAD_RAY_RATIO, 2))) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/math/WadRayMath.sol)

```solidity
File: src/yield/YieldStakingBase.sol

656:     return (underAmount, yieldAmount.mulDiv(yieldPrice, 10 ** getProtocolTokenDecimals()));

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

### <a name="NC-4"></a>[NC-4] Control structures do not follow the Solidity Style Guide
See the [control structures](https://docs.soliditylang.org/en/latest/style-guide.html#control-structures) section of the Solidity Style Guide

*Instances (13)*:
```solidity
File: src/PoolManager.sol

56:     if (moduleImpl == address(0)) moduleImpl = moduleLookup[moduleId];

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PoolManager.sol)

```solidity
File: src/base/Base.sol

27:     if (proxyLookup[proxyModuleId] != address(0)) return proxyLookup[proxyModuleId];

33:     if (proxyModuleId <= Constants.MAX_EXTERNAL_SINGLE_PROXY_MODULEID) proxyLookup[proxyModuleId] = proxyAddr;

44:     if (!success) revertBytes(result);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Base.sol)

```solidity
File: src/libraries/helpers/KVSortUtils.sol

22:       if (length < 2) return;

26:         _siftDown(array, length, i, array[i]);

32:         _siftDown(array, length, 0, array[length]);

50:         if (childIdx >= length) break;

65:         if (childItem.val <= inserted.val) break;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/helpers/KVSortUtils.sol)

```solidity
File: src/libraries/logic/FlashLoanLogic.sol

4: import {IFlashLoanReceiver} from '../../interfaces/IFlashLoanReceiver.sol';

25:     IFlashLoanReceiver receiver = IFlashLoanReceiver(inputParams.receiverAddress);

67:     IFlashLoanReceiver receiver = IFlashLoanReceiver(inputParams.receiverAddress);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/FlashLoanLogic.sol)

```solidity
File: src/libraries/logic/GenericLogic.sol

353:     if (totalDebt == 0) return type(uint256).max;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/GenericLogic.sol)

### <a name="NC-5"></a>[NC-5] Critical Changes Should Use Two-step Procedure
The critical procedures should be two step process.

See similar findings in previous Code4rena contests for reference: <https://code4rena.com/reports/2022-06-illuminate/#2-critical-changes-should-use-two-step-procedure>

**Recommended Mitigation Steps**

Lack of two-step procedure for critical operations leaves them error-prone. Consider adding two step procedure on the critical functions.

*Instances (1)*:
```solidity
File: src/yield/YieldStakingBase.sol

144:   function setBotAdmin(address newAdmin) public virtual onlyPoolAdmin {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

### <a name="NC-6"></a>[NC-6] Dangerous `while(true)` loop
Consider using for-loops to avoid all risks of an infinite-loop situation

*Instances (1)*:
```solidity
File: src/libraries/helpers/KVSortUtils.sol

45:       while (true) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/helpers/KVSortUtils.sol)

### <a name="NC-7"></a>[NC-7] Default Visibility for constants
Some constants are using the default visibility. For readability, consider explicitly declaring them as `internal`.

*Instances (1)*:
```solidity
File: src/libraries/logic/StorageSlot.sol

8:   bytes32 constant STORAGE_POSITION_POOL = 0xce044ef5c897ad3fe9fcce02f9f2b7dc69de8685dee403b46b4b685baa720200;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/StorageSlot.sol)

### <a name="NC-8"></a>[NC-8] Functions should not be longer than 50 lines
Overly complex code can make understanding functionality more difficult, try to further modularize your code to ensure readability 

*Instances (238)*:
```solidity
File: src/ACLManager.sol

33:   function initialize(address aclAdmin) public initializer {

39:   function addPoolAdmin(address admin) public override {

44:   function removePoolAdmin(address admin) public override {

49:   function isPoolAdmin(address admin) public view override returns (bool) {

54:   function addEmergencyAdmin(address admin) public override {

59:   function removeEmergencyAdmin(address admin) public override {

64:   function isEmergencyAdmin(address admin) public view override returns (bool) {

69:   function addOracleAdmin(address admin) public override {

74:   function removeOracleAdmin(address admin) public override {

79:   function isOracleAdmin(address admin) public view override returns (bool) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/ACLManager.sol)

```solidity
File: src/PoolManager.sol

37:   function moduleIdToImplementation(uint moduleId) external view returns (address) {

44:   function moduleIdToProxy(uint moduleId) external view returns (address) {

48:   function dispatch() external payable reentrantOK {

96:   function emergencyEtherTransfer(address to, uint256 amount) public onlyPoolAdmin {

102:   function emergencyProxyEtherTransfer(address proxyAddr, address to, uint256 amount) public onlyPoolAdmin {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PoolManager.sol)

```solidity
File: src/PriceOracle.sol

86:   function getAssetChainlinkAggregators(address[] calldata assets) public view returns (address[] memory aggregators) {

94:   function setBendNFTOracle(address bendNFTOracle_) public onlyOracleAdmin {

100:   function getBendNFTOracle() public view returns (address) {

105:   function getAssetPrice(address asset) external view returns (uint256) {

118:   function getAssetPriceFromChainlink(address asset) public view returns (uint256) {

131:   function getAssetPriceFromBendNFTOracle(address asset) public view returns (uint256) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/base/Base.sol

21:   function _createProxy(uint proxyModuleId) internal returns (address) {

42:   function callInternalModule(uint moduleId, bytes memory input) internal returns (bytes memory) {

72:   function revertBytes(bytes memory errMsg) internal pure {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Base.sol)

```solidity
File: src/base/BaseModule.sol

21:   function unpackTrailingParamMsgSender() internal pure returns (address msgSender) {

27:   function unpackTrailingParams() internal pure returns (address msgSender, address proxyAddr) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/BaseModule.sol)

```solidity
File: src/base/Proxy.sol

67:   function emergencyEtherTransfer(address to, uint256 amount) public {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Proxy.sol)

```solidity
File: src/base/Storage.sol

31:   function getPoolStorage() internal pure returns (DataTypes.PoolStorage storage rs) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Storage.sol)

```solidity
File: src/libraries/helpers/KVSortUtils.sol

19:   function sort(KeyValue[] memory array) internal pure {

43:   function _siftDown(KeyValue[] memory array, uint256 length, uint256 emptyIdx, KeyValue memory inserted) private pure {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/helpers/KVSortUtils.sol)

```solidity
File: src/libraries/logic/BorrowLogic.sol

23:   function executeCrossBorrowERC20(InputTypes.ExecuteCrossBorrowERC20Params memory params) internal returns (uint256) {

68:   function executeCrossRepayERC20(InputTypes.ExecuteCrossRepayERC20Params memory params) internal returns (uint256) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/BorrowLogic.sol)

```solidity
File: src/libraries/logic/ConfigureLogic.sol

34:   function executeCreatePool(address msgSender, string memory name) internal returns (uint32 poolId) {

54:   function executeDeletePool(address msgSender, uint32 poolId) internal {

71:   function executeSetPoolName(address msgSender, uint32 poolId, string calldata name) internal {

82:   function executeSetPoolPause(address msgSender, uint32 poolId, bool paused) internal {

92:   function executeAddPoolGroup(address msgSender, uint32 poolId, uint8 groupId) internal {

110:   function executeRemovePoolGroup(address msgSender, uint32 poolId, uint8 groupId) internal {

139:   function executeSetPoolYieldEnable(address msgSender, uint32 poolId, bool isEnable) internal {

176:   function executeSetPoolYieldPause(address msgSender, uint32 poolId, bool isPause) internal {

187:   function executeAddAssetERC20(address msgSender, uint32 poolId, address asset) internal {

210:   function executeRemoveAssetERC20(address msgSender, uint32 poolId, address asset) internal {

223:   function executeAddAssetERC721(address msgSender, uint32 poolId, address asset) internal {

243:   function executeRemoveAssetERC721(address msgSender, uint32 poolId, address asset) internal {

302:   function executeRemoveAssetGroup(address msgSender, uint32 poolId, address asset, uint8 groupId) internal {

332:   function executeSetAssetActive(address msgSender, uint32 poolId, address asset, bool isActive) internal {

346:   function executeSetAssetFrozen(address msgSender, uint32 poolId, address asset, bool isFrozen) internal {

360:   function executeSetAssetPause(address msgSender, uint32 poolId, address asset, bool isPause) internal {

374:   function executeSetAssetBorrowing(address msgSender, uint32 poolId, address asset, bool isEnable) internal {

389:   function executeSetAssetFlashLoan(address msgSender, uint32 poolId, address asset, bool isEnable) internal {

403:   function executeSetAssetSupplyCap(address msgSender, uint32 poolId, address asset, uint256 newCap) internal {

417:   function executeSetAssetBorrowCap(address msgSender, uint32 poolId, address asset, uint256 newCap) internal {

432:   function executeSetAssetClassGroup(address msgSender, uint32 poolId, address asset, uint8 classGroup) internal {

509:   function executeSetAssetProtocolFee(address msgSender, uint32 poolId, address asset, uint16 feeFactor) internal {

554:   function executeSetAssetYieldEnable(address msgSender, uint32 poolId, address asset, bool isEnable) internal {

594:   function executeSetAssetYieldPause(address msgSender, uint32 poolId, address asset, bool isPause) internal {

609:   function executeSetAssetYieldCap(address msgSender, uint32 poolId, address asset, uint256 newCap) internal {

626:   function executeSetAssetYieldRate(address msgSender, uint32 poolId, address asset, address rateModel_) internal {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ConfigureLogic.sol)

```solidity
File: src/libraries/logic/FlashLoanLogic.sol

20:   function executeFlashLoanERC20(InputTypes.ExecuteFlashLoanERC20Params memory inputParams) internal {

62:   function executeFlashLoanERC721(InputTypes.ExecuteFlashLoanERC721Params memory inputParams) internal {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/FlashLoanLogic.sol)

```solidity
File: src/libraries/logic/InterestLogic.sol

34:   function initAssetData(DataTypes.AssetData storage assetData) internal {

39:   function initGroupData(DataTypes.GroupData storage groupData) internal {

49:   function getNormalizedSupplyIncome(DataTypes.AssetData storage assetData) internal view returns (uint256) {

258:   function _updateSupplyIndex(DataTypes.AssetData storage assetData) internal {

275:   function _updateBorrowIndex(DataTypes.AssetData storage assetData, DataTypes.GroupData storage groupData) internal {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/InterestLogic.sol)

```solidity
File: src/libraries/logic/IsolateLogic.sol

35:   function executeIsolateBorrow(InputTypes.ExecuteIsolateBorrowParams memory params) internal returns (uint256) {

114:   function executeIsolateRepay(InputTypes.ExecuteIsolateRepayParams memory params) internal returns (uint256) {

190:   function executeIsolateAuction(InputTypes.ExecuteIsolateAuctionParams memory params) internal {

296:   function executeIsolateRedeem(InputTypes.ExecuteIsolateRedeemParams memory params) internal {

396:   function executeIsolateLiquidate(InputTypes.ExecuteIsolateLiquidateParams memory params) internal {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/IsolateLogic.sol)

```solidity
File: src/libraries/logic/LiquidationLogic.sol

262:   function _transferUserERC20CollateralToLiquidator(

392:   function _calculateAvailableERC20CollateralToLiquidate(

433:   function _transferUserERC721CollateralToLiquidator(

477:   function _calculateDebtAmountFromERC721Collateral(

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/LiquidationLogic.sol)

```solidity
File: src/libraries/logic/PoolLogic.sol

26:   function checkCallerIsPoolAdmin(DataTypes.PoolStorage storage ps, address msgSender) internal view {

31:   function checkCallerIsEmergencyAdmin(DataTypes.PoolStorage storage ps, address msgSender) internal view {

36:   function executeCollectFeeToTreasury(address msgSender, uint32 poolId, address[] calldata assets) internal {

70:   function executeDelegateERC721(InputTypes.ExecuteDelegateERC721Params memory params) internal {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/PoolLogic.sol)

```solidity
File: src/libraries/logic/StorageSlot.sol

10:   function getPoolStorage() internal pure returns (DataTypes.PoolStorage storage rs) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/StorageSlot.sol)

```solidity
File: src/libraries/logic/SupplyLogic.sol

19:   function executeDepositERC20(InputTypes.ExecuteDepositERC20Params memory params) internal {

40:   function executeWithdrawERC20(InputTypes.ExecuteWithdrawERC20Params memory params) internal {

82:   function executeDepositERC721(InputTypes.ExecuteDepositERC721Params memory params) internal {

112:   function executeWithdrawERC721(InputTypes.ExecuteWithdrawERC721Params memory params) internal {

157:   function executeSetERC721SupplyMode(InputTypes.ExecuteSetERC721SupplyModeParams memory params) internal {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/SupplyLogic.sol)

```solidity
File: src/libraries/logic/ValidateLogic.sol

27:   function validatePoolBasic(DataTypes.PoolData storage poolData) internal view {

32:   function validateAssetBasic(DataTypes.AssetData storage assetData) internal view {

46:   function validateGroupBasic(DataTypes.GroupData storage groupData) internal view {

50:   function validateArrayDuplicateUInt8(uint8[] memory values) internal pure {

58:   function validateArrayDuplicateUInt256(uint256[] memory values) internal pure {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ValidateLogic.sol)

```solidity
File: src/libraries/logic/VaultLogic.sol

31:   function accountSetBorrowedAsset(DataTypes.AccountData storage accountData, address asset, bool borrowing) internal {

158:   function erc20GetTotalScaledCrossSupply(DataTypes.AssetData storage assetData) internal view returns (uint256) {

162:   function erc20GetTotalScaledIsolateSupply(DataTypes.AssetData storage assetData) internal view returns (uint256) {

211:   function erc20IncreaseCrossSupply(DataTypes.AssetData storage assetData, address account, uint256 amount) internal {

222:   function erc20DecreaseCrossSupply(DataTypes.AssetData storage assetData, address account, uint256 amount) internal {

262:   function erc20GetTotalCrossBorrowInAsset(DataTypes.AssetData storage assetData) internal view returns (uint256) {

288:   function erc20GetTotalIsolateBorrowInAsset(DataTypes.AssetData storage assetData) internal view returns (uint256) {

375:   function erc20IncreaseCrossBorrow(DataTypes.GroupData storage groupData, address account, uint256 amount) internal {

383:   function erc20IncreaseIsolateBorrow(DataTypes.GroupData storage groupData, address account, uint256 amount) internal {

403:   function erc20DecreaseCrossBorrow(DataTypes.GroupData storage groupData, address account, uint256 amount) internal {

411:   function erc20DecreaseIsolateBorrow(DataTypes.GroupData storage groupData, address account, uint256 amount) internal {

428:   function erc20TransferInLiquidity(DataTypes.AssetData storage assetData, address from, uint256 amount) internal {

440:   function erc20TransferOutLiquidity(DataTypes.AssetData storage assetData, address to, uint amount) internal {

456:   function erc20TransferBetweenWallets(address asset, address from, address to, uint amount) internal {

468:   function erc20TransferInBidAmount(DataTypes.AssetData storage assetData, address from, uint256 amount) internal {

480:   function erc20TransferOutBidAmount(DataTypes.AssetData storage assetData, address to, uint amount) internal {

496:   function erc20TransferOutBidAmountToLiqudity(DataTypes.AssetData storage assetData, uint amount) internal {

501:   function erc20TransferInOnFlashLoan(address from, address[] memory assets, uint256[] memory amounts) internal {

507:   function erc20TransferOutOnFlashLoan(address to, address[] memory assets, uint256[] memory amounts) internal {

522:   function erc721GetTotalCrossSupply(DataTypes.AssetData storage assetData) internal view returns (uint256) {

526:   function erc721GetTotalIsolateSupply(DataTypes.AssetData storage assetData) internal view returns (uint256) {

739:   function erc721TransferInOnFlashLoan(address from, address[] memory nftAssets, uint256[] memory tokenIds) internal {

745:   function erc721TransferOutOnFlashLoan(address to, address[] memory nftAssets, uint256[] memory tokenIds) internal {

771:   function checkGroupHasEmptyLiquidity(DataTypes.GroupData storage groupData) internal view {

779:   function safeTransferNativeToken(address to, uint256 amount) internal {

784:   function wrapNativeTokenInWallet(address wrappedNativeToken, address user, uint256 amount) internal {

793:   function unwrapNativeTokenInWallet(address wrappedNativeToken, address user, uint256 amount) internal {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/libraries/logic/YieldLogic.sol

32:   function executeYieldBorrowERC20(InputTypes.ExecuteYieldBorrowERC20Params memory params) internal {

85:   function executeYieldRepayERC20(InputTypes.ExecuteYieldRepayERC20Params memory params) internal {

119:   function executeYieldSetERC721TokenData(InputTypes.ExecuteYieldSetERC721TokenDataParams memory params) internal {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/YieldLogic.sol)

```solidity
File: src/libraries/math/MathUtils.sol

42:   function calculateLinearInterest(uint256 rate, uint256 lastUpdateTimestamp) internal view returns (uint256) {

103:   function calculateCompoundedInterest(uint256 rate, uint256 lastUpdateTimestamp) internal view returns (uint256) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/math/MathUtils.sol)

```solidity
File: src/libraries/math/PercentageMath.sol

27:   function percentMul(uint256 value, uint256 percentage) internal pure returns (uint256 result) {

45:   function percentDiv(uint256 value, uint256 percentage) internal pure returns (uint256 result) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/math/PercentageMath.sol)

```solidity
File: src/libraries/math/WadRayMath.sol

28:   function wadMul(uint256 a, uint256 b) internal pure returns (uint256 c) {

46:   function wadDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {

64:   function rayMul(uint256 a, uint256 b) internal pure returns (uint256 c) {

82:   function rayDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {

99:   function rayToWad(uint256 a) internal pure returns (uint256 b) {

115:   function wadToRay(uint256 a) internal pure returns (uint256 b) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/math/WadRayMath.sol)

```solidity
File: src/modules/BVault.sol

140:   function collectFeeToTreasury(uint32 poolId, address[] calldata assets) public whenNotPaused nonReentrant {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/modules/BVault.sol)

```solidity
File: src/modules/Configurator.sol

33:   function getGlobalPause() public view returns (bool) {

37:   function createPool(string memory name) public nonReentrant returns (uint32 poolId) {

42:   function deletePool(uint32 poolId) public nonReentrant {

47:   function setPoolName(uint32 poolId, string calldata name) public nonReentrant {

52:   function setPoolPause(uint32 poolId, bool paused) public nonReentrant {

57:   function addPoolGroup(uint32 poolId, uint8 groupId) public nonReentrant {

62:   function removePoolGroup(uint32 poolId, uint8 groupId) public nonReentrant {

67:   function setPoolYieldEnable(uint32 poolId, bool isEnable) public nonReentrant {

72:   function setPoolYieldPause(uint32 poolId, bool isPause) public nonReentrant {

77:   function addAssetERC20(uint32 poolId, address asset) public nonReentrant {

82:   function removeAssetERC20(uint32 poolId, address asset) public nonReentrant {

87:   function addAssetERC721(uint32 poolId, address asset) public nonReentrant {

92:   function removeAssetERC721(uint32 poolId, address asset) public nonReentrant {

97:   function addAssetGroup(uint32 poolId, address asset, uint8 groupId, address rateModel_) public nonReentrant {

102:   function removeAssetGroup(uint32 poolId, address asset, uint8 groupId) public nonReentrant {

107:   function setAssetActive(uint32 poolId, address asset, bool isActive) public nonReentrant {

112:   function setAssetFrozen(uint32 poolId, address asset, bool isFrozen) public nonReentrant {

117:   function setAssetPause(uint32 poolId, address asset, bool isPause) public nonReentrant {

122:   function setAssetBorrowing(uint32 poolId, address asset, bool isEnable) public nonReentrant {

127:   function setAssetFlashLoan(uint32 poolId, address asset, bool isEnable) public nonReentrant {

132:   function setAssetSupplyCap(uint32 poolId, address asset, uint256 newCap) public nonReentrant {

137:   function setAssetBorrowCap(uint32 poolId, address asset, uint256 newCap) public nonReentrant {

142:   function setAssetClassGroup(uint32 poolId, address asset, uint8 classGroup) public nonReentrant {

185:   function setAssetProtocolFee(uint32 poolId, address asset, uint16 feeFactor) public nonReentrant {

190:   function setAssetLendingRate(uint32 poolId, address asset, uint8 groupId, address rateModel_) public nonReentrant {

195:   function setAssetYieldEnable(uint32 poolId, address asset, bool isEnable) public nonReentrant {

200:   function setAssetYieldPause(uint32 poolId, address asset, bool isPause) public nonReentrant {

205:   function setAssetYieldCap(uint32 poolId, address asset, uint256 cap) public nonReentrant {

210:   function setAssetYieldRate(uint32 poolId, address asset, address rateModel_) public nonReentrant {

215:   function setManagerYieldCap(uint32 poolId, address staker, address asset, uint256 cap) public nonReentrant {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/modules/Configurator.sol)

```solidity
File: src/modules/Yield.sol

22:   function yieldBorrowERC20(uint32 poolId, address asset, uint256 amount) public override whenNotPaused nonReentrant {

35:   function yieldRepayERC20(uint32 poolId, address asset, uint256 amount) public override whenNotPaused nonReentrant {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/modules/Yield.sol)

```solidity
File: src/yield/YieldAccount.sol

36:   function initialize(address _registry, address _manager) public initializer {

41:   function safeApprove(address token, address spender, uint256 amount) public override onlyManager {

46:   function safeTransferNativeToken(address to, uint256 amount) public override onlyManager {

52:   function safeTransfer(address token, address to, uint256 amount) public override onlyManager {

58:   function execute(address target, bytes calldata data) public override onlyManager returns (bytes memory result) {

73:   function rescue(address target, bytes calldata data) public override onlyRegistry {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldAccount.sol)

```solidity
File: src/yield/YieldRegistry.sol

51:   function initialize(address addressProvider_) public initializer {

60:   function createYieldAccount(address _manager) public override returns (address) {

72:   function setYieldAccountImplementation(address _implementation) public onlyPoolAdmin {

79:   function addYieldManager(address _manager) public onlyPoolAdmin {

86:   function existYieldManager(address _manager) public view override returns (bool) {

90:   function getAllYieldManagers() public view returns (address[] memory) {

94:   function rescue(address yieldAccount, address target, bytes calldata data) public onlyPoolAdmin {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldRegistry.sol)

```solidity
File: src/yield/YieldStakingBase.sol

94:   function __YieldStakingBase_init(address addressProvider_, address underlyingAsset_) internal onlyInitializing {

113:   function setNftActive(address nft, bool active) public virtual onlyPoolAdmin {

144:   function setBotAdmin(address newAdmin) public virtual onlyPoolAdmin {

153:   function setPause(bool paused) public virtual onlyPoolAdmin {

165:   function createYieldAccount(address user) public virtual returns (address) {

211:   function _stake(uint32 poolId, address nft, uint256 tokenId, uint256 borrowAmount) internal virtual {

309:   function _unstake(uint32 poolId, address nft, uint256 tokenId, uint256 unstakeFine) internal virtual {

377:   function repay(uint32 poolId, address nft, uint256 tokenId) public virtual whenNotPaused nonReentrant {

381:   function _repay(uint32 poolId, address nft, uint256 tokenId) internal virtual {

461:   function getYieldAccount(address user) public view virtual returns (address) {

465:   function getTotalDebt(uint32 poolId) public view virtual returns (uint256) {

469:   function getAccountTotalYield(address account) public view virtual returns (uint256) {

473:   function getAccountTotalUnstakedYield(address account) public view virtual returns (uint256) {

477:   function getAccountYieldBalance(address account) public view virtual returns (uint256) {}

479:   function getNftValueInUnderlyingAsset(address nft) public view virtual returns (uint256) {

487:   function getNftDebtInUnderlyingAsset(address nft, uint256 tokenId) public view virtual returns (uint256) {

611:   function protocolDeposit(YieldStakeData storage sd, uint256 amount) internal virtual returns (uint256) {}

613:   function protocolRequestWithdrawal(YieldStakeData storage sd) internal virtual {}

615:   function protocolClaimWithdraw(YieldStakeData storage sd) internal virtual returns (uint256) {}

617:   function protocolIsClaimReady(YieldStakeData storage sd) internal view virtual returns (bool) {}

619:   function convertToDebtShares(uint32 poolId, uint256 assets) public view virtual returns (uint256) {

623:   function convertToDebtAssets(uint32 poolId, uint256 shares) public view virtual returns (uint256) {

627:   function convertToYieldShares(address account, uint256 assets) public view virtual returns (uint256) {

632:   function convertToYieldAssets(address account, uint256 shares) public view virtual returns (uint256) {

645:   function _getNftDebtInUnderlyingAsset(YieldStakeData storage sd) internal view virtual returns (uint256) {

649:   function _getNftYieldInUnderlyingAsset(YieldStakeData storage sd) internal view virtual returns (uint256, uint256) {

659:   function getProtocolTokenDecimals() internal view virtual returns (uint8) {

663:   function getProtocolTokenPriceInUnderlyingAsset() internal view virtual returns (uint256) {

667:   function getProtocolTokenAmountInUnderlyingAsset(uint256 yieldAmount) internal view virtual returns (uint256) {

673:   function getNftPriceInUnderlyingAsset(address nft) internal view virtual returns (uint256) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

38:   function initialize(address addressProvider_, address weth_, address liquidityPool_) public initializer {

50:   function createYieldAccount(address user) public virtual override returns (address) {

59:   function repayETH(uint32 poolId, address nft, uint256 tokenId) public payable {

68:   function protocolDeposit(YieldStakeData storage /*sd*/, uint256 amount) internal virtual override returns (uint256) {

83:   function protocolRequestWithdrawal(YieldStakeData storage sd) internal virtual override {

94:   function protocolClaimWithdraw(YieldStakeData storage sd) internal virtual override returns (uint256) {

112:   function protocolIsClaimReady(YieldStakeData storage sd) internal view virtual override returns (bool) {

120:   function getAccountYieldBalance(address account) public view override returns (uint256) {

124:   function getProtocolTokenPriceInUnderlyingAsset() internal view virtual override returns (uint256) {

131:   function getProtocolTokenDecimals() internal view virtual override returns (uint8) {

138:   function emergencyEtherTransfer(address to, uint256 amount) public onlyPoolAdmin {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

36:   function initialize(address addressProvider_, address weth_, address stETH_, address unstETH_) public initializer {

48:   function createYieldAccount(address user) public virtual override returns (address) {

57:   function repayETH(uint32 poolId, address nft, uint256 tokenId) public payable {

66:   function protocolDeposit(YieldStakeData storage /*sd*/, uint256 amount) internal virtual override returns (uint256) {

81:   function protocolRequestWithdrawal(YieldStakeData storage sd) internal virtual override {

95:   function protocolClaimWithdraw(YieldStakeData storage sd) internal virtual override returns (uint256) {

110:   function protocolIsClaimReady(YieldStakeData storage sd) internal view virtual override returns (bool) {

120:   function getAccountYieldBalance(address account) public view virtual override returns (uint256) {

124:   function getProtocolTokenPriceInUnderlyingAsset() internal view virtual override returns (uint256) {

131:   function getProtocolTokenDecimals() internal view virtual override returns (uint8) {

138:   function emergencyEtherTransfer(address to, uint256 amount) public onlyPoolAdmin {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

37:   function initialize(address addressProvider_, address dai_, address sdai_) public initializer {

49:   function createYieldAccount(address user) public virtual override returns (address) {

72:   function unstakeAndRepay(uint32 poolId, address nft, uint256 tokenId) public virtual whenNotPaused nonReentrant {

78:   function protocolDeposit(YieldStakeData storage /*sd*/, uint256 amount) internal virtual override returns (uint256) {

94:   function protocolRequestWithdrawal(YieldStakeData storage sd) internal virtual override {

98:   function protocolClaimWithdraw(YieldStakeData storage sd) internal virtual override returns (uint256) {

116:   function protocolIsClaimReady(YieldStakeData storage sd) internal view virtual override returns (bool) {

123:   function getAccountTotalUnstakedYield(address account) public view virtual override returns (uint256) {

132:   function getAccountYieldBalance(address account) public view virtual override returns (uint256) {

136:   function getProtocolTokenPriceInUnderlyingAsset() internal view virtual override returns (uint256) {

149:   function getProtocolTokenDecimals() internal view virtual override returns (uint8) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="NC-9"></a>[NC-9] Change int to int256
Throughout the code base, some variables are declared as `int`. To favor explicitness, consider changing all instances of `int` to `int256`

*Instances (2)*:
```solidity
File: src/libraries/logic/InterestLogic.sol

248:     vars.amountToMint = vars.totalDebtAccrued.percentMul(assetData.feeFactor);

250:     if (vars.amountToMint != 0) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/InterestLogic.sol)

### <a name="NC-10"></a>[NC-10] Change uint to uint256
Throughout the code base, some variables are declared as `uint`. To favor explicitness, consider changing all instances of `uint` to `uint256`

*Instances (30)*:
```solidity
File: src/PoolManager.sol

37:   function moduleIdToImplementation(uint moduleId) external view returns (address) {

44:   function moduleIdToProxy(uint moduleId) external view returns (address) {

58:     uint msgDataLength = msg.data.length;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PoolManager.sol)

```solidity
File: src/base/Base.sol

21:   function _createProxy(uint proxyModuleId) internal returns (address) {

42:   function callInternalModule(uint moduleId, bytes memory input) internal returns (bytes memory) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Base.sol)

```solidity
File: src/base/BaseModule.sol

11:   uint public immutable moduleId;

14:   constructor(uint moduleId_, bytes32 moduleGitCommit_) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/BaseModule.sol)

```solidity
File: src/base/Proxy.sol

17:     uint value = msg.value;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Proxy.sol)

```solidity
File: src/base/Storage.sol

10:   uint internal reentrancyLock;

12:   mapping(uint => address) moduleLookup; // moduleId => module implementation

13:   mapping(uint => address) proxyLookup; // moduleId => proxy address (only for single-proxy modules)

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Storage.sol)

```solidity
File: src/libraries/logic/ValidateLogic.sol

51:     for (uint i = 0; i < values.length; i++) {

52:       for (uint j = i + 1; j < values.length; j++) {

59:     for (uint i = 0; i < values.length; i++) {

60:       for (uint j = i + 1; j < values.length; j++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ValidateLogic.sol)

```solidity
File: src/libraries/logic/VaultLogic.sol

440:   function erc20TransferOutLiquidity(DataTypes.AssetData storage assetData, address to, uint amount) internal {

452:     uint poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

456:   function erc20TransferBetweenWallets(address asset, address from, address to, uint amount) internal {

464:     uint userSizeAfter = IERC20Upgradeable(asset).balanceOf(to);

480:   function erc20TransferOutBidAmount(DataTypes.AssetData storage assetData, address to, uint amount) internal {

492:     uint poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

496:   function erc20TransferOutBidAmountToLiqudity(DataTypes.AssetData storage assetData, uint amount) internal {

734:     uint poolSizeAfter = IERC721Upgradeable(asset).balanceOf(address(this));

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/yield/YieldStakingBase.sol

197:     for (uint i = 0; i < nfts.length; i++) {

295:     for (uint i = 0; i < nfts.length; i++) {

372:     for (uint i = 0; i < nfts.length; i++) {

534:     for (uint i = 0; i < nfts.length; i++) {

577:     for (uint i = 0; i < nfts.length; i++) {

603:     for (uint i = 0; i < nfts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

65:     for (uint i = 0; i < nfts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="NC-11"></a>[NC-11] Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor
If a function is supposed to be access-controlled, a `modifier` should be used instead of a `require/if` statement for more readability.

*Instances (12)*:
```solidity
File: src/PoolManager.sol

92:     require(aclManager.isPoolAdmin(msg.sender), Errors.CALLER_NOT_POOL_ADMIN);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PoolManager.sol)

```solidity
File: src/PriceOracle.sol

44:     require(IACLManager(addressProvider.getACLManager()).isOracleAdmin(msg.sender), Errors.CALLER_NOT_ORACLE_ADMIN);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/base/Proxy.sol

19:     if (msg.sender == creator_) {

68:     require(msg.sender == creator, 'Invalid caller');

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Proxy.sol)

```solidity
File: src/yield/YieldAccount.sol

23:     require(msg.sender == address(yieldRegistry), Errors.YIELD_REGISTRY_IS_NOT_AUTH);

33:     require(msg.sender == yieldManager, Errors.YIELD_MANAGER_IS_NOT_AUTH);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldAccount.sol)

```solidity
File: src/yield/YieldRegistry.sol

44:     require(IACLManager(addressProvider.getACLManager()).isPoolAdmin(msg.sender), Errors.CALLER_NOT_POOL_ADMIN);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldRegistry.sol)

```solidity
File: src/yield/YieldStakingBase.sol

91:     require(IACLManager(addressProvider.getACLManager()).isPoolAdmin(msg.sender), Errors.CALLER_NOT_POOL_ADMIN);

222:     require(vars.nftOwner == msg.sender, Errors.INVALID_CALLER);

320:     require(vars.nftOwner == msg.sender || botAdmin == msg.sender, Errors.INVALID_CALLER);

329:     if (msg.sender == botAdmin) {

398:     require(vars.nftOwner == msg.sender || botAdmin == msg.sender, Errors.INVALID_CALLER);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

### <a name="NC-12"></a>[NC-12] Consider using named mappings
Consider moving to solidity version 0.8.18 or later, and using [named mappings](https://ethereum.stackexchange.com/questions/51629/how-to-name-the-arguments-in-mapping/145555#145555) to make it easier to understand the purpose of each mapping

*Instances (22)*:
```solidity
File: src/PriceOracle.sol

29:   mapping(address => AggregatorV2V3Interface) public assetChainlinkAggregators;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/base/Storage.sol

12:   mapping(uint => address) moduleLookup; // moduleId => module implementation

13:   mapping(uint => address) proxyLookup; // moduleId => proxy address (only for single-proxy modules)

20:   mapping(address => TrustedSenderInfo) trustedSenders; // sender address => moduleId (0 = un-trusted)

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Storage.sol)

```solidity
File: src/libraries/types/DataTypes.sol

15:     mapping(uint8 => bool) enabledGroups;

19:     mapping(address => AssetData) assetLookup;

23:     mapping(address => mapping(uint256 => IsolateLoanData)) loanLookup;

25:     mapping(address => AccountData) accountLookup;

37:     mapping(address => mapping(address => bool)) operatorApprovals;

46:     mapping(address => uint256) userScaledCrossBorrow;

48:     mapping(address => uint256) userScaledIsolateBorrow;

92:     mapping(uint8 => GroupData) groupLookup;

100:     mapping(address => uint256) userScaledCrossSupply; // user supplied balance in cross margin mode

101:     mapping(address => uint256) userScaledIsolateSupply; // user supplied balance in isolate mode, only for ERC721

102:     mapping(uint256 => ERC721TokenData) erc721TokenData; // token -> data, only for ERC721

111:     mapping(address => YieldManagerData) yieldManagerLookup;

134:     mapping(uint32 => PoolData) poolLookup;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/types/DataTypes.sol)

```solidity
File: src/yield/YieldStakingBase.sol

72:   mapping(address => address) public yieldAccounts;

73:   mapping(address => uint256) public accountYieldShares;

74:   mapping(address => YieldNftConfig) public nftConfigs;

75:   mapping(address => mapping(uint256 => YieldStakeData)) public stakeDatas;

76:   mapping(address => uint256) public accountYieldInWithdraws;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

### <a name="NC-13"></a>[NC-13] Take advantage of Custom Error's return value property
An important feature of Custom Error is that values such as address, tokenID, msg.value can be written inside the () sign, this kind of approach provides a serious advantage in debugging and examining the revert details of dapps such as tenderly.

*Instances (2)*:
```solidity
File: src/PoolManager.sol

72:         revert(0, returndatasize())

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PoolManager.sol)

```solidity
File: src/base/Proxy.sol

57:           revert(0, returndatasize())

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Proxy.sol)

### <a name="NC-14"></a>[NC-14] Strings should use double quotes rather than single quotes
See the Solidity Style Guide: https://docs.soliditylang.org/en/v0.8.20/style-guide.html#other-recommendations

*Instances (9)*:
```solidity
File: src/ACLManager.sol

13:   bytes32 public constant override POOL_ADMIN_ROLE = keccak256('POOL_ADMIN');

14:   bytes32 public constant override EMERGENCY_ADMIN_ROLE = keccak256('EMERGENCY_ADMIN');

15:   bytes32 public constant override ORACLE_ADMIN_ROLE = keccak256('ORACLE_ADMIN');

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/ACLManager.sol)

```solidity
File: src/PoolManager.sol

17:   string public constant name = 'Bend Protocol V2';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PoolManager.sol)

```solidity
File: src/base/Proxy.sol

68:     require(msg.sender == creator, 'Invalid caller');

71:     require(success, 'ETH_TRANSFER_FAILED');

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Proxy.sol)

```solidity
File: src/libraries/logic/PoolLogic.sol

89:       delegateRegistryV2.delegateERC721(params.delegate, params.nftAsset, params.tokenIds[i], '', params.value);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/PoolLogic.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

140:     require(success, 'ETH_TRANSFER_FAILED');

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

140:     require(success, 'ETH_TRANSFER_FAILED');

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

### <a name="NC-15"></a>[NC-15] Use Underscores for Number Literals (add an underscore every 3 digits)

*Instances (2)*:
```solidity
File: src/yield/YieldStakingBase.sol

47:     uint16 leverageFactor; // e.g. 50000 -> 500%

48:     uint16 liquidationThreshold; // e.g. 9000 -> 90%

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

### <a name="NC-16"></a>[NC-16] Constants should be defined rather than using magic numbers

*Instances (11)*:
```solidity
File: src/PoolManager.sol

64:       mstore(payloadSize, shl(96, caller()))

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PoolManager.sol)

```solidity
File: src/base/BaseModule.sol

23:       msgSender := shr(96, calldataload(sub(calldatasize(), 40)))

29:       msgSender := shr(96, calldataload(sub(calldatasize(), 40)))

30:       proxyAddr := shr(96, calldataload(sub(calldatasize(), 20)))

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/BaseModule.sol)

```solidity
File: src/base/Proxy.sol

22:         calldatacopy(31, 0, calldatasize())

29:           log1(64, sub(calldatasize(), 33), mload(32))

32:           log2(96, sub(calldatasize(), 65), mload(32), mload(64))

35:           log3(128, sub(calldatasize(), 97), mload(32), mload(64), mload(96))

38:           log4(160, sub(calldatasize(), 129), mload(32), mload(64), mload(96), mload(128))

50:         mstore(add(4, calldatasize()), shl(96, caller()))

52:         let result := call(gas(), creator_, value, 0, add(24, calldatasize()), 0, 0)

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Proxy.sol)

### <a name="NC-17"></a>[NC-17] Variables need not be initialized to zero
The default value for variables is zero, so initializing them to zero is superfluous.

*Instances (46)*:
```solidity
File: src/PriceOracle.sol

78:     for (uint256 i = 0; i < assets.length; i++) {

88:     for (uint256 i = 0; i < assets.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/libraries/logic/BorrowLogic.sol

41:     for (uint256 gidx = 0; gidx < params.groups.length; gidx++) {

82:     for (uint256 gidx = 0; gidx < params.groups.length; gidx++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/BorrowLogic.sol)

```solidity
File: src/libraries/logic/ConfigureLogic.sol

122:     for (uint256 i = 0; i < allAssets.length; i++) {

158:       for (uint256 i = 0; i < allAssets.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ConfigureLogic.sol)

```solidity
File: src/libraries/logic/LiquidationLogic.sol

312:     for (uint256 i = 0; i < groupRateList.length; i++) {

321:     for (uint256 i = 0; i < groupRateList.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/LiquidationLogic.sol)

```solidity
File: src/libraries/logic/PoolLogic.sol

46:     for (uint256 i = 0; i < assets.length; i++) {

85:     for (uint256 i = 0; i < params.tokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/PoolLogic.sol)

```solidity
File: src/libraries/logic/SupplyLogic.sol

131:       for (uint256 i = 0; i < params.tokenIds.length; i++) {

168:     for (uint256 i = 0; i < params.tokenIds.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/SupplyLogic.sol)

```solidity
File: src/libraries/logic/ValidateLogic.sol

51:     for (uint i = 0; i < values.length; i++) {

59:     for (uint i = 0; i < values.length; i++) {

134:     for (uint256 i = 0; i < inputParams.tokenIds.length; i++) {

166:     for (uint256 i = 0; i < inputParams.tokenIds.length; i++) {

292:     for (uint256 gidx = 0; gidx < inputParams.groups.length; gidx++) {

341:     for (uint256 i = 0; i < inputParams.collateralTokenIds.length; i++) {

498:     for (uint256 i = 0; i < inputParams.amounts.length; i++) {

532:     for (uint256 i = 0; i < inputParams.amounts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ValidateLogic.sol)

```solidity
File: src/libraries/logic/VaultLogic.sol

265:     for (uint256 i = 0; i < groupIds.length; i++) {

291:     for (uint256 i = 0; i < groupIds.length; i++) {

319:     for (uint256 i = 0; i < groupIds.length; i++) {

349:     for (uint256 i = 0; i < groupIds.length; i++) {

502:     for (uint256 i = 0; i < amounts.length; i++) {

510:     for (uint256 i = 0; i < amounts.length; i++) {

568:     for (uint256 i = 0; i < tokenIds.length; i++) {

583:     for (uint256 i = 0; i < tokenIds.length; i++) {

598:     for (uint256 i = 0; i < tokenIds.length; i++) {

615:     for (uint256 i = 0; i < tokenIds.length; i++) {

631:     for (uint256 i = 0; i < tokenIds.length; i++) {

653:     for (uint256 i = 0; i < tokenIds.length; i++) {

670:     for (uint256 i = 0; i < tokenIds.length; i++) {

687:     for (uint256 i = 0; i < tokenIds.length; i++) {

708:     for (uint256 i = 0; i < tokenIds.length; i++) {

730:     for (uint256 i = 0; i < tokenIds.length; i++) {

740:     for (uint256 i = 0; i < tokenIds.length; i++) {

748:     for (uint256 i = 0; i < tokenIds.length; i++) {

764:     for (uint256 gidx = 0; gidx < assetGroupIds.length; gidx++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/yield/YieldStakingBase.sol

197:     for (uint i = 0; i < nfts.length; i++) {

295:     for (uint i = 0; i < nfts.length; i++) {

372:     for (uint i = 0; i < nfts.length; i++) {

534:     for (uint i = 0; i < nfts.length; i++) {

577:     for (uint i = 0; i < nfts.length; i++) {

603:     for (uint i = 0; i < nfts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

65:     for (uint i = 0; i < nfts.length; i++) {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)


## Low Issues


| |Issue|Instances|
|-|:-|:-:|
| [L-1](#L-1) | `approve()`/`safeApprove()` may revert if the current approval is not zero | 5 |
| [L-2](#L-2) | `decimals()` is not a part of the ERC-20 standard | 8 |
| [L-3](#L-3) | Do not use deprecated library functions | 6 |
| [L-4](#L-4) | `safeApprove()` is deprecated | 4 |
| [L-5](#L-5) | Deprecated _setupRole() function | 1 |
| [L-6](#L-6) | Division by zero not prevented | 6 |
| [L-7](#L-7) | External call recipient may consume all transaction gas | 6 |
| [L-8](#L-8) | Initializers could be front-run | 17 |
| [L-9](#L-9) | Possible rounding issue | 3 |
| [L-10](#L-10) | Loss of precision | 7 |
| [L-11](#L-11) | Unsafe ERC20 operation(s) | 5 |
| [L-12](#L-12) | Upgradeable contract is missing a `__gap[50]` storage variable to allow for new storage variables in later versions | 78 |
| [L-13](#L-13) | Upgradeable contract not initialized | 101 |
| [L-14](#L-14) | A year is not always 365 days | 1 |
### <a name="L-1"></a>[L-1] `approve()`/`safeApprove()` may revert if the current approval is not zero
- Some tokens (like the *very popular* USDT) do not work when changing the allowance from an existing non-zero allowance value (it will revert if the current approval is not zero to protect against front-running changes of approvals). These tokens must first be approved for zero and then the actual allowance can be approved.
- Furthermore, OZ's implementation of safeApprove would throw an error if an approve is attempted from a non-zero value (`"SafeERC20: approve from non-zero to non-zero allowance"`)

Set the allowance to zero immediately before each of the existing allowance calls

*Instances (5)*:
```solidity
File: src/yield/YieldAccount.sol

42:     IERC20(token).safeApprove(spender, amount);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldAccount.sol)

```solidity
File: src/yield/YieldStakingBase.sol

106:     underlyingAsset.approve(address(poolManager), type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

54:     yieldAccount.safeApprove(address(eETH), address(liquidityPool), type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

52:     yieldAccount.safeApprove(address(stETH), address(unstETH), type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

53:     yieldAccount.safeApprove(address(dai), address(sdai), type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="L-2"></a>[L-2] `decimals()` is not a part of the ERC-20 standard
The `decimals()` function is not a part of the [ERC-20 standard](https://eips.ethereum.org/EIPS/eip-20), and was added later as an [optional extension](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol). As such, some valid ERC20 tokens do not support this interface, so it is unsafe to blindly cast all tokens to this interface, and then call this function.

*Instances (8)*:
```solidity
File: src/libraries/logic/ConfigureLogic.sol

200:     assetData.underlyingDecimals = IERC20MetadataUpgradeable(asset).decimals();

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ConfigureLogic.sol)

```solidity
File: src/yield/YieldStakingBase.sol

677:     return nftPriceInBase.mulDiv(10 ** underlyingAsset.decimals(), underlyingAssetPriceInBase);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

128:     return eEthPriceInBase.mulDiv(10 ** underlyingAsset.decimals(), ethPriceInBase);

132:     return eETH.decimals();

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

128:     return stETHPriceInBase.mulDiv(10 ** underlyingAsset.decimals(), ethPriceInBase);

132:     return stETH.decimals();

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

140:     return sDaiPriceInBase.mulDiv(10 ** underlyingAsset.decimals(), daiPriceInBase);

150:     return sdai.decimals();

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="L-3"></a>[L-3] Do not use deprecated library functions

*Instances (6)*:
```solidity
File: src/ACLManager.sol

35:     _setupRole(DEFAULT_ADMIN_ROLE, aclAdmin);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/ACLManager.sol)

```solidity
File: src/yield/YieldAccount.sol

41:   function safeApprove(address token, address spender, uint256 amount) public override onlyManager {

42:     IERC20(token).safeApprove(spender, amount);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldAccount.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

54:     yieldAccount.safeApprove(address(eETH), address(liquidityPool), type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

52:     yieldAccount.safeApprove(address(stETH), address(unstETH), type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

53:     yieldAccount.safeApprove(address(dai), address(sdai), type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="L-4"></a>[L-4] `safeApprove()` is deprecated
[Deprecated](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/bfff03c0d2a59bcd8e2ead1da9aed9edf0080d05/contracts/token/ERC20/utils/SafeERC20.sol#L38-L45) in favor of `safeIncreaseAllowance()` and `safeDecreaseAllowance()`. If only setting the initial allowance to the value that means infinite, `safeIncreaseAllowance()` can be used instead. The function may currently work, but if a bug is found in this version of OpenZeppelin, and the version that you're forced to upgrade to no longer has this function, you'll encounter unnecessary delays in porting and testing replacement contracts.

*Instances (4)*:
```solidity
File: src/yield/YieldAccount.sol

42:     IERC20(token).safeApprove(spender, amount);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldAccount.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

54:     yieldAccount.safeApprove(address(eETH), address(liquidityPool), type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

52:     yieldAccount.safeApprove(address(stETH), address(unstETH), type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

53:     yieldAccount.safeApprove(address(dai), address(sdai), type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="L-5"></a>[L-5] Deprecated _setupRole() function

*Instances (1)*:
```solidity
File: src/ACLManager.sol

35:     _setupRole(DEFAULT_ADMIN_ROLE, aclAdmin);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/ACLManager.sol)

### <a name="L-6"></a>[L-6] Division by zero not prevented
The divisions below take an input parameter which does not have any zero-value checks, which may lead to the functions reverting when zero is passed.

*Instances (6)*:
```solidity
File: src/libraries/logic/GenericLogic.sol

182:       result.avgLtv = result.avgLtv / result.totalCollateralInBaseCurrency;

394:     return userTotalDebt / (10 ** assetData.underlyingDecimals);

413:     return userTotalBalance / (10 ** assetData.underlyingDecimals);

442:       loanDebtAmount = loanDebtAmount / (10 ** debtAssetData.underlyingDecimals);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/GenericLogic.sol)

```solidity
File: src/libraries/logic/LiquidationLogic.sol

500:     vars.collateralItemDebtToCover = vars.collateralTotalDebtToCover / liqVars.userCollateralBalance;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/LiquidationLogic.sol)

```solidity
File: src/libraries/math/MathUtils.sol

81:       basePowerTwo = rate.rayMul(rate) / (SECONDS_PER_YEAR * SECONDS_PER_YEAR);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/math/MathUtils.sol)

### <a name="L-7"></a>[L-7] External call recipient may consume all transaction gas
There is no limit specified on the amount of gas used, so the recipient can use up all of the transaction's gas, causing it to revert. Use `addr.call{gas: <amount>}("")` or [this](https://github.com/nomad-xyz/ExcessivelySafeCall) library instead.

*Instances (6)*:
```solidity
File: src/PoolManager.sol

97:     (bool success, ) = to.call{value: amount}(new bytes(0));

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PoolManager.sol)

```solidity
File: src/base/Proxy.sol

70:     (bool success, ) = to.call{value: amount}(new bytes(0));

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/base/Proxy.sol)

```solidity
File: src/libraries/logic/VaultLogic.sol

780:     (bool success, ) = to.call{value: amount}(new bytes(0));

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/yield/YieldAccount.sol

47:     (bool success, ) = to.call{value: amount}(new bytes(0));

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldAccount.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

139:     (bool success, ) = to.call{value: amount}(new bytes(0));

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

139:     (bool success, ) = to.call{value: amount}(new bytes(0));

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

### <a name="L-8"></a>[L-8] Initializers could be front-run
Initializers could be front-run, allowing an attacker to either set their own values, take ownership of the contract, and in the best case forcing a re-deployment

*Instances (17)*:
```solidity
File: src/ACLManager.sol

33:   function initialize(address aclAdmin) public initializer {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/ACLManager.sol)

```solidity
File: src/PriceOracle.sol

54:   function initialize(

60:   ) public initializer {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/yield/YieldAccount.sol

36:   function initialize(address _registry, address _manager) public initializer {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldAccount.sol)

```solidity
File: src/yield/YieldRegistry.sol

51:   function initialize(address addressProvider_) public initializer {

54:     __Pausable_init();

55:     __ReentrancyGuard_init();

65:     YieldAccount(payable(yieldAccount)).initialize(address(this), _manager);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldRegistry.sol)

```solidity
File: src/yield/YieldStakingBase.sol

94:   function __YieldStakingBase_init(address addressProvider_, address underlyingAsset_) internal onlyInitializing {

95:     __Pausable_init();

96:     __ReentrancyGuard_init();

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

38:   function initialize(address addressProvider_, address weth_, address liquidityPool_) public initializer {

43:     __YieldStakingBase_init(addressProvider_, weth_);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

36:   function initialize(address addressProvider_, address weth_, address stETH_, address unstETH_) public initializer {

42:     __YieldStakingBase_init(addressProvider_, weth_);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

37:   function initialize(address addressProvider_, address dai_, address sdai_) public initializer {

43:     __YieldStakingBase_init(addressProvider_, dai_);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="L-9"></a>[L-9] Possible rounding issue
Division by large numbers may result in the result being zero, due to solidity not supporting fractions. Consider requiring a minimum amount for the numerator to ensure that it is always larger than the denominator. Also, there is indication of multiplication and division without the use of parenthesis which could result in issues.

*Instances (3)*:
```solidity
File: src/libraries/logic/GenericLogic.sol

182:       result.avgLtv = result.avgLtv / result.totalCollateralInBaseCurrency;

183:       result.avgLiquidationThreshold = result.avgLiquidationThreshold / result.totalCollateralInBaseCurrency;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/GenericLogic.sol)

```solidity
File: src/libraries/logic/LiquidationLogic.sol

500:     vars.collateralItemDebtToCover = vars.collateralTotalDebtToCover / liqVars.userCollateralBalance;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/LiquidationLogic.sol)

### <a name="L-10"></a>[L-10] Loss of precision
Division by large numbers may result in the result being zero, due to solidity not supporting fractions. Consider requiring a minimum amount for the numerator to ensure that it is always larger than the denominator

*Instances (7)*:
```solidity
File: src/PriceOracle.sol

142:     uint256 nftPriceInBase = (nftPriceInNftBase * nftBaseCurrencyPriceInBase) / NFT_BASE_CURRENCY_UNIT;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/libraries/logic/GenericLogic.sol

182:       result.avgLtv = result.avgLtv / result.totalCollateralInBaseCurrency;

183:       result.avgLiquidationThreshold = result.avgLiquidationThreshold / result.totalCollateralInBaseCurrency;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/GenericLogic.sol)

```solidity
File: src/libraries/math/MathUtils.sol

30:       result = result / SECONDS_PER_YEAR;

81:       basePowerTwo = rate.rayMul(rate) / (SECONDS_PER_YEAR * SECONDS_PER_YEAR);

82:       basePowerThree = basePowerTwo.rayMul(rate) / SECONDS_PER_YEAR;

94:     return WadRayMath.RAY + (rate * exp) / SECONDS_PER_YEAR + secondTerm + thirdTerm;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/math/MathUtils.sol)

### <a name="L-11"></a>[L-11] Unsafe ERC20 operation(s)

*Instances (5)*:
```solidity
File: src/libraries/logic/VaultLogic.sol

789:     bool success = IWETH(wrappedNativeToken).transferFrom(address(this), user, amount);

796:     bool success = IWETH(wrappedNativeToken).transferFrom(user, address(this), amount);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/yield/YieldStakingBase.sol

106:     underlyingAsset.approve(address(poolManager), type(uint256).max);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

62:       IWETH(address(underlyingAsset)).transfer(msg.sender, msg.value);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

60:       IWETH(address(underlyingAsset)).transfer(msg.sender, msg.value);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

### <a name="L-12"></a>[L-12] Upgradeable contract is missing a `__gap[50]` storage variable to allow for new storage variables in later versions
See [this](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps) link for a description of this storage variable. While some contracts may not currently be sub-classed, adding the variable now protects against forgetting to add it in the future.

*Instances (78)*:
```solidity
File: src/ACLManager.sol

4: import {AccessControlUpgradeable} from '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';

12: contract ACLManager is AccessControlUpgradeable, IACLManager {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/ACLManager.sol)

```solidity
File: src/PriceOracle.sol

4: import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/libraries/logic/ConfigureLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {IERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';

6: import {IERC20MetadataUpgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol';

7: import {SafeCastUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol';

31:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

32:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

200:     assetData.underlyingDecimals = IERC20MetadataUpgradeable(asset).decimals();

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ConfigureLogic.sol)

```solidity
File: src/libraries/logic/GenericLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

23:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

24:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/GenericLogic.sol)

```solidity
File: src/libraries/logic/InterestLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {IERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';

6: import {SafeCastUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol';

25:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

26:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

27:   using SafeCastUpgradeable for uint256;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/InterestLogic.sol)

```solidity
File: src/libraries/logic/LiquidationLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

28:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

29:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/LiquidationLogic.sol)

```solidity
File: src/libraries/logic/ValidateLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {IERC721Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';

24:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

25:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ValidateLogic.sol)

```solidity
File: src/libraries/logic/VaultLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {IERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';

6: import {SafeERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol';

7: import {IERC721Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';

19:   using SafeERC20Upgradeable for IERC20Upgradeable;

21:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

22:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

430:     uint256 poolSizeBefore = IERC20Upgradeable(asset).balanceOf(address(this));

434:     IERC20Upgradeable(asset).safeTransferFrom(from, address(this), amount);

436:     uint256 poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

445:     uint256 poolSizeBefore = IERC20Upgradeable(asset).balanceOf(address(this));

450:     IERC20Upgradeable(asset).safeTransfer(to, amount);

452:     uint poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

460:     uint256 userSizeBefore = IERC20Upgradeable(asset).balanceOf(to);

462:     IERC20Upgradeable(asset).safeTransferFrom(from, to, amount);

464:     uint userSizeAfter = IERC20Upgradeable(asset).balanceOf(to);

470:     uint256 poolSizeBefore = IERC20Upgradeable(asset).balanceOf(address(this));

474:     IERC20Upgradeable(asset).safeTransferFrom(from, address(this), amount);

476:     uint256 poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

485:     uint256 poolSizeBefore = IERC20Upgradeable(asset).balanceOf(address(this));

490:     IERC20Upgradeable(asset).safeTransfer(to, amount);

492:     uint poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

503:       IERC20Upgradeable(assets[i]).safeTransferFrom(from, address(this), amounts[i]);

511:       IERC20Upgradeable(assets[i]).safeTransfer(to, amounts[i]);

704:     uint256 poolSizeBefore = IERC721Upgradeable(asset).balanceOf(address(this));

709:       IERC721Upgradeable(asset).safeTransferFrom(from, address(this), tokenIds[i]);

712:     uint256 poolSizeAfter = IERC721Upgradeable(asset).balanceOf(address(this));

728:     uint256 poolSizeBefore = IERC721Upgradeable(asset).balanceOf(address(this));

731:       IERC721Upgradeable(asset).safeTransferFrom(address(this), to, tokenIds[i]);

734:     uint poolSizeAfter = IERC721Upgradeable(asset).balanceOf(address(this));

741:       IERC721Upgradeable(nftAssets[i]).safeTransferFrom(from, address(this), tokenIds[i]);

749:       IERC721Upgradeable(nftAssets[i]).safeTransferFrom(address(this), to, tokenIds[i]);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/libraries/types/DataTypes.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

16:     EnumerableSetUpgradeable.UintSet groupList;

20:     EnumerableSetUpgradeable.AddressSet assetList;

34:     EnumerableSetUpgradeable.AddressSet suppliedAssets;

35:     EnumerableSetUpgradeable.AddressSet borrowedAssets;

93:     EnumerableSetUpgradeable.UintSet groupList;

135:     EnumerableSetUpgradeable.UintSet poolList;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/types/DataTypes.sol)

```solidity
File: src/yield/YieldRegistry.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {ClonesUpgradeable} from '@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol';

6: import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

7: import {PausableUpgradeable} from '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';

8: import {ReentrancyGuardUpgradeable} from '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';

19: contract YieldRegistry is IYieldRegistry, PausableUpgradeable, ReentrancyGuardUpgradeable {

20:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

29:   EnumerableSetUpgradeable.AddressSet internal yieldManagers;

64:     address yieldAccount = ClonesUpgradeable.clone(yieldAccountImplementation);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldRegistry.sol)

```solidity
File: src/yield/YieldStakingBase.sol

8: import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

9: import {PausableUpgradeable} from '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';

10: import {ReentrancyGuardUpgradeable} from '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';

28: abstract contract YieldStakingBase is Initializable, PausableUpgradeable, ReentrancyGuardUpgradeable {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

### <a name="L-13"></a>[L-13] Upgradeable contract not initialized
Upgradeable contracts are initialized via an initializer function rather than by a constructor. Leaving such a contract uninitialized may lead to it being taken over by a malicious user

*Instances (101)*:
```solidity
File: src/ACLManager.sol

4: import {AccessControlUpgradeable} from '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';

12: contract ACLManager is AccessControlUpgradeable, IACLManager {

25:     _disableInitializers();

33:   function initialize(address aclAdmin) public initializer {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/ACLManager.sol)

```solidity
File: src/PriceOracle.sol

4: import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

48:     _disableInitializers();

54:   function initialize(

60:   ) public initializer {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/PriceOracle.sol)

```solidity
File: src/libraries/logic/ConfigureLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {IERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';

6: import {IERC20MetadataUpgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol';

7: import {SafeCastUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol';

31:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

32:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

200:     assetData.underlyingDecimals = IERC20MetadataUpgradeable(asset).decimals();

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ConfigureLogic.sol)

```solidity
File: src/libraries/logic/GenericLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

23:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

24:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/GenericLogic.sol)

```solidity
File: src/libraries/logic/InterestLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {IERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';

6: import {SafeCastUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol';

25:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

26:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

27:   using SafeCastUpgradeable for uint256;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/InterestLogic.sol)

```solidity
File: src/libraries/logic/LiquidationLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

28:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

29:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/LiquidationLogic.sol)

```solidity
File: src/libraries/logic/ValidateLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {IERC721Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';

24:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

25:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/ValidateLogic.sol)

```solidity
File: src/libraries/logic/VaultLogic.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {IERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';

6: import {SafeERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol';

7: import {IERC721Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';

19:   using SafeERC20Upgradeable for IERC20Upgradeable;

21:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

22:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

430:     uint256 poolSizeBefore = IERC20Upgradeable(asset).balanceOf(address(this));

434:     IERC20Upgradeable(asset).safeTransferFrom(from, address(this), amount);

436:     uint256 poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

445:     uint256 poolSizeBefore = IERC20Upgradeable(asset).balanceOf(address(this));

450:     IERC20Upgradeable(asset).safeTransfer(to, amount);

452:     uint poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

460:     uint256 userSizeBefore = IERC20Upgradeable(asset).balanceOf(to);

462:     IERC20Upgradeable(asset).safeTransferFrom(from, to, amount);

464:     uint userSizeAfter = IERC20Upgradeable(asset).balanceOf(to);

470:     uint256 poolSizeBefore = IERC20Upgradeable(asset).balanceOf(address(this));

474:     IERC20Upgradeable(asset).safeTransferFrom(from, address(this), amount);

476:     uint256 poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

485:     uint256 poolSizeBefore = IERC20Upgradeable(asset).balanceOf(address(this));

490:     IERC20Upgradeable(asset).safeTransfer(to, amount);

492:     uint poolSizeAfter = IERC20Upgradeable(asset).balanceOf(address(this));

503:       IERC20Upgradeable(assets[i]).safeTransferFrom(from, address(this), amounts[i]);

511:       IERC20Upgradeable(assets[i]).safeTransfer(to, amounts[i]);

704:     uint256 poolSizeBefore = IERC721Upgradeable(asset).balanceOf(address(this));

709:       IERC721Upgradeable(asset).safeTransferFrom(from, address(this), tokenIds[i]);

712:     uint256 poolSizeAfter = IERC721Upgradeable(asset).balanceOf(address(this));

728:     uint256 poolSizeBefore = IERC721Upgradeable(asset).balanceOf(address(this));

731:       IERC721Upgradeable(asset).safeTransferFrom(address(this), to, tokenIds[i]);

734:     uint poolSizeAfter = IERC721Upgradeable(asset).balanceOf(address(this));

741:       IERC721Upgradeable(nftAssets[i]).safeTransferFrom(from, address(this), tokenIds[i]);

749:       IERC721Upgradeable(nftAssets[i]).safeTransferFrom(address(this), to, tokenIds[i]);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/logic/VaultLogic.sol)

```solidity
File: src/libraries/types/DataTypes.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

16:     EnumerableSetUpgradeable.UintSet groupList;

20:     EnumerableSetUpgradeable.AddressSet assetList;

34:     EnumerableSetUpgradeable.AddressSet suppliedAssets;

35:     EnumerableSetUpgradeable.AddressSet borrowedAssets;

93:     EnumerableSetUpgradeable.UintSet groupList;

135:     EnumerableSetUpgradeable.UintSet poolList;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/types/DataTypes.sol)

```solidity
File: src/yield/YieldAccount.sol

36:   function initialize(address _registry, address _manager) public initializer {

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldAccount.sol)

```solidity
File: src/yield/YieldRegistry.sol

4: import {EnumerableSetUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

5: import {ClonesUpgradeable} from '@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol';

6: import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

7: import {PausableUpgradeable} from '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';

8: import {ReentrancyGuardUpgradeable} from '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';

19: contract YieldRegistry is IYieldRegistry, PausableUpgradeable, ReentrancyGuardUpgradeable {

20:   using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

29:   EnumerableSetUpgradeable.AddressSet internal yieldManagers;

48:     _disableInitializers();

51:   function initialize(address addressProvider_) public initializer {

54:     __Pausable_init();

55:     __ReentrancyGuard_init();

64:     address yieldAccount = ClonesUpgradeable.clone(yieldAccountImplementation);

65:     YieldAccount(payable(yieldAccount)).initialize(address(this), _manager);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldRegistry.sol)

```solidity
File: src/yield/YieldStakingBase.sol

8: import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

9: import {PausableUpgradeable} from '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';

10: import {ReentrancyGuardUpgradeable} from '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';

28: abstract contract YieldStakingBase is Initializable, PausableUpgradeable, ReentrancyGuardUpgradeable {

94:   function __YieldStakingBase_init(address addressProvider_, address underlyingAsset_) internal onlyInitializing {

95:     __Pausable_init();

96:     __ReentrancyGuard_init();

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/YieldStakingBase.sol)

```solidity
File: src/yield/etherfi/YieldEthStakingEtherfi.sol

35:     _disableInitializers();

38:   function initialize(address addressProvider_, address weth_, address liquidityPool_) public initializer {

43:     __YieldStakingBase_init(addressProvider_, weth_);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/etherfi/YieldEthStakingEtherfi.sol)

```solidity
File: src/yield/lido/YieldEthStakingLido.sol

33:     _disableInitializers();

36:   function initialize(address addressProvider_, address weth_, address stETH_, address unstETH_) public initializer {

42:     __YieldStakingBase_init(addressProvider_, weth_);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/lido/YieldEthStakingLido.sol)

```solidity
File: src/yield/sdai/YieldSavingsDai.sol

34:     _disableInitializers();

37:   function initialize(address addressProvider_, address dai_, address sdai_) public initializer {

43:     __YieldStakingBase_init(addressProvider_, dai_);

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/yield/sdai/YieldSavingsDai.sol)

### <a name="L-14"></a>[L-14] A year is not always 365 days
On leap years, the number of days is 366, so calculations during those years will return the wrong value

*Instances (1)*:
```solidity
File: src/libraries/math/MathUtils.sol

14:   uint256 internal constant SECONDS_PER_YEAR = 365 days;

```
[Link to code](https://github.com/code-423n4/2024-07-benddao/blob/main/src/libraries/math/MathUtils.sol)
