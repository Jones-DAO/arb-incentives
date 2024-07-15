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

    IERC20 public constant jUSDC = IERC20(0xB0BDE111812EAC913b392D80D51966eC977bE3A2);

    MiniChefV2 public farm = MiniChefV2(0x7522E621f266bf5065fa9681Ce2B38f8eA6C7c74);

    // The amount of allocation points assigned to the pool. Also known as the amount of ARB to distribute per block.
    uint256 gmAllocPoint = 20_00; // 20% jGM
    uint256 usdcAllocPoint = 80_00; // 80% jUSDC

    function run() public {
        vm.startBroadcast();

        // Create pool for jUSDC
        farm.add(usdcAllocPoint, jUSDC, IRewarder(address(0)), 0);

        vm.stopBroadcast();
    }
}
