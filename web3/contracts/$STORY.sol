// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract StoryToken is ERC20, Ownable {
    using Math for uint256;

    // Custom errors for gas efficiency
    error StoryToken__InsufficientBalance();
    error StoryToken__InsufficientTokens();
    error StoryToken__InsufficientFunds();
    error StoryToken__ZeroTokenAmount();
    error StoryToken__ContractInsufficientFunds();

    // Tokenomics
    uint256 public constant BURN_RATE = 2; // 2% burn per transaction
    uint256 public constant SCALE_FACTOR = 10; // Logarithmic scaling factor
    uint256 public totalSupplyCap = 1_000_000 * 10 ** 18; // Max token supply

    event TokensPurchased(
        address indexed buyer,
        uint256 amount,
        uint256 ethSpent
    );
    event TokensSold(
        address indexed seller,
        uint256 amount,
        uint256 ethReceived
    );

    /**
     * @dev Deploys the StoryToken contract.
     * @param initialOwner Address of the initial owner.
     */
    constructor(
        address initialOwner
    ) ERC20("StoryToken", "$STORY") Ownable(initialOwner) {
        _mint(address(this), totalSupplyCap); // Mint total supply to contract
    }

    /**
     * @dev Calculates the token price using a bonding curve.
     * @param tokenAmount The number of tokens to buy.
     * @return The required ETH amount.
     */
    function bondingCurvePrice(
        uint256 tokenAmount
    ) public pure returns (uint256) {
        if (tokenAmount == 0) revert StoryToken__ZeroTokenAmount();
        uint256 basePrice = 1 ether;
        uint256 logValue = Math.log10(tokenAmount + 1);
        return basePrice * logValue * SCALE_FACTOR;
    }

    /**
     * @dev Allows users to buy tokens using ETH.
     */
    function buyTokens() external payable {
        if (msg.value == 0) revert StoryToken__InsufficientFunds();

        uint256 tokenAmount = msg.value / bondingCurvePrice(1); // Calculate tokens based on price per token
        if (tokenAmount == 0) revert StoryToken__ZeroTokenAmount();
        if (balanceOf(address(this)) < tokenAmount)
            revert StoryToken__InsufficientTokens();

        _update(address(this), msg.sender, tokenAmount);
        emit TokensPurchased(msg.sender, tokenAmount, msg.value);
    }

    /**
     * @dev Allows users to sell tokens back for ETH.
     * @param tokenAmount The number of tokens to sell.
     */
    function sellTokens(uint256 tokenAmount, address to) external {
        if (balanceOf(msg.sender) < tokenAmount)
            revert StoryToken__InsufficientBalance();

        _update(msg.sender, to, tokenAmount);
        emit TokensSold(msg.sender, tokenAmount, tokenAmount);
    }

    /**
     * @dev Internal function to handle token transfers and burn mechanism.
     * @param from Sender address.
     * @param to Recipient address.
     * @param amount Amount of tokens to transfer.
     */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (from != address(0) && to != address(0)) {
            uint256 burnAmount = (amount * BURN_RATE) / 100;
            uint256 sendAmount = amount - burnAmount;
            super._update(from, to, sendAmount);
            _burn(from, burnAmount);
        } else {
            super._update(from, to, amount);
        }
    }

    /**
     * @dev Retrieves the current price of the token based on total supply.
     * @return The current price in ETH.
     */
    function getCurrentPrice() external view returns (uint256) {
        return bondingCurvePrice(totalSupply());
    }

    /**
     * @dev Calculates the number of tokens that can be bought with a given ETH amount.
     * @param ethAmount The amount of ETH to spend.
     * @return The number of tokens that can be bought.
     */
    function getTokensForEth(
        uint256 ethAmount
    ) external pure returns (uint256) {
        if (ethAmount == 0) revert StoryToken__ZeroTokenAmount();
        return ethAmount / bondingCurvePrice(1 * 10 ** 18);
    }
}
