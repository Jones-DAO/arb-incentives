// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {MiniChefV2} from "src/sushi/MiniChefV2.sol";
import {IRewarder} from "src/sushi/IRewarder.sol";

contract UpdateWeights is Script {
    // The amount of allocation points assigned to the pool. Also known as the amount of ARB to distribute per block.
    uint256 glpAllocPoint = 3939; // 39,39% GLP // Update
    uint256 usdcAllocPoint = 3939; // 39,39% USDC // Update
    uint256 auraAllocPoint = 2122; // 21.22 % jAURA // Update

    MiniChefV2 public farm = MiniChefV2(0x0aEfaD19aA454bCc1B1Dd86e18A7d58D0a6FAC38);

    function run() public {
        vm.startBroadcast();

        // Update pool weight for jGLP
        farm.set(0, glpAllocPoint, IRewarder(address(0)), false);
        farm.updatePool(0);

        // Update pool weight for jUSDC
        farm.set(1, usdcAllocPoint, IRewarder(address(0)), false);
        farm.updatePool(1);

        // Update pool weight for wjAura
        farm.set(2, auraAllocPoint, IRewarder(address(0)), false);
        farm.updatePool(2);

        vm.stopBroadcast();
    }
}
