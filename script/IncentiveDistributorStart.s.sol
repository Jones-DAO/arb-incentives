// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {MiniChefV2} from "src/sushi/MiniChefV2.sol";
import {IERC20} from "src/sushi/IERC20.sol";
import {IRewarder} from "src/sushi/IRewarder.sol";

contract IncentiveDistributorStart is Script {
    using FixedPointMathLib for uint256;

    IERC20 public constant jGLP = IERC20(0x7241bC8035b65865156DDb5EdEf3eB32874a3AF6);
    IERC20 public constant jUSDC = IERC20(0xe66998533a1992ecE9eA99cDf47686F4fc8458E0);
    IERC20 public constant wjAura = IERC20(0xcB9295ac65De60373A25C18d2044D517ed5da8A9);

    MiniChefV2 public farm = MiniChefV2(0x0aEfaD19aA454bCc1B1Dd86e18A7d58D0a6FAC38);

    uint256 constant ACC_SUSHI_PRECISION = 1e12;

    /// @notice GMT: Wednesday, 31 January 2024 23:59:59
    uint256 deadline = 1706745599;

    /// @notice 2M - 350k allocation to MV2
    uint256 totalIncentives = 1_650_000e18;

    // Set Arb per second
    uint256 arbPerSecond = totalIncentives.mulDivDown(1, deadline - block.timestamp);

    // The amount of allocation points assigned to the pool. Also known as the amount of ARB to distribute per block.
    uint256 glpAllocPoint = 6302; // 63,02% GLP
    uint256 usdcAllocPoint = 1576; // 15,76% USDC
    uint256 auraAllocPoint = 2122; // 21.22 % jAURA

    address public farmAddress = 0x0aEfaD19aA454bCc1B1Dd86e18A7d58D0a6FAC38; // Update

    uint256 glpDepositIncentives = ACC_SUSHI_PRECISION.mulDivDown(2, 100); // 2%
    uint256 usdcDepositIncentives = ACC_SUSHI_PRECISION / 100; // 1%
    uint256 auraDepositIncentives; // 0%

    function run() public {
        vm.startBroadcast();

        // Create pool for jGLP
        farm.add(glpAllocPoint, jGLP, IRewarder(address(0)), glpDepositIncentives);

        // Create pool for jUSDC
        farm.add(usdcAllocPoint, jUSDC, IRewarder(address(0)), usdcDepositIncentives);

        // Create pool for wjAura
        farm.add(auraAllocPoint, wjAura, IRewarder(address(0)), auraDepositIncentives);

        farm.setSushiPerSecond(arbPerSecond);

        vm.stopBroadcast();
    }
}
