// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {MiniChefV2} from "src/sushi/MiniChefV2.sol";
import {IRewarder} from "src/sushi/IRewarder.sol";
import {FarmController} from "src/governor/FarmController.sol";

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import {IERC20} from "src/sushi/IERC20.sol";

contract UpdateWeights is Script {
    using FixedPointMathLib for uint256;

    address public multisig = 0xFa82f1bA00b0697227E2Ad6c668abb4C50CA0b1F;

    address public jonesDeployer = 0x4817cA4DF701d554D78Aa3d142b62C162C682ee1;

    IERC20 public constant ARB = IERC20(0x912CE59144191C1204E64559FE8253a0e49E6548);

    /// @notice GMT+0000: Friday 29 March 2024 23:59:59
    uint256 newDeadline = 1711756799;

    // Set Arb per second
    uint256 arbPerSecond;

    // The amount of allocation points assigned to the pool. Also known as the amount of ARB to distribute per block.
    uint256 glpAllocPoint = 6826; // 68.26% GLP // Update
    uint256 usdcAllocPoint = 3174; // 31.74% USDC // Update
    uint256 auraAllocPoint = 0; // 0 % jAURA // Update

    MiniChefV2 public farm = MiniChefV2(0x0aEfaD19aA454bCc1B1Dd86e18A7d58D0a6FAC38);

    FarmController public controller = FarmController(0x5A8546A65baeAeccEad910c8Bd5C088f813C87CC);

    function run() public {
        vm.startBroadcast(jonesDeployer);

        // @notice current balance + 350k allocation to MV2
        uint256 totalIncentives = ARB.balanceOf(address(farm)) + 350_000e18;

        arbPerSecond = totalIncentives.mulDivDown(1, newDeadline - block.timestamp);

        /// @notice set deadline to infinite
        controller.setDeadline(newDeadline);

        // Update pool weight for jGLP
        farm.updatePool(0);
        controller.set(0, glpAllocPoint, IRewarder(address(0)), false);

        // Update pool weight for jUSDC
        farm.updatePool(1);
        controller.set(1, usdcAllocPoint, IRewarder(address(0)), false);

        // Update pool weight for wjAura
        farm.updatePool(2);
        controller.set(2, auraAllocPoint, IRewarder(address(0)), false);

        // Update Rewards
        controller.setSushiPerSecond(arbPerSecond);

        // Return Governor to Multisig
        controller.updateGovernor(multisig);

        vm.stopBroadcast();
    }
}
