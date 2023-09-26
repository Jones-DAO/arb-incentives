#/bin/bash

. ./.env

args="--rpc-url $RPC_URL --private-key $DEPLOYER_KEY --etherscan-api-key $ETHERSCAN_API_KEY"

forge script script/IncentiveDistributor.s.sol:IncentiveDistributor $args -vv