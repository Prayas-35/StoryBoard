// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract StoryToken is ERC20, Ownable {
    using Math for uint256;

    // Custom errors for gas efficiency
    error StoryToken__PresaleEnded();
    error StoryToken__PresaleOngoing();
    error StoryToken__InsufficientBalance();
    error StoryToken__InsufficientTokens();
    error StoryToken__InsufficientFunds();
    error StoryToken__ZeroTokenAmount();
    error StoryToken__ContractInsufficientFunds();

    // Tokenomics
    uint256 public constant PRESALE_PRICE = 10000; // 10 STORY per 1 POL (1 ETH)
    uint256 public constant POL_UNIT = 1 ether;
    uint256 public constant BURN_RATE = 2; // 2% burn per transaction
    uint256 public constant SCALE_FACTOR = 10; // Logarithmic scaling factor
    uint256 public presaleEndTime;
    uint256 public totalSupplyCap = 1_000_000 * 10 ** 18; // Max token supply

    bool public presaleActive = true;

    event TokensPurchased(
        address indexed buyer,
        uint256 amount,
        uint256 polSpent
    );
    event TokensSold(
        address indexed seller,
        uint256 amount,
        uint256 polReceived
    );

    /**
     * @dev Deploys the StoryToken contract.
     * @param _presaleDuration Duration of the presale in seconds.
     * @param initialOwner Address of the initial owner.
     */
    constructor(
        uint256 _presaleDuration,
        address initialOwner
    ) ERC20("StoryToken", "$STORY") Ownable(initialOwner) {
        _mint(address(this), totalSupplyCap); // Mint total supply to contract
        presaleEndTime = block.timestamp + _presaleDuration;
    }

    /**
     * @dev Modifier to ensure that the function is called only during the presale.
     */
    modifier onlyDuringPresale() {
        if (!presaleActive || block.timestamp > presaleEndTime)
            revert StoryToken__PresaleEnded();
        _;
    }

    /**
     * @dev Modifier to ensure that the function is called only after the presale has ended.
     */
    modifier onlyAfterPresale() {
        if (presaleActive && block.timestamp <= presaleEndTime)
            revert StoryToken__PresaleOngoing();
        _;
    }

    /**
     * @dev Allows users to buy tokens during the presale period.
     */
    function buyPresaleTokens() external payable onlyDuringPresale {
        uint256 storyAmount = msg.value * PRESALE_PRICE;
        if (balanceOf(address(this)) < storyAmount)
            revert StoryToken__InsufficientTokens();
        _update(address(this), msg.sender, storyAmount);
        emit TokensPurchased(msg.sender, storyAmount, msg.value);
    }

    /**
     * @dev Ends the presale period. Only callable by the owner.
     */
    function endPresale() external onlyOwner {
        presaleActive = false;
    }

    /**
     * @dev Calculates the token price using a bonding curve.
     * @param tokenAmount The number of tokens to buy.
     * @return The required POL (ETH) amount.
     */
    function bondingCurvePrice(
        uint256 tokenAmount
    ) public view onlyAfterPresale returns (uint256) {
        if (tokenAmount == 0) revert StoryToken__ZeroTokenAmount();
        uint256 basePrice = 1 ether;
        uint256 logValue = Math.log10(tokenAmount + 1);
        return basePrice * logValue * SCALE_FACTOR;
    }

    /**
     * @dev Allows users to buy tokens after the presale period at the bonding curve price.
     */
    function buyTokens() external payable onlyAfterPresale {
        if (msg.value == 0) revert StoryToken__InsufficientFunds();

        uint256 tokenAmount = msg.value / bondingCurvePrice(1); // Calculate tokens based on price per token
        if (tokenAmount == 0) revert StoryToken__ZeroTokenAmount();
        if (balanceOf(address(this)) < tokenAmount)
            revert StoryToken__InsufficientTokens();

        _update(address(this), msg.sender, tokenAmount);
        emit TokensPurchased(msg.sender, tokenAmount, msg.value);
    }

    /**
     * @dev Allows users to sell tokens after the presale period at the bonding curve price.
     * @param tokenAmount The number of tokens to sell.
     */
    function sellTokens(uint256 tokenAmount, address to) external {
        if (balanceOf(msg.sender) < tokenAmount)
            revert StoryToken__InsufficientBalance();

        _update(msg.sender, to, tokenAmount);

        emit TokensSold(msg.sender, tokenAmount, tokenAmount);
    }

    // function sellForNow(uint256 tokenAmount) external {
    //     if (balanceOf(msg.sender) < tokenAmount)
    //         revert StoryToken__InsufficientBalance();

    //     uint256 polAmount = bondingCurvePrice(tokenAmount);
    //     if (address(this).balance < polAmount)
    //         revert StoryToken__ContractInsufficientFunds();

    //     _update(msg.sender, address(this), tokenAmount);
    //     emit TokensSold(msg.sender, tokenAmount, polAmount);
    // }

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
     * @return The current price in POL (ETH).
     */
    function getCurrentPrice() external view returns (uint256) {
        return bondingCurvePrice(totalSupply());
    }
}
