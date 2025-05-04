// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Exchange} from "../src/Exchange.sol";
import {ExchangeFactory} from "../src/ExchangeFactory.sol";
import {TestToken} from "../src/TestToken.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BaseExchangeTest is Test {
    ExchangeFactory public factory;
    IERC20 public token;
    Exchange public exchange;

    address public owner;
    address public user1;
    address public user2;

    uint256 public constant INITIAL_LIQUIDITY_ETH = 5 ether;
    uint256 public constant INITIAL_LIQUIDITY_TOKENS = 10000 * 10 ** 18;

    uint256 public constant TOKEN_TOTAL_SUPPLY =
        100000 * 10 ** 18 + 50000 * 10 ** 18 + 50000 * 10 ** 18;

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        vm.deal(owner, 10000 ether);
        vm.deal(user1, 1000 ether);
        vm.deal(user2, 1000 ether);

        // deploying contracts
        factory = new ExchangeFactory();

        vm.startPrank(owner);
        token = new TestToken("Test token", "TST", TOKEN_TOTAL_SUPPLY);
        token.transfer(user1, 50000 * 10 ** 18);
        token.transfer(user2, 50000 * 10 ** 18);
        vm.stopPrank();

        address exchangeAddr = factory.createExchange(address(token));
        exchange = Exchange(payable(exchangeAddr));

        // approving exchange to spend tokens. Normally you never want to approve for max, but this is for test convenience
        vm.prank(owner);
        token.approve(address(exchange), type(uint256).max);
        vm.prank(user1);
        token.approve(address(exchange), type(uint256).max);
        vm.prank(user2);
        token.approve(address(exchange), type(uint256).max);

        // sanity checks
        assertEq(token.balanceOf(owner), 100000 * 10 ** 18);
        assertEq(token.balanceOf(user1), 50000 * 10 ** 18);
        assertEq(token.balanceOf(user2), 50000 * 10 ** 18);
    }

    function addInitialLiquidity() internal {
        // Add initial liquidity as owner
        vm.prank(owner);
        exchange.addLiquidity{value: INITIAL_LIQUIDITY_ETH}(
            1,
            INITIAL_LIQUIDITY_TOKENS,
            block.timestamp + 300
        );
    }
}
