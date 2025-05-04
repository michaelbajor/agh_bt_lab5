// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Exchange.t.sol";

contract FactoryTest is BaseExchangeTest {
    function testCreateExchange() public {
        // Create a new token
        TestToken newToken = new TestToken("New Token", "NEW", 18);

        // Create exchange for the new token
        address exchangeAddress = factory.createExchange(address(newToken));

        // Verify the exchange was created
        assertEq(factory.exchangeFor(address(newToken)), exchangeAddress);
        assertEq(factory.allExchanges(0), address(exchange));
        assertEq(factory.allExchanges(1), exchangeAddress);
        assertEq(factory.exchangeCount(), 2);
    }

    function testCannotCreateExchangeForZeroAddress() public {
        // Attempt to create an exchange for the zero address
        vm.expectRevert("INVALID_TOKEN");
        factory.createExchange(address(0));
    }

    function testCannotCreateDuplicateExchange() public {
        // Attempt to create an exchange for a token that already has one
        vm.expectRevert("EXCHANGE_EXISTS");
        factory.createExchange(address(token));
    }

    function testCannotReinitializeExchange() public {
        vm.expectRevert("FORBIDDEN");
        exchange.initialize(address(token));
    }
}
