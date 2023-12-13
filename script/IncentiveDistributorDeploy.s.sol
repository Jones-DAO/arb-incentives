// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {MiniChefV2} from "src/sushi/MiniChefV2.sol";
import {IERC20} from "src/sushi/IERC20.sol";
import {IRewarder} from "src/sushi/IRewarder.sol";

contract IncentiveDistributorDeploy is Script {
    using FixedPointMathLib for uint256;

    IERC20 public constant ARB = IERC20(0x912CE59144191C1204E64559FE8253a0e49E6548);

    MiniChefV2 public farm;

    address public incentiveReceiver = 0x5A446ba4D4BF482a3E63648E76E9404E784f7BbC; // jGLP/jUSDC Incentive receiver

    function run() public {
        vm.startBroadcast();
        console2.log("Deploying from:", msg.sender);

        farm = new MiniChefV2(ARB, incentiveReceiver);
        console2.log("Farm address:", address(farm));

        vm.stopBroadcast();
    }
}
