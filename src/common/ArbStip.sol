// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Claimer} from "src/common/Claimer.sol";

contract ArbStip is Claimer {
    constructor(address keeper, address initialOwner) Claimer("Jones STIP Farm", keeper, initialOwner) {}
}
