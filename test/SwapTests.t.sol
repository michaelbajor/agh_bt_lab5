// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Exchange.t.sol";

contract SwapTests is BaseExchangeTest {
    function testSwapDeadline() public {
        // Try to swap with expired deadline
        vm.prank(user1);
        vm.expectRevert("DEADLINE_EXPIRED");
        exchange.ethToTokenSwap{value: 1 ether}(
            1, // Min tokens out
            block.timestamp - 1 // Expired deadline
        );
    }

    function getKValue() internal view returns (uint256, uint256, uint256) {
        (uint256 ethReserve, uint256 tokenReserve) = exchange.getReserves();
        uint256 k = ethReserve * tokenReserve;
        return (ethReserve, tokenReserve, k);
    }

    function testPricingEqualValue() public {
        uint256 liquidityToAdd = 1000000000;
        vm.prank(owner);
        exchange.addLiquidity{value: liquidityToAdd}(
            1,
            liquidityToAdd,
            block.timestamp + 300
        );

        // equal liquidity for each asset so price is equal
        uint256 ethToSwap = 1000;
        uint256 userEthBalanceBefore = user1.balance;
        uint256 userTokenBalanceBefore = token.balanceOf(user1);

        vm.prank(user1);
        uint256 tokensBought = exchange.ethToTokenSwap{value: ethToSwap}(
            1,
            block.timestamp + 300
        );

        uint256 userEthBalanceAfter = user1.balance;
        uint256 userTokenBalanceAfter = token.balanceOf(user1);

        assertEq(userEthBalanceAfter, userEthBalanceBefore - ethToSwap);
        assertEq(userTokenBalanceAfter, userTokenBalanceBefore + tokensBought);
        // equal pricing so we spend 1000, we get 1000 back, but there is a 0.3% fee, so that's 997, but due to rounding it's going to be 996
        assertEq(tokensBought, 996);
    }

    function testPricingTwiceAsMuch() public {
        uint256 ethLiquidityToAdd = 1000000000;
        uint256 tokenLiquidityToAdd = ethLiquidityToAdd / 2;
        vm.prank(owner);
        exchange.addLiquidity{value: ethLiquidityToAdd}(
            1,
            tokenLiquidityToAdd,
            block.timestamp + 300
        );

        uint256 ethToSwap = 1000;
        uint256 userEthBalanceBefore = user1.balance;
        uint256 userTokenBalanceBefore = token.balanceOf(user1);

        vm.prank(user1);
        uint256 tokensBought = exchange.ethToTokenSwap{value: ethToSwap}(
            1,
            block.timestamp + 300
        );

        uint256 userEthBalanceAfter = user1.balance;
        uint256 userTokenBalanceAfter = token.balanceOf(user1);
        assertEq(userEthBalanceAfter, userEthBalanceBefore - ethToSwap);
        assertEq(userTokenBalanceAfter, userTokenBalanceBefore + tokensBought);

        // there's half as much tokens in the liquidity as there is ETH
        // which means the price is 1 token = 0.5 ETH, but 0.3% fee and rounding means we get 498
        assertEq(tokensBought, 498);
    }

    function testPricingTwiceAsMuch2() public {
        uint256 ethLiquidityToAdd = 1000000000;
        uint256 tokenLiquidityToAdd = 2 * ethLiquidityToAdd;
        vm.prank(owner);
        exchange.addLiquidity{value: ethLiquidityToAdd}(
            1,
            tokenLiquidityToAdd,
            block.timestamp + 300
        );

        uint256 ethToSwap = 1000;
        uint256 userEthBalanceBefore = user1.balance;
        uint256 userTokenBalanceBefore = token.balanceOf(user1);

        vm.prank(user1);
        uint256 tokensBought = exchange.ethToTokenSwap{value: ethToSwap}(
            1,
            block.timestamp + 300
        );

        uint256 userEthBalanceAfter = user1.balance;
        uint256 userTokenBalanceAfter = token.balanceOf(user1);
        assertEq(userEthBalanceAfter, userEthBalanceBefore - ethToSwap);
        assertEq(userTokenBalanceAfter, userTokenBalanceBefore + tokensBought);

        // there's half as much ETH in the liquidity as there is tokens
        // which means the price is 1 ETH = 2 tokens, but 0.3% fee and rounding means we get 1993
        assertEq(tokensBought, 1993);
    }

    function testSwapEthToToken() public {
        addInitialLiquidity();

        uint256 ethToSwap = 1000;
        uint256 userEthBalanceBefore = user1.balance;
        uint256 userTokenBalanceBefore = token.balanceOf(user1);

        vm.prank(user1);
        uint256 tokensBought = exchange.ethToTokenSwap{value: ethToSwap}(
            1,
            block.timestamp + 300
        );

        uint256 userEthBalanceAfter = user1.balance;
        uint256 userTokenBalanceAfter = token.balanceOf(user1);
        assertEq(userEthBalanceAfter, userEthBalanceBefore - ethToSwap);
        assertEq(userTokenBalanceAfter, userTokenBalanceBefore + tokensBought);
        assertEq(tokensBought, 1993999);
    }

    function testSwapTokenToEth() public {
        addInitialLiquidity();

        uint256 tokensToSwap = 200 * 10 ** 18;
        uint256 userEthBalanceBefore = user1.balance;
        uint256 userTokenBalanceBefore = token.balanceOf(user1);

        vm.prank(user1);
        uint256 ethBought = exchange.tokenToEthSwap(
            tokensToSwap,
            1,
            block.timestamp + 300
        );

        uint256 userEthBalanceAfter = user1.balance;
        uint256 userTokenBalanceAfter = token.balanceOf(user1);
        assertEq(userEthBalanceAfter, userEthBalanceBefore + ethBought);
        assertEq(userTokenBalanceAfter, userTokenBalanceBefore - tokensToSwap);
        assertEq(ethBought, 97750848089103280);
    }

    function testInsufficientOutputAmount() public {
        addInitialLiquidity();

        // price of a token is so low, that 1000 is not even 1 wei
        uint256 tokensToSwap = 1000;
        vm.prank(user1);
        vm.expectRevert();
        exchange.tokenToEthSwap(tokensToSwap, 1, block.timestamp + 300);
    }

    function testInsufficientInputAmount() public {
        addInitialLiquidity();

        uint256 tokensToSwap = 0;
        vm.prank(user1);
        vm.expectRevert();
        exchange.tokenToEthSwap(tokensToSwap, 1, block.timestamp + 300);
    }

    function testConstantProductFormula() public {
        addInitialLiquidity();

        // Get initial state
        (uint256 ethReserve, uint256 tokenReserve) = exchange.getReserves();
        uint256 initialK = ethReserve * tokenReserve;

        // Perform a swap
        uint256 ethAmount = 1.5 ether;
        vm.prank(user1);
        exchange.ethToTokenSwap{value: ethAmount}(
            1, // Min tokens out
            block.timestamp + 300 // Deadline
        );

        // Get state after swap
        (uint256 newEthReserve, uint256 newTokenReserve) = exchange
            .getReserves();
        uint256 newK = newEthReserve * newTokenReserve;

        // mathematically the K value should be the same, but in practice, when you take a fee and rounding down, it will be increasing with each trade
        assertGe(newK, initialK, "oops");
    }
}
