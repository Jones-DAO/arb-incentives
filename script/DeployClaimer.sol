// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import {MockERC20} from "src/common/MockERC20.sol";
import {ArbStip} from "src/common/ArbStip.sol";

contract DeployClaimer is Script {
    address keeper = 0x785177E9A02fe80fC27890AeCd5d196b6F704e9b;
    address initialOwner = 0x4817cA4DF701d554D78Aa3d142b62C162C682ee1;

    address arb = 0x912CE59144191C1204E64559FE8253a0e49E6548;
    ArbStip claimer;

    address internal DEPLOYER = 0x4817cA4DF701d554D78Aa3d142b62C162C682ee1;

    function run() external {
        vm.startBroadcast(DEPLOYER);

        require(initialOwner != address(0));
        require(keeper != address(0));

        address[] memory supported_ = new address[](1);
        supported_[0] = address(arb);

        claimer = new ArbStip(supported_, keeper, initialOwner);

        vm.stopBroadcast();
    }
}
