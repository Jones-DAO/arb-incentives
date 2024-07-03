// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

contract Farm {
    mapping(uint256 => uint256) public idToWeight;

    /**
     * @notice Rebalance managed by keeper
     * @param pids Pids of the pools to rebalance
     * @param allocPoints New weights
     */
    function batchUpdatePoolAndSetWeights(uint256[] calldata pids, uint256[] calldata allocPoints) external {
        uint256 len = pids.length;
        for (uint256 i = 0; i < len; ++i) {
            idToWeight[pids[i]] = allocPoints[i];
        }
    }
}

contract MockFarm is Script {
    Farm public farm;

    function run() public {
        vm.startBroadcast();
        farm = new Farm();
        vm.stopBroadcast();
    }
}
