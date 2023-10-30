// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {MiniChefV2} from "src/Sushi/MiniChefV2.sol";
import {IERC20} from "src/Sushi/IERC20.sol";
import {IRewarder} from "src/Sushi/IRewarder.sol";

contract IncentiveDistributor is Script {
    using FixedPointMathLib for uint256;

    IERC20 public constant ARB = IERC20(0x912CE59144191C1204E64559FE8253a0e49E6548);
    IERC20 public constant jGLP = IERC20(0x7241bC8035b65865156DDb5EdEf3eB32874a3AF6);
    IERC20 public constant jUSDC = IERC20(0xe66998533a1992ecE9eA99cDf47686F4fc8458E0);
    IERC20 public constant wjAura = IERC20(0x873066F098E6A3A4FEbF65c9e437F7F71C8ef314);

    MiniChefV2 public farm;

    uint256 deadline = 1706745599;

    uint256 totalIncentives = 1_650_000e18;

    /// @notice 2M - 350k allocation to MV2

    // Set Arb per second
    uint256 arbPerSecond = totalIncentives.mulDivDown(1, deadline - block.timestamp);

    // The amount of allocation points assigned to the pool. Also known as the amount of ARB to distribute per block.
    uint256 glpAllocPoint = 3939; // 39,39% GLP
    uint256 usdcAllocPoint = 3939; // 39,39% USDC
    uint256 auraAllocPoint = 2122; // 21.22 % jAURA

    address public incentiveReceiver; // Update

    function run() public {
        vm.startBroadcast();

        farm = new MiniChefV2(ARB, incentiveReceiver);

        // Create pool for jGLP
        farm.add(glpAllocPoint, jGLP, IRewarder(address(0)));

        // Create pool for jUSDC
        farm.add(usdcAllocPoint, jUSDC, IRewarder(address(0)));

        // Create pool for wjAura
        farm.add(auraAllocPoint, wjAura, IRewarder(address(0)));

        farm.setSushiPerSecond(arbPerSecond);

        vm.stopBroadcast();
    }
}
