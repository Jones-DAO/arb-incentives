// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, Vm, StdCheats, StdUtils} from "forge-std/Test.sol";

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {console2} from "forge-std/console2.sol";
import {MiniChefV2} from "src/sushi/MiniChefV2.sol";
import {Governable} from "src/common/Governable.sol";
import {FarmControllerDeploy} from "script/FarmController.s.sol";
import {FarmController} from "src/governor/FarmController.sol";
import {IERC20} from "src/sushi/IERC20.sol";

contract FarmControllerTest is Test {
    using FixedPointMathLib for uint256;

    MiniChefV2 public farm = MiniChefV2(0x0aEfaD19aA454bCc1B1Dd86e18A7d58D0a6FAC38);

    address public alice = makeAddr("alice");

    address public gov = 0x4817cA4DF701d554D78Aa3d142b62C162C682ee1;

    uint256 deadline = 1706745599;

    FarmController public controller;

    /// @notice token address => pid
    mapping(address => uint256) public poolID;

    IERC20 public constant ARB = IERC20(0x912CE59144191C1204E64559FE8253a0e49E6548);
    IERC20 public constant jGLP = IERC20(0x7241bC8035b65865156DDb5EdEf3eB32874a3AF6);
    IERC20 public constant jUSDC = IERC20(0xe66998533a1992ecE9eA99cDf47686F4fc8458E0);
    IERC20 public constant wjAura = IERC20(0xcB9295ac65De60373A25C18d2044D517ed5da8A9);

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("arbitrum"), 159778901);

        FarmControllerDeploy script = new FarmControllerDeploy();

        controller = script.run();

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
        vm.label(address(controller), "CONTROLLER");
    }

    function test_finish_rewards(uint256 _amount) public {
        _amount = bound(_amount, 1e16, 500_000e18);

        console2.log("_amount", _amount);

        address jGLPAddress = address(jGLP);

        uint256 _poolID = poolID[jGLPAddress];

        _deposit(alice, _amount, jGLPAddress);

        uint256 oldjGLPBalance = jGLP.balanceOf(alice);
        uint256 oldArbBalance = ARB.balanceOf(alice);

        (uint256 amount,) = farm.userInfo(_poolID, alice);

        /// @notice Go forward to old deadline
        vm.warp(deadline + 1);

        uint256 pendingArbBefore = farm.pendingSushi(_poolID, alice);

        console2.log("pendingArbBefore", pendingArbBefore);

        /// @notice Finish Rewards
        controller.finishRewards();

        /// @notice Go forward 1 week
        vm.warp(deadline + 1 weeks + 1);

        /// @notice Withdraw

        uint256 pendingArbAfter = farm.pendingSushi(_poolID, alice);

        console2.log("pendingArbAfter", pendingArbAfter);

        vm.startPrank(alice, alice);

        farm.withdrawAndHarvest(_poolID, amount, alice);

        vm.stopPrank();

        uint256 newjGLPBalance = jGLP.balanceOf(alice);
        uint256 newArbBalance = ARB.balanceOf(alice);

        assertGt(newjGLPBalance, oldjGLPBalance);
        assertEq(pendingArbAfter, 0);
        assertGt(pendingArbBefore, 0);
        assertEq(oldArbBalance, newArbBalance);
    }

    function test_should_revert_for_timestamp_finish_rewards() public {
        /// @notice Finish Rewards Must Revert
        vm.expectRevert(FarmController.TooEarly.selector);
        controller.finishRewards();
    }

    function _deposit(address _user, uint256 _amount, address _asset) private {
        deal(_asset, _user, _amount);

        vm.startPrank(_user, _user);

        IERC20(_asset).approve(address(farm), _amount);

        farm.deposit(poolID[_asset], _amount, _user);

        vm.stopPrank();
    }
}
