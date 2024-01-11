// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {MiniChefV2} from "src/sushi/MiniChefV2.sol";
import {IRewarder} from "src/sushi/IRewarder.sol";

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

contract UpdateWeights is Script {
    using FixedPointMathLib for uint256;

    address public gov = 0x5A8546A65baeAeccEad910c8Bd5C088f813C87CC;

    /// @notice GMT+0000: Friday 29 March 2024 23:59:59
    uint256 newDeadline = 1711756799;

    // @notice 2M - 350k allocation to MV2
    uint256 totalIncentives = 350_000e18;

    // Set Arb per second
    uint256 arbPerSecond = totalIncentives.mulDivDown(1, newDeadline - block.timestamp);


    // The amount of allocation points assigned to the pool. Also known as the amount of ARB to distribute per block.
    uint256 glpAllocPoint = 5378; // 50% GLP // Update
    uint256 usdcAllocPoint = 2500; // 50% USDC // Update
    uint256 auraAllocPoint = 0; // 0 % jAURA // Update

    MiniChefV2 public farm = MiniChefV2(0x0aEfaD19aA454bCc1B1Dd86e18A7d58D0a6FAC38);

    function run() public {
        vm.startBroadcast(gov);

        /// @notice set deadline to infinite
        farm.setDeadline(newDeadline);

        // Update pool weight for jGLP
        farm.updatePool(0);
        farm.set(0, glpAllocPoint, IRewarder(address(0)), false);

        // Update pool weight for jUSDC
        farm.updatePool(1);
        farm.set(1, usdcAllocPoint, IRewarder(address(0)), false);

        // Update pool weight for wjAura
        farm.updatePool(2);
        farm.set(2, auraAllocPoint, IRewarder(address(0)), false);

        // Update Rewards
        farm.setSushiPerSecond(arbPerSecond);
        
        vm.stopBroadcast();
    }
}
