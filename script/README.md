# How to run the script

## env

fill .env file at project root.

## Install new modules

. ./setup-env.sh && forge script ./script/InstallModule.s.sol -vvvvv --private-key ${PRIVATE_KEY} --etherscan-api-key ${ETHERSCAN_KEY} --rpc-url sepolia --broadcast --slow --verify

## Query

forge script ./script/QueryPool.s.sol --rpc-url sepolia -vvvvv
