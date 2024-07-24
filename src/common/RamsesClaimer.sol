// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Claimer} from "src/common/Claimer.sol";

contract RamsesClaimer is Claimer {
    constructor(address keeper, address initialOwner) Claimer("Ramses Claimer", keeper, initialOwner) {}
}
