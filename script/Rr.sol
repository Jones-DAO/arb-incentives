// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import {MockERC20} from "src/common/MockERC20.sol";
import {Claimer} from "src/common/ArbStip.sol";
import {Test} from "forge-std/Test.sol";

contract M is Claimer {
    constructor(address[] memory distAsset, string memory farm, address keeper, address initialOwner) Claimer(distAsset, farm, keeper, initialOwner) {}
}
contract Rr is Script {
    Claimer cl = Claimer(0xbe7ad9b2F66508CE07BCB4C4BFA7afDA97aFE351);

    address sender = 0x970AE3e4cAa2DcA8dF567D565dcD3550972B86F2;
    address keeper = 0x785177E9A02fe80fC27890AeCd5d196b6F704e9b;
    address mocky = 0x86694d3dB6BC2CCEcdE8EFEc6A0A993cAEd5678b;

    function run() external{
        vm.startBroadcast();

        uint256[] memory amounts= new uint256[](1);
        bytes32[] memory proofs =new bytes32[](2);
        
        proofs[0] = 0xa7a1bcf7948f9a86354732d31802f299a0a465fef7c1929059ad4e059f336777;
        proofs[1] = 0xe6b3fec5d7b718d4bbd91eaa6d3bdd53257a4aba02d5122f3fd91005158720ea;

        amounts[0] = 375000000000000000000;

        cl.claim(amounts, proofs);

    }
}