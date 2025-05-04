// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ExchangeFactory {
    mapping(address => address) public exchangeFor;
    address[] public allExchanged;

    event ExchangeCreated(
        address indexed token,
        address echange,
        uint256 exchangeId
    );

    function exchangeCount() external view returns (uint256) {
        return allExchanged.length;
    }

    function createExchange() external returns (address) {
        // TODO: Implement createExchange function
        // Requirements:
        // 1. Verify token address is not zero
        // 2. Verify exchange doesn't already exist for this token
        // 3. Create a new Exchange contract
        // 4. Initialize the Exchange with the token address
        // 5. Store the exchange address in the mapping
        // 6. Add to allExchanges array
        // 7. Emit ExchangeCreated event
        // 8. Return the new exchange address
    }
}
