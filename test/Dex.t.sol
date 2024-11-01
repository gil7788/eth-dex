// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Dex.sol";
import "../src/Token1.sol";
import "../src/Token2.sol";

contract TestDex is Test {
    Dex private dex;
    Token1 private token1;
    Token2 private token2;
    address private owner;
    uint256 initialLiquidity;

    function setUp() public {
        owner = address(this);
        // uint256 token1Amount = 1000;
        // uint256 token2Amount = 1000;
        uint256 token1Amount = 1000 * 10 ** 18;
        uint256 token2Amount = 1000 * 10 ** 18;

        // Deploy Token1 and Token2 with an initial supply
        token1 = new Token1(token1Amount);
        token2 = new Token2(token2Amount);

        // Deploy Dex with token1 and token2 addresses
        dex = new Dex(address(token1), address(token2));

        // Approve Dex contract to transfer tokens on behalf of the owner
        token1.approve(address(dex), type(uint256).max);
        token2.approve(address(dex), type(uint256).max);

        // Transfer initial liquidity to the dex contract
        token1.transfer(address(dex), 500 * 10 ** 18);
        token2.transfer(address(dex), 500 * 10 ** 18);
        initialLiquidity = token1.balanceOf(address(dex)) * token2.balanceOf(address(dex));
    }

    function testProvideInitLiquidity() public {
        uint256 token1Amount = 100 * 10 ** 18;
        uint256 token2Amount = 100 * 10 ** 18;

        // Provide initial liquidity
        dex.provideInitLiqudity(token1Amount, token2Amount);

        // Check dex contract's balance for token1 and token2
        assertEq(token1.balanceOf(address(dex)), 600 * 10 ** 18);
        assertEq(token2.balanceOf(address(dex)), 600 * 10 ** 18);
    }

    function testSwapToken1ToToken2() public {
        uint256 amountToSwap = 10 * 10 ** 18;

        // Perform swap: token1 -> token2
        dex.swap(address(token1), address(token2), amountToSwap);

        // Check balances after swap
        assertEq(token1.balanceOf(owner), 490 * 10 ** 18); // 1000 - 10
        assertTrue(token2.balanceOf(owner) > 0); // Received some token2
        uint256 liquidity = token1.balanceOf(address(dex)) * token2.balanceOf(address(dex));
        assertGe(liquidity, initialLiquidity);
    }

    function testSwapToken2ToToken1() public {
        uint256 amountToSwap = 10 * 10 ** 18;

        // Perform swap: token2 -> token1
        dex.swap(address(token2), address(token1), amountToSwap);

        // Check balances after swap
        assertEq(token2.balanceOf(owner), 490 * 10 ** 18); // 1000 - 10
        assertTrue(token1.balanceOf(owner) > 0); // Received some token1
        uint256 liquidity = token1.balanceOf(address(dex)) * token2.balanceOf(address(dex));
        assertGe(liquidity, initialLiquidity);
    }

    function testAddLiquidityToken1() public {
        uint256 token1Amount = 50 * 10 ** 18;

        // Add liquidity for token1
        dex.addLiquidity(address(token1), token1Amount);

        // Check dex contract's token1 balance
        assertEq(token1.balanceOf(address(dex)), 550 * 10 ** 18);
    }

    function testAddLiquidityToken2() public {
        uint256 token2Amount = 50 * 10 ** 18;

        // Add liquidity for token2
        dex.addLiquidity(address(token2), token2Amount);

        // Check dex contract's token2 balance
        assertEq(token2.balanceOf(address(dex)), 550 * 10 ** 18);
    }

    function testFailSwapInvalidTokenPair() public {
        uint256 amountToSwap = 10 * 10 ** 18;

        // Attempt to swap between invalid tokens
        // vm.expectRevert("Invalid token pair");
        dex.swap(address(0), address(token1), amountToSwap);
    }

    function testFailAddLiquidityInvalidToken() public {
        uint256 amountToAdd = 50 * 10 ** 18;

        // Attempt to add liquidity with an invalid token
        // vm.expectRevert("Invalid token");
        dex.addLiquidity(address(0), amountToAdd);
    }

    /* ceilDiv */
    function testCeilDivZeroNominator() public view {
        uint256 result = dex.ceilDiv(0, 100);
        assertEq(result, 0);
    }

    function testCeilDivByZero() public {
        vm.expectRevert("Invalid division by 0");
        dex.ceilDiv(100, 0);
    }

    function testCeilDivOne() public view {
        uint256 result = dex.ceilDiv(1, 100);
        assertTrue(result == 1);
    }

    function testCeilDiv() public view {
        uint256 result = dex.ceilDiv(455, 100);
        assertTrue(result == 5);
    }
}
