// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {MockERC20} from "src/common/MockERC20.sol";
import {MockClaimer} from "src/common/MockClaimer.sol";

contract DeployMockClaimer is Script {
    address keeper;
    MockERC20 mockErc20;
    MockClaimer mockClaimer;

    function run() external {
        vm.startBroadcast();

        mockErc20 = new MockERC20();

        address[] memory supported_ = new address[](1);
        supported_[0] = address(mockErc20);

        mockClaimer = new MockClaimer(supported_, keeper);

        vm.stopBroadcast();
    }
}
