// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("MockERC20", "MOCK") {
        _mint(msg.sender, 1_000_000_000e18);
    }
}
