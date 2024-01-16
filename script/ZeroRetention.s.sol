// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

import {FarmController} from "src/governor/FarmController.sol";

contract ZeroRetentionScript is Script {
    address public multisig = 0xFa82f1bA00b0697227E2Ad6c668abb4C50CA0b1F;

    address public jonesDeployer = 0x4817cA4DF701d554D78Aa3d142b62C162C682ee1;

    FarmController public controller = FarmController(0x5A8546A65baeAeccEad910c8Bd5C088f813C87CC);

    function run() public {
        vm.startBroadcast(jonesDeployer);

        /// @notice Tirn deposit Incentives OFF
        controller.toggleIncentives();

        /// @notice Return Governor to Multisig
        controller.updateGovernor(multisig);

        vm.stopBroadcast();
    }
}
