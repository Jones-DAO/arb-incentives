pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {MiniChefV2} from "src/sushi/MiniChefV2.sol";
import {Governable} from "src/common/Governable.sol";

contract StopRewardsScript is Script {
    address public constant governor = 0x4817cA4DF701d554D78Aa3d142b62C162C682ee1;

    MiniChefV2 public farm = MiniChefV2(0x0aEfaD19aA454bCc1B1Dd86e18A7d58D0a6FAC38);

    function run(address gov) public {
        vm.startBroadcast(gov);

        /// @notice set deadline to infinite
        farm.setDeadline(type(uint256).max);

        /// @notice set rewards to 0
        farm.setSushiPerSecond(0);

        /// @notice update governor to multisig
        Governable(address(farm)).updateGovernor(governor);

        vm.stopBroadcast();
    }
}
