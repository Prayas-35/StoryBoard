// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract StoryTokenFactory {
    struct StoryToken {
        ERC20 token;
        address creator;
        uint256 totalTokensBought;
        uint256 votingPower;
        bool vetoed;
    }

    mapping(uint256 => StoryToken) public storyTokens;
    mapping(uint256 => mapping(address => uint256)) public storyVotes;
    mapping(uint256 => address[]) public storyVoters;

    event StoryTokenCreated(
        uint256 storyId,
        address tokenAddress,
        string name,
        string symbol,
        address creator
    );
    event TokensPurchased(uint256 storyId, address user, uint256 amount);
    event StoryVoted(uint256 storyId, address user, uint256 votePower);
    event StoryVetoed(uint256 storyId, address creator);

    function createStoryToken(
        uint256 storyId,
        string memory name,
        string memory symbol
    ) external returns (address) {
        require(
            address(storyTokens[storyId].token) == address(0),
            "Story token already exists"
        );
        StoryERC20 newToken = new StoryERC20(name, symbol, msg.sender);
        storyTokens[storyId] = StoryToken(newToken, msg.sender, 0, 0, false);

        emit StoryTokenCreated(
            storyId,
            address(newToken),
            name,
            symbol,
            msg.sender
        );

        return address(newToken);
    }

    function getQuizPts(uint256 storyId) external {
        _mintTokens(storyId, msg.sender, 1000);
    }

    function getPredictionPts(uint256 storyId) external {
        _mintTokens(storyId, msg.sender, 1500);
    }

    function getPollPts(uint256 storyId) external {
        _mintTokens(storyId, msg.sender, 500);
    }

    function voteOnStory(uint256 storyId, uint256 votePower) external {
        StoryToken storage story = storyTokens[storyId];
        require(
            story.token.balanceOf(msg.sender) >= votePower,
            "Insufficient balance"
        );
        require(storyVotes[storyId][msg.sender] == 0, "Already voted");

        story.token.transferFrom(msg.sender, address(this), votePower);
        storyVotes[storyId][msg.sender] = votePower;
        story.votingPower += votePower;
        storyVoters[storyId].push(msg.sender);

        emit StoryVoted(storyId, msg.sender, votePower);
    }

    function vetoStory(uint256 storyId) external {
        require(
            storyTokens[storyId].creator == msg.sender,
            "Not the story creator"
        );
        storyTokens[storyId].vetoed = true;
        emit StoryVetoed(storyId, msg.sender);
    }

    function shouldStoryEnd(uint256 storyId) external returns (bool) {
        StoryToken storage story = storyTokens[storyId];
        uint256 votePercentage = (story.votingPower * 100) /
            story.totalTokensBought;

        if (story.vetoed) {
            votePercentage = 0;
            story.vetoed = false;
        }

        // Reset votes
        for (uint256 i = 0; i < storyVoters[storyId].length; i++) {
            storyVotes[storyId][storyVoters[storyId][i]] = 0;
        }
        delete storyVoters[storyId];
        story.votingPower = 0;

        return votePercentage >= 51;
    }

    function getTokenBalance(
        uint256 storyId,
        address user
    ) external view returns (uint256) {
        return storyTokens[storyId].token.balanceOf(user);
    }

    function _mintTokens(
        uint256 storyId,
        address user,
        uint256 amount
    ) internal {
        StoryToken storage story = storyTokens[storyId];
        require(
            address(story.token) != address(0),
            "Story token does not exist"
        );
        story.token.transfer(user, amount);
        story.totalTokensBought += amount;
        emit TokensPurchased(storyId, user, amount);
    }
}

contract StoryERC20 is ERC20 {
    address public creator;

    constructor(
        string memory name,
        string memory symbol,
        address _creator
    ) ERC20(name, symbol) {
        creator = _creator;
        _mint(_creator, 1000 * 10 ** decimals()); // Mint some initial tokens to creator (optional)
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == creator, "Only creator can mint");
        _mint(to, amount);
    }
}
