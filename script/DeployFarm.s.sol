// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {MiniChefV2, IERC20, IRewarder} from "src/sushi/MiniChefV2.sol";

contract DeployFarm is Script {
    MiniChefV2 mc2;
    address mockerc20 = 0x86694d3dB6BC2CCEcdE8EFEc6A0A993cAEd5678b;
    address deployer = 0x970AE3e4cAa2DcA8dF567D565dcD3550972B86F2;

    // Thu Oct 03 2024 22:20:04 GMT+0000
    uint256 endTimestamp = 1727994004;

    function run() external {
        vm.startBroadcast(deployer);

        // mc2 = new MiniChefV2(IERC20(mockerc20), deployer, endTimestamp);

        // console2.log("Mock minichefv2 = ", address(mc2));

        _addPool();

        vm.stopBroadcast();
    }

    function _addPool() private {
        address mockDeployment = 0xA826aF3a783B0b71B6593b0F86053B3FbA1D1c58;

        MiniChefV2(mockDeployment).add(1000, IERC20(mockerc20), IRewarder(address(0)), 0);

        IERC20(mockerc20).approve(mockDeployment, 1000e18);

        MiniChefV2(mockDeployment).deposit(0, 1000e18, deployer);
    }
}
