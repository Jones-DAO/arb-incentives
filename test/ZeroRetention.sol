// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, Vm, StdCheats, StdUtils} from "forge-std/Test.sol";

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {console2} from "forge-std/console2.sol";
import {MiniChefV2} from "src/sushi/MiniChefV2.sol";
import {ZeroRetentionScript} from "script/ZeroRetention.s.sol";

import {FarmController} from "src/governor/FarmController.sol";
import {IERC20} from "src/sushi/IERC20.sol";

contract ZeroRetentionTest is Test {
    using FixedPointMathLib for uint256;

    MiniChefV2 public farm = MiniChefV2(0x0aEfaD19aA454bCc1B1Dd86e18A7d58D0a6FAC38);

    FarmController public controller = FarmController(0x5A8546A65baeAeccEad910c8Bd5C088f813C87CC);

    address public jGLPStaker = 0x28d5fA40b3Ca8B6c1D5934fcEc6c58361F749B54;

    address public jUSDCStaker = 0x6ff42899f4da584a7eBc166CeECd74715FF5B828;

    address public wjAuraStaker = 0x36cc7B13029B5DEe4034745FB4F24034f3F2ffc6;

    address public multisig = 0xFa82f1bA00b0697227E2Ad6c668abb4C50CA0b1F;

    address jonesDeployer = 0x4817cA4DF701d554D78Aa3d142b62C162C682ee1;

    /// @notice token address => pid
    mapping(address => uint256) public poolID;

    IERC20 public constant ARB = IERC20(0x912CE59144191C1204E64559FE8253a0e49E6548);
    IERC20 public constant jGLP = IERC20(0x7241bC8035b65865156DDb5EdEf3eB32874a3AF6);
    IERC20 public constant jUSDC = IERC20(0xe66998533a1992ecE9eA99cDf47686F4fc8458E0);
    IERC20 public constant wjAura = IERC20(0xcB9295ac65De60373A25C18d2044D517ed5da8A9);

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("arbitrum"), 169490082);

        poolID[address(jGLP)] = 0;
        poolID[address(jUSDC)] = 1;
        poolID[address(wjAura)] = 2;

        vm.startPrank(multisig, multisig);
        controller.updateGovernor(jonesDeployer);
        vm.stopPrank();

        /// @notice Labels
        vm.label(address(ARB), "$ARB");
        vm.label(address(jGLP), "$jGLP");
        vm.label(address(jUSDC), "$jUSDC");
        vm.label(address(jGLP), "$jGLP");
        vm.label(address(wjAura), "$wjAura");

        /// @notice Labels
        vm.label(address(farm), "FARM CONTRACT");
    }

    function test_zero_retention() public {
        ZeroRetentionScript script = new ZeroRetentionScript();

        script.run();

        /// @notice Go forward to old deadline
        vm.warp(block.timestamp + 1);
    }
}
