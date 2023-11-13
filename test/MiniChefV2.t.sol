// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, Vm, StdCheats, StdUtils} from "forge-std/Test.sol";

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {console2} from "forge-std/console2.sol";
import {MiniChefV2} from "src/Sushi/MiniChefV2.sol";
import {IRewarder} from "src/Sushi/IRewarder.sol";
import {IERC20} from "src/Sushi/IERC20.sol";

contract MiniChefV2Test is Test {
    using FixedPointMathLib for uint256;

    address public gov = makeAddr("gov");
    address public alice = makeAddr("alice");

    MiniChefV2 public farm;

    address public incentiveReceiver = 0x8Cf4F0BA114bfC15faBDf0DdC0A7b7eD5399Af5f;
    uint256 public depositIncentives = 3e12 / 100;

    IERC20 public constant ARB = IERC20(0x912CE59144191C1204E64559FE8253a0e49E6548);
    IERC20 public constant jGLP = IERC20(0x7241bC8035b65865156DDb5EdEf3eB32874a3AF6);
    IERC20 public constant jUSDC = IERC20(0xe66998533a1992ecE9eA99cDf47686F4fc8458E0);
    IERC20 public constant wjAura = IERC20(0x873066F098E6A3A4FEbF65c9e437F7F71C8ef314);

    uint256 deadline = 1706745599;
    uint256 totalIncentives = 1_650_000e18;
    // token address => pid
    mapping(address => uint256) public poolID;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("arbitrum"), 134806168);

        vm.startPrank(gov, gov);

        farm = new MiniChefV2(ARB, incentiveReceiver);
        uint256 allocPoint; // The amount of allocation points assigned to the pool. Also known as the amount of ARB to distribute per block.

        // Labels
        vm.label(address(farm), "FARM CONTRACT");
        vm.label(address(ARB), "$ARB");
        vm.label(address(jGLP), "$jGLP");
        vm.label(address(jUSDC), "$jUSDC");
        vm.label(address(jGLP), "$jGLP");
        vm.label(address(wjAura), "$wjAura");

        // Create pool for jGLP
        allocPoint = 3939;
        farm.add(allocPoint, jGLP, IRewarder(address(0)), depositIncentives);
        poolID[address(jGLP)] = 0;

        // Create pool for jUSDC
        allocPoint = 3939;
        farm.add(allocPoint, jUSDC, IRewarder(address(0)), depositIncentives);
        poolID[address(jUSDC)] = 1;

        // Create pool for wjAura
        allocPoint = 2122;
        farm.add(allocPoint, wjAura, IRewarder(address(0)), depositIncentives);
        poolID[address(wjAura)] = 2;

        // Set Arb per second
        uint256 _arbPerSecond = totalIncentives.mulDivDown(1, deadline - block.timestamp);
        farm.setSushiPerSecond(_arbPerSecond);

        deal(address(ARB), address(farm), totalIncentives);

        vm.stopPrank();
    }

    function test_stake(uint256 _amount) public {
        _amount = bound(_amount, 1e16, 20_000_000e18);

        console2.log("_amount", _amount);

        _deposit(alice, _amount, address(jGLP));

        (uint256 amount,) = farm.userInfo(poolID[address(jGLP)], alice);

        address jGLPAddress = address(jGLP);

        uint256 incentive = IERC20(jGLPAddress).balanceOf(incentiveReceiver);

        assertEq(amount, _amount - incentive);
    }

    function test_harvest(uint256 _amount) public {
        _amount = bound(_amount, 1e16, 20_000_000e18);

        console2.log("_amount", _amount);

        address jGLPAddress = address(jGLP);

        uint256 _poolID = poolID[jGLPAddress];

        _deposit(alice, _amount, jGLPAddress);

        (uint256 amount,) = farm.userInfo(_poolID, alice);

        uint256 incentive = IERC20(jGLPAddress).balanceOf(incentiveReceiver);

        console2.log("incentive", incentive);

        assertEq(amount, _amount - incentive);

        // 1 week later
        vm.warp(block.timestamp + 1 weeks + 1);

        uint256 pendingArb = farm.pendingSushi(_poolID, alice);

        console2.log("pendingArb", pendingArb);

        assertGt(pendingArb, 0);

        uint256 arbBefore = ARB.balanceOf(alice);

        vm.startPrank(alice, alice);

        farm.harvest(_poolID, alice);

        vm.stopPrank();

        uint256 arbAfter = ARB.balanceOf(alice);

        assertGt(arbAfter, arbBefore);
        assertEq(arbAfter, pendingArb);
    }

    function test_withdraw(uint256 _amount) public {
        _amount = bound(_amount, 1e16, 20_000_000e18);

        console2.log("_amount", _amount);

        address jGLPAddress = address(jGLP);

        uint256 _poolID = poolID[jGLPAddress];

        _deposit(alice, _amount, jGLPAddress);

        (uint256 amount,) = farm.userInfo(_poolID, alice);

        uint256 incentive = IERC20(jGLPAddress).balanceOf(incentiveReceiver);

        assertEq(incentive, (_amount * depositIncentives) / 1e12);

        assertEq(amount, _amount - incentive);

        // 1 week later
        vm.warp(block.timestamp + 1 weeks + 1);

        uint256 pendingArb = farm.pendingSushi(_poolID, alice);

        assertGt(pendingArb, 0);

        uint256 arbBefore = ARB.balanceOf(alice);

        vm.startPrank(alice, alice);

        farm.harvest(_poolID, alice);

        vm.stopPrank();

        uint256 arbAfter = ARB.balanceOf(alice);

        assertGt(arbAfter, arbBefore);
        assertEq(arbAfter, pendingArb);

        // 3 week later
        vm.warp(block.timestamp + 3 weeks + 1);

        vm.startPrank(alice, alice);

        farm.withdrawAndHarvest(_poolID, amount, alice);

        vm.stopPrank();

        assertLt(IERC20(jGLPAddress).balanceOf(alice), _amount);
    }

    function test_update_withdraw_incentives(uint256 _amount, uint256 _pid) public {
        _amount = bound(_amount, 3e11 / 100, 10e12 / 100);
        _pid = bound(_pid, 0, 2);

        vm.startPrank(gov, gov);

        farm.updatePoolIncentive(_pid, _amount);

        vm.stopPrank();

        (,,, uint256 _depositIncentives) = farm.poolInfo(_pid);

        assertEq(_depositIncentives, _amount);
    }

    function _deposit(address _user, uint256 _amount, address _asset) private {
        deal(_asset, _user, _amount);

        vm.startPrank(_user, _user);

        IERC20(_asset).approve(address(farm), _amount);

        farm.deposit(poolID[_asset], _amount, _user);

        vm.stopPrank();
    }
}
