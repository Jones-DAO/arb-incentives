// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {TransparentUpgradeableProxy} from "openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {FarmController} from "src/governor/FarmController.sol";

import {Governable} from "src/common/Governable.sol";

contract FarmControllerDeploy is Script {
    address public proxyAdmin = 0xcC21349b6B1C82530d5Da6ed310380d980F75497;

    address public farm = 0x0aEfaD19aA454bCc1B1Dd86e18A7d58D0a6FAC38;

    address public gov = 0x4817cA4DF701d554D78Aa3d142b62C162C682ee1;

    address public multisig = 0xFa82f1bA00b0697227E2Ad6c668abb4C50CA0b1F;

    function run() public returns (FarmController) {
        vm.startBroadcast(gov);
        console2.log("Deploying from:", msg.sender);

        FarmController controller =
            FarmController(address(new TransparentUpgradeableProxy(address(new FarmController()), proxyAdmin, "")));

        controller.initialize(multisig, farm);

        Governable(farm).updateGovernor(address(controller));

        console2.log("Farm Cotroller address:", address(farm));

        vm.stopBroadcast();

        return controller;
    }
}
