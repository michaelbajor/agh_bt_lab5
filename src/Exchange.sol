// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Exchange is ERC20, ReentrancyGuard {
    IERC20 public token; // ERC20 token traded against ETH
    address public factory;
    uint256 ethReserve;

    event TokenPurchase(
        address indexed buyer,
        uint256 ethSold,
        uint256 tokensBought
    );
    event EthPurchase(
        address indexed buyer,
        uint256 tokensSold,
        uint256 ethBought
    );
    event AddLiquidity(
        address indexed provider,
        uint256 ethAmount,
        uint256 tokenAmount
    );
    event RemoveLiquidity(
        address indexed provider,
        uint256 ethAmount,
        uint256 tokenAmount
    );

    modifier onlyFactory() {
        require(msg.sender == factory, "FORBIDDEN");
        _;
    }

    constructor() ERC20("LP token", "LP") {
        factory = msg.sender;
    }

    function initialize(address _token) external onlyFactory {
        require(_token != address(0), "INVALID_TOKEN");
        token = IERC20(_token);
    }

    function getReserves()
        public
        view
        returns (uint256 _ethReserve, uint256 tokenReserve)
    {
        _ethReserve = ethReserve;
        tokenReserve = token.balanceOf(address(this));
    }

    receive() external payable {
        revert("REJECT_DIRECT_TRANSFER");
    }

    fallback() external payable {
        revert("REJECT_DIRECT_TRANSFER");
    }

    /**
     * @dev Add liquidity to the exchange
     * @param _minLiquidity Minimum LP tokens to mint
     * @param _maxTokens Maximum tokens to deposit
     * @param _deadline Transaction deadline timestamp
     * @return liquidity Amount of LP tokens minted
     */
    function addLiquidity(
        uint256 _minLiquidity,
        uint256 _maxTokens,
        uint256 _deadline
    ) external payable nonReentrant returns (uint256 liquidity) {
        // TODO: Implement adding liquidity
        // 1. Verify deadline

        // 2. Get current reserves
        (uint256 _ethReserve, uint256 tokenReserve) = getReserves();

        // 3. Handle first liquidity provision and
        if (_ethReserve == 0 && tokenReserve == 0) {
            // First liquidity provision
            // Token amount is determined by sender
            // Transfer tokens from sender to exchange
            // Initial liquidity is set to ETH contributed
            // Update ETH reserve (internal accounting)
            // Mint LP tokens
            // Emit event
        } else {
            // Subsequent liquidity provision
            // Maintain price by keeping the ratio consistent
            // Calculate liquidity amount
            // Transfer tokens from sender to exchange
            // Update ETH reserve (internal accounting)
            // Mint LP tokens
            // Emit event
        }
    }

    /**
     * @dev Remove liquidity from the exchange
     * @param _amount Amount of LP tokens to burn
     * @param _minEth Minimum ETH to receive
     * @param _minTokens Minimum tokens to receive
     * @param _deadline Transaction deadline timestamp
     * @return ethAmount Amount of ETH received
     * @return tokenAmount Amount of tokens received
     */
    function removeLiquidity(
        uint256 _amount,
        uint256 _minEth,
        uint256 _minTokens,
        uint256 _deadline
    ) external nonReentrant returns (uint256 ethAmount, uint256 tokenAmount) {
        // TODO: Implement removing liquidity
        // 1. Verify deadline
        // 2. Verify non-zero amount
        // 3. Get total supply
        // 4. Calculate token and ETH amounts based on proportion of liquidity
        // 5. Verify minimum outputs
        // 6. Burn LP tokens
        // 7. Update ETH reserve (internal accounting)
        // 8. Transfer ETH and tokens to user
        // 9. Emit event
        // 10. Return amounts
    }

    /**
     * @dev Calculate tokens out for a given ETH input
     * @param _ethSold Amount of ETH sold
     * @return tokensOut Amount of tokens that can be bought
     */
    function getEthToTokenInputPrice(
        uint256 _ethSold
    ) public view returns (uint256 tokensOut) {
        // TODO: Implement price calculation
        // 1. Verify input amount
        // 2. Get reserves
        // 3. Verify reserves
        // 4. Calculate using constant product formula
        // Input reserve: _ethReserve
        // Output reserve: tokenReserve
        // Fee: 0.3%
        // Apply fee of 0.3%
        // 5. Return amount of bought tokens
    }

    /**
     * @dev Calculate ETH out for a given token input
     * @param _tokensSold Amount of tokens sold
     * @return ethOut Amount of ETH that can be bought
     */
    function getTokenToEthInputPrice(
        uint256 _tokensSold
    ) public view returns (uint256 ethOut) {
        // TODO: Implement price calculation
        // 1. Verify input amount
        // 2. Get reserves
        // 3. Verify reserves
        // 4. Calculate using constant product formula
        // Input reserve: tokenReserve
        // Output reserve: _ethReserve
        // Fee: 0.3%
        // Apply fee of 0.3%
        // 5. Return amount of bought ETH
    }

    /**
     * @dev Swap ETH for tokens
     * @param _minTokens Minimum tokens to receive
     * @param _deadline Transaction deadline timestamp
     * @return tokenAmount Amount of tokens bought
     */
    function ethToTokenSwap(
        uint256 _minTokens,
        uint256 _deadline
    ) external payable nonReentrant returns (uint256 tokenAmount) {
        // TODO: Implement ETH to token swap
        // 1. Verify deadline
        // 2. Verify non-zero input
        // 3. Calculate output amount
        // 4. Verify minimum tokens out
        // 5. Update ETH reserve (internal accounting)
        // 6. Transfer tokens to buyer
        // 7. Emit event
        // 8. Return token amount
    }

    /**
     * @dev Swap tokens for ETH
     * @param _tokensSold Amount of tokens sold
     * @param _minEth Minimum ETH to receive
     * @param _deadline Transaction deadline timestamp
     * @return ethAmount Amount of ETH bought
     */
    function tokenToEthSwap(
        uint256 _tokensSold,
        uint256 _minEth,
        uint256 _deadline
    ) external nonReentrant returns (uint256 ethAmount) {
        // TODO: Implement token to ETH swap
        // 1. Verify deadline
        // 2. Verify non-zero input
        // 3. Calculate output amount
        // 4. Verify minimum ETH out
        // 5. Transfer tokens from sender to exchange
        // 6. Update ETH reserve (internal accounting)
        // 7. Transfer ETH to buyer
        // 8. Emit event
        // 9. Return ETH amount
    }
}
