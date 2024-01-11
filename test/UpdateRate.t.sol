// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, Vm, StdCheats, StdUtils} from "forge-std/Test.sol";

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {console2} from "forge-std/console2.sol";
import {MiniChefV2} from "src/sushi/MiniChefV2.sol";
import {UpdateWeights} from "script/UpdateWeights.s.sol";
import {IERC20} from "src/sushi/IERC20.sol";

contract UpdateRateTest is Test {
    using FixedPointMathLib for uint256;

    MiniChefV2 public farm = MiniChefV2(0x0aEfaD19aA454bCc1B1Dd86e18A7d58D0a6FAC38);

    address public jGLPStaker = 0x28d5fA40b3Ca8B6c1D5934fcEc6c58361F749B54;

    address public jUSDCStaker = 0x6ff42899f4da584a7eBc166CeECd74715FF5B828;

    address public wjAuraStaker = 0x36cc7B13029B5DEe4034745FB4F24034f3F2ffc6;

    address public gov = 0x5A8546A65baeAeccEad910c8Bd5C088f813C87CC;

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


        /// @notice Labels
        vm.label(address(ARB), "$ARB");
        vm.label(address(jGLP), "$jGLP");
        vm.label(address(jUSDC), "$jUSDC");
        vm.label(address(jGLP), "$jGLP");
        vm.label(address(wjAura), "$wjAura");

        /// @notice Labels
        vm.label(address(farm), "FARM CONTRACT");
    }

    function test_jglp_rate_change() public {

        address jGLPAddress = address(jGLP);

        uint256 _poolID = poolID[jGLPAddress];

        vm.startPrank(gov, gov);
        farm.updatePool(_poolID);
        vm.stopPrank();

        uint256 pendingArbBefore = farm.pendingSushi(_poolID, jGLPStaker);

        UpdateWeights script = new UpdateWeights();

        script.run();
      
        uint256 pendingArbAfter = farm.pendingSushi(_poolID, jGLPStaker);

        console2.log("pendingArbBefore", pendingArbBefore);

        console2.log("pendingArbAfter", pendingArbAfter);

        assertGt(pendingArbBefore, 0);
        assertEq(pendingArbBefore, pendingArbAfter);

        /// @notice Go forward to old deadline
        vm.warp(block.timestamp + 1);
    }

    function test_jusdc_rate_change() public {

        address jUSDCAddress = address(jUSDC);

        uint256 _poolID = poolID[jUSDCAddress];

        vm.startPrank(gov, gov);
        farm.updatePool(_poolID);
        vm.stopPrank();

        uint256 pendingArbBefore = farm.pendingSushi(_poolID, jUSDCStaker);

        UpdateWeights script = new UpdateWeights();

        script.run();
      
        uint256 pendingArbAfter = farm.pendingSushi(_poolID, jUSDCStaker);

        console2.log("pendingArbBefore", pendingArbBefore);

        console2.log("pendingArbAfter", pendingArbAfter);

        assertGt(pendingArbBefore, 0);
        assertEq(pendingArbBefore, pendingArbAfter);

        /// @notice Go forward to old deadline
        vm.warp(block.timestamp + 1);
    }

     function test_wjaura_rate_change() public {

        address wjAuraAddress = address(wjAura);

        uint256 _poolID = poolID[wjAuraAddress];

        vm.startPrank(gov, gov);
        farm.updatePool(_poolID);
        vm.stopPrank();

        uint256 pendingArbBefore = farm.pendingSushi(_poolID, wjAuraStaker);

        UpdateWeights script = new UpdateWeights();

        script.run();
      
        uint256 pendingArbAfter = farm.pendingSushi(_poolID, wjAuraStaker);

        console2.log("pendingArbBefore", pendingArbBefore);

        console2.log("pendingArbAfter", pendingArbAfter);

        assertGt(pendingArbBefore, 0);
        assertEq(pendingArbBefore, pendingArbAfter);

        /// @notice Go forward to old deadline
        vm.warp(block.timestamp + 1);
    }
}
