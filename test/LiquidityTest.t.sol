// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Exchange.t.sol";

contract LiquidityTest is BaseExchangeTest {
    function testInitialLiquidityProvision() public {
        // Verify initial state
        (uint256 ethReserve, uint256 tokenReserve) = exchange.getReserves();
        assertEq(ethReserve, 0);
        assertEq(tokenReserve, 0);
        assertEq(exchange.totalSupply(), 0);

        // Add initial liquidity
        uint256 ethAmount = 2 ether;
        uint256 tokenAmount = 1000 * 10 ** 18;

        vm.prank(owner);
        uint256 liquidity = exchange.addLiquidity{value: ethAmount}(
            1, // Min liquidity
            tokenAmount, // Max tokens
            block.timestamp + 300 // Deadline
        );

        // Verify state after adding liquidity
        (ethReserve, tokenReserve) = exchange.getReserves();
        assertEq(ethReserve, ethAmount);
        assertEq(tokenReserve, tokenAmount);

        // For first liquidity, LP tokens = ETH amount - MINIMUM_LIQUIDITY
        assertEq(liquidity, ethAmount);
        assertEq(exchange.balanceOf(owner), liquidity);

        // Verify total supply
        assertEq(exchange.totalSupply(), ethAmount);
    }

    function testSubsequentLiquidityProvision() public {
        // Add initial liquidity
        addInitialLiquidity();

        // Get initial state
        (uint256 ethReserve, uint256 tokenReserve) = exchange.getReserves();
        uint256 initialTotalSupply = exchange.totalSupply();

        // Add more liquidity with user1
        uint256 ethAmount = 1 ether;
        uint256 expectedTokenAmount = (ethAmount * tokenReserve) / ethReserve;

        vm.prank(user1);
        uint256 liquidity = exchange.addLiquidity{value: ethAmount}(
            1, // Min liquidity
            expectedTokenAmount * 2,
            block.timestamp + 300
        );

        // Verify state after adding liquidity
        (uint256 newEthReserve, uint256 newTokenReserve) = exchange
            .getReserves();
        assertEq(newEthReserve, ethReserve + ethAmount);
        assertEq(newTokenReserve, tokenReserve + expectedTokenAmount);

        // For subsequent liquidity, LP tokens = (ETH added * totalSupply) / ETH reserve
        uint256 expectedLiquidity = (ethAmount * initialTotalSupply) /
            ethReserve;
        assertEq(liquidity, expectedLiquidity);
        assertEq(exchange.balanceOf(user1), expectedLiquidity);
    }

    function testRemoveLiquidity() public {
        // Add initial liquidity
        addInitialLiquidity();

        // Get initial state
        (uint256 ethReserve, uint256 tokenReserve) = exchange.getReserves();
        uint256 initialTotalSupply = exchange.totalSupply();
        uint256 liquidityToRemove = exchange.balanceOf(owner) / 2; // Remove half

        // Calculate expected amounts
        uint256 expectedEthAmount = (liquidityToRemove * ethReserve) /
            initialTotalSupply;
        uint256 expectedTokenAmount = (liquidityToRemove * tokenReserve) /
            initialTotalSupply;

        // Approve exchange to spend LP tokens
        vm.prank(owner);
        exchange.approve(address(exchange), liquidityToRemove);

        // Remove liquidity
        vm.prank(owner);
        (uint256 ethAmount, uint256 tokenAmount) = exchange.removeLiquidity(
            liquidityToRemove,
            1,
            1,
            block.timestamp + 300
        );

        // Verify returned amounts
        assertEq(ethAmount, expectedEthAmount);
        assertEq(tokenAmount, expectedTokenAmount);

        // Verify state after removing liquidity
        (uint256 newEthReserve, uint256 newTokenReserve) = exchange
            .getReserves();
        assertEq(newEthReserve, ethReserve - ethAmount);
        assertEq(newTokenReserve, tokenReserve - tokenAmount);
        assertEq(
            exchange.totalSupply(),
            initialTotalSupply - liquidityToRemove
        );
    }

    function testDeadlineExpired() public {
        // Try to add liquidity with expired deadline
        vm.expectRevert();
        exchange.addLiquidity{value: 1 ether}(
            1,
            1000 * 10 ** 18,
            block.timestamp - 1 // Expired deadline
        );
    }

    function testMinimumLiquidityRequirement() public {
        // Add initial liquidity
        addInitialLiquidity();

        // Calculate the smallest amount that would create less than minLiquidity
        (uint256 ethReserve, ) = exchange.getReserves();
        uint256 totalSupply = exchange.totalSupply();
        uint256 minLiquidity = 100;

        // Calculate ETH needed to produce minLiquidity tokens
        uint256 ethNeeded = (minLiquidity * ethReserve) / totalSupply;

        // Provide slightly less than needed
        uint256 ethAmount = ethNeeded - 1;

        // Try to add liquidity with too small amount
        vm.startPrank(user1);
        vm.expectRevert();
        exchange.addLiquidity{value: ethAmount}(
            minLiquidity, // Min liquidity
            1000 * 10 ** 18, // Max tokens
            block.timestamp + 300 // Deadline
        );
        vm.stopPrank();
    }

    function testInsufficientTokensProvided() public {
        // Add initial liquidity
        addInitialLiquidity();

        // Calculate required token amount for 1 ETH
        (uint256 ethReserve, uint256 tokenReserve) = exchange.getReserves();
        uint256 ethAmount = 1 ether;
        uint256 requiredTokens = (ethAmount * tokenReserve) / ethReserve;

        // Try to add liquidity with insufficient max tokens
        vm.startPrank(user1);
        vm.expectRevert();
        exchange.addLiquidity{value: ethAmount}(
            1, // Min liquidity
            requiredTokens - 1, // Less than required
            block.timestamp + 300 // Deadline
        );
        vm.stopPrank();
    }

    function testInternalEthAccountingMatchesExpected() public {
        // Add initial liquidity
        addInitialLiquidity();

        // Get initial state
        (uint256 ethReserve, uint256 tokenReserve) = exchange.getReserves();
        console.logUint(tokenReserve);
        assertEq(ethReserve, INITIAL_LIQUIDITY_ETH);

        // Add more liquidity
        uint256 additionalEth = 1 ether;
        uint256 expectedTokenAmount = (additionalEth * tokenReserve) /
            ethReserve;
        console.logUint(expectedTokenAmount);

        vm.prank(owner);
        exchange.addLiquidity{value: additionalEth}(
            1, // Min liquidity
            expectedTokenAmount,
            block.timestamp + 300 // Deadline
        );

        // Verify ETH accounting is updated correctly
        (ethReserve, ) = exchange.getReserves();
        assertEq(ethReserve, INITIAL_LIQUIDITY_ETH + additionalEth);
        assertEq(
            address(exchange).balance,
            INITIAL_LIQUIDITY_ETH + additionalEth
        );
    }
}
