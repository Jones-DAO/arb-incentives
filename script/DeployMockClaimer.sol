// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import {MockERC20} from "src/common/MockERC20.sol";
import {MockClaimer} from "src/common/MockClaimer.sol";

contract DeployMockClaimer is Script {
    address keeper = 0x20141635f40F9eA3EDA0eC4fa46E88A5A65AE99a;
    MockERC20 mockErc20;
    MockClaimer mockClaimer;

    address internal constant DEPLOYER = 0x970AE3e4cAa2DcA8dF567D565dcD3550972B86F2;

    function run() external {
        vm.startBroadcast(DEPLOYER);

        mockErc20 = new MockERC20();

        address[] memory supported_ = new address[](1);
        supported_[0] = address(mockErc20);

        mockClaimer = new MockClaimer(supported_, keeper);
        
        mockErc20.transfer(keeper, 100_000e18);

        console2.log("MockClaimer: ", address(mockClaimer));
        console2.log("mockErc20: ", address(mockErc20));

        vm.stopBroadcast();
    }
}
