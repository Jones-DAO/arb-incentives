// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Claimer} from "src/common/Claimer.sol";

contract MockClaimer is Claimer {
    constructor(address[] memory supportedAssets, address keeper) Claimer(supportedAssets, "MockFarm", keeper) {}
}
