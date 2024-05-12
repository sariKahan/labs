// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@labs/staking/MyToken.sol";
import "@labs/AMM/Amm.sol";
import "forge-std/Test.sol";

contract TestAmm is Test {
    MyToken tokenA;
    MyToken tokenB;
    Amm amm;
    uint256 wad = 1e18;
    address user1;
    address user2;

    function setUp() public {
        tokenA = new MyToken();
        tokenB = new MyToken();
        amm = new Amm(address(tokenA), address(tokenB));
        user1 = vm.addr(1);
        user2 = vm.addr(2);
    }

    function testCalcCount() public {
        assertEq(amm.calcCount(60 * wad, 50 * wad, 10 * wad, 1), 8333333333333333330);
        assertEq(amm.calcCount(60 * wad, 50 * wad, 10 * wad, 2), 12000000000000000000);
    }

    function test() public {
        add(5 * wad, 5 * wad);
        tradeAToB(2 * wad);
        vm.startPrank(user1);
        uint256 amount = amm.calcCountB(2 * wad);
        add(2 * wad, amount);
        amm.removeAllLiquidity();
        vm.stopPrank();
        amm.removeAllLiquidity();
        assertEq(amm.totalLiquidity(), 0);
    }

    function add(uint256 amount0, uint256 amount1) private {
        tokenA.mint(amount0);
        tokenA.approve(address(amm), amount0);
        tokenB.mint(amount1);
        tokenB.approve(address(amm), amount1);
        amm.addLiquidity(amount0, amount1);
    }

    function tradeAToB(uint256 amount) private {
        tokenA.mint(amount);
        tokenA.approve(address(amm), amount);
        amm.tradeAToB(amount);
    }

    function tradeBToA(uint256 amount) private {
        tokenB.mint(amount);
        tokenB.approve(address(amm), amount);
        amm.tradeBToA(amount);
    }
}
