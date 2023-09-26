// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, Vm, StdCheats} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {MiniChefV2} from "src/Sushi/MiniChefV2.sol";
import {IRewarder} from "src/Sushi/IRewarder.sol";
import {IERC20} from "src/Sushi/IERC20.sol";

contract MiniChefV2Test is Test {
    address public gov = makeAddr("gov");
    address public alice = makeAddr("alice");

    MiniChefV2 public farm;

    IERC20 public constant ARB = IERC20(0x912CE59144191C1204E64559FE8253a0e49E6548);
    IERC20 public constant jGLP = IERC20(0x7241bC8035b65865156DDb5EdEf3eB32874a3AF6);
    IERC20 public constant jUSDC = IERC20(0xe66998533a1992ecE9eA99cDf47686F4fc8458E0);
    IERC20 public constant wjAura = IERC20(0x873066F098E6A3A4FEbF65c9e437F7F71C8ef314);

    uint256 totalIncentives = 2_000_000e18;
    // token address => pid
    mapping(address => uint256) public poolID;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("arbitrum"), 134806168);

        vm.startPrank(gov, gov);

        farm = new MiniChefV2(ARB);
        uint256 allocPoint; // The amount of allocation points assigned to the pool. Also known as the amount of ARB to distribute per block.

        // Labels
        vm.label(address(farm), "FARM CONTRACT");
        vm.label(address(ARB), "$ARB");
        vm.label(address(jGLP), "$jGLP");
        vm.label(address(jUSDC), "$jUSDC");
        vm.label(address(jGLP), "$jGLP");
        vm.label(address(wjAura), "$wjAura");

        // Create pool for jGLP
        allocPoint = 4000;
        farm.add(allocPoint, jGLP, IRewarder(address(0)));
        poolID[address(jGLP)] = 0;

        // Create pool for jUSDC
        allocPoint = 1000;
        farm.add(allocPoint, jUSDC, IRewarder(address(0)));
        poolID[address(jUSDC)] = 1;

        // Create pool for wjAura
        allocPoint = 2000;
        farm.add(allocPoint, wjAura, IRewarder(address(0)));
        poolID[address(wjAura)] = 2;

        // Set Arb per second
        uint256 _arbPerSecond;
        farm.setSushiPerSecond(_arbPerSecond);

        deal(address(ARB), gov, totalIncentives);

        vm.stopPrank();
    }

    function test_stake(uint256 _amount) public {
        _deposit(alice, _amount, address(jGLP));

        (uint256 amount,) = farm.userInfo(poolID[address(jGLP)], alice);

        assertEq(amount, _amount);
    }

    function _deposit(address _user, uint256 _amount, address _asset) private {
        deal(_asset, _user, _amount);

        vm.startPrank(_user, _user);

        console2.log("_asset: ", _asset);

        console2.log("user balance: ", IERC20(_asset).balanceOf(_user));

        IERC20(_asset).approve(address(farm), _amount);

        console2.log("_user: ", _user);

        console2.log("farm: ", address(farm));

        console2.log("allowance: ", IERC20(_asset).allowance(_user, address(farm)));

        farm.deposit(poolID[_asset], _amount, _user);

        vm.stopPrank();
    }
}
