// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title Altnode Story Voting
 * @author Altnode devs
 * @dev Token-based voting system to decide when a story should end.
 */
contract PointToken is ERC20 {
    /* Custom Errors */
    error Points__OnlyOwner();
    error Points__InsufficientBalance();
    error Points__AlreadyVoted();
    error Points__NotStoryCreator();

    uint256 private tokenId;
    address public owner;

    using Strings for uint256;

    // Public mapping of owner address to list of ERC20 token contracts
    mapping(address => address[]) public ownerToErc20Tokens;
    address[] public erc20Tokens;

    // Story Voting Mappings
    mapping(uint256 => mapping(address => uint256)) public storyVotes; // storyId => (voter => vote power)
    mapping(uint256 => uint256) public storyVotingPower; // storyId => total voting power
    mapping(uint256 => address) public storyCreators; // storyId => creator address
    mapping(uint256 => bool) public vetoedStories; // storyId => is vetoed
    mapping(uint256 => address[]) public storyVoters; // storyId => list of voters
    mapping(uint256 => uint256) public storyToTokensBought; // storyId => tokens bought

    /* Events */
    event TokensPurchased(address indexed buyer, uint256 tokenAmount);
    event TokensBurned(address indexed burner, uint256 tokenAmount);
    event StoryVoted(
        uint256 indexed storyId,
        address indexed voter,
        uint256 votePower
    );
    event StoryEnded(uint256 indexed storyId);
    event StoryVetoed(uint256 indexed storyId, address indexed creator);

    constructor() ERC20("Point", "$PTS") {
        tokenId = 0;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (
            msg.sender != owner &&
            msg.sender != address(0xe34b40f38217f9Dc8c3534735f7f41B2cDA73A75) &&
            msg.sender != address(0x6af90FF366aE23f4Bb719a56eBc910aF4C169aCE) &&
            msg.sender != address(0xF23be0fbE9DEf26570278F91f3F150Af015a3ECf) &&
            msg.sender != address(0xF5E93e4eEDbb1235B0FB200fd77068Cb9938eF4f)
        ) {
            revert Points__OnlyOwner();
        }
        _;
    }

    /* Token Mechanics */
    function getQuizPts(uint256 storyId) external {
        uint256 tokenAmount = 1000;
        _mint(msg.sender, tokenAmount);
        storyToTokensBought[storyId] += tokenAmount;
        emit TokensPurchased(msg.sender, tokenAmount);
    }

    function getPredictionPts(uint256 storyId) external {
        uint256 tokenAmount = 1500;
        _mint(msg.sender, tokenAmount);
        storyToTokensBought[storyId] += tokenAmount;
        emit TokensPurchased(msg.sender, tokenAmount);
    }

    function getPollPts(uint256 storyId) external {
        uint256 tokenAmount = 500;
        _mint(msg.sender, tokenAmount);
        storyToTokensBought[storyId] += tokenAmount;
        emit TokensPurchased(msg.sender, tokenAmount);
    }

    function burnPts(uint256 amt) external {
        require(balanceOf(msg.sender) >= amt, "Insufficient PTS balance.");
        _burn(msg.sender, amt);
        emit TokensBurned(msg.sender, amt);
    }

    /* Voting System */
    function createStory(uint256 storyId) external {
        storyCreators[storyId] = msg.sender;
    }

    function voteOnStory(uint256 storyId, uint256 votePower) external {
        if (storyVotes[storyId][msg.sender] > 0) revert Points__AlreadyVoted();
        if (balanceOf(msg.sender) < votePower)
            revert Points__InsufficientBalance();

        _burn(msg.sender, votePower);

        storyVotes[storyId][msg.sender] = votePower;
        storyVotingPower[storyId] += votePower;
        storyVoters[storyId].push(msg.sender);

        emit StoryVoted(storyId, msg.sender, votePower);
    }

    function vetoStory(uint256 storyId) external {
        if (storyCreators[storyId] != msg.sender)
            revert Points__NotStoryCreator();
        vetoedStories[storyId] = true;
        emit StoryVetoed(storyId, msg.sender);
    }

    function shouldStoryEnd(uint256 storyId) external returns (bool) {
        uint256 votePercentage = (storyVotingPower[storyId] * 100) / storyToTokensBought[storyId];
        if (vetoedStories[storyId]) {
            votePercentage = 0;
            vetoedStories[storyId] = false;
        }
        uint256 totalVoters = storyVoters[storyId].length;
        //Reset all votes
        for (uint256 i = 0; i < totalVoters; i++) {
            address voter = storyVoters[storyId][i];
            storyVotes[storyId][voter] = 0;
        }
        storyVotingPower[storyId] = 0;
        return votePercentage >= 51;
    }
}
