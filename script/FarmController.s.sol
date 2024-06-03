// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {MiniChefV2} from "src/sushi/MiniChefV2.sol";
import {IERC20} from "src/sushi/IERC20.sol";
import {TransparentUpgradeableProxy} from "openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {FarmController} from "src/governor/FarmController.sol";
import {Governable} from "src/common/Governable.sol";

contract FarmControllerDeploy is Script {
    address public proxyAdmin = 0xcC21349b6B1C82530d5Da6ed310380d980F75497;

    address public farm;
    
    uint256 public deadline;
    
    address public gov = 0x4817cA4DF701d554D78Aa3d142b62C162C682ee1;

    address public multisig = 0xFa82f1bA00b0697227E2Ad6c668abb4C50CA0b1F;

    address public incentiveReceiver = 0x5A446ba4D4BF482a3E63648E76E9404E784f7BbC; // jGLP/jUSDC Incentive receiver

    IERC20 public constant ARB = IERC20(0x912CE59144191C1204E64559FE8253a0e49E6548);

    function run() public returns (FarmController) {
        require(deadline != 0, "deadline not set");

        vm.startBroadcast(gov);
        console2.log("Deploying from:", msg.sender);

        farm = address(new MiniChefV2(ARB, incentiveReceiver, deadline));

        console2.log("Farm address:", address(farm));

        FarmController controller =
            FarmController(address(new TransparentUpgradeableProxy(address(new FarmController()), gov, "")));
        console2.log("Farm Controller address:", address(controller));

        controller.initialize(multisig, farm, deadline);

        Governable(farm).updateGovernor(address(controller));

        vm.stopBroadcast();

        return controller;
    }
}
