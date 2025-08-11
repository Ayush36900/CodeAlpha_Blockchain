// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollingSystem {
    struct Poll {
        string title;
        string[] options;
        uint endTime; // timestamp when poll ends
        mapping(uint => uint) votes; // optionIndex => vote count
        mapping(address => bool) voted; // prevent double voting
        bool exists;
    }

    mapping(uint => Poll) private polls;
    uint public pollCount;

    event PollCreated(uint pollId, string title, uint endTime);
    event Voted(uint pollId, uint optionIndex, address voter);

    // Create a new poll. durationSeconds = how long poll stays open from now.
    function createPoll(string memory title, string[] memory options, uint durationSeconds) public {
        require(options.length >= 2, "Need at least 2 options");
        require(durationSeconds > 0, "Duration must be > 0");

        uint pollId = pollCount++;
        Poll storage p = polls[pollId];
        p.title = title;
        p.endTime = block.timestamp + durationSeconds;
        p.exists = true;

        // copy options to storage array
        for (uint i = 0; i < options.length; i++) {
            p.options.push(options[i]);
        }

        emit PollCreated(pollId, title, p.endTime);
    }

    // Vote for an option by its index
    function vote(uint pollId, uint optionIndex) public {
        require(pollId < pollCount && polls[pollId].exists, "Poll does not exist");
        Poll storage p = polls[pollId];
        require(block.timestamp <= p.endTime, "Poll has ended");
        require(!p.voted[msg.sender], "Already voted");
        require(optionIndex < p.options.length, "Invalid option");

        p.votes[optionIndex] += 1;
        p.voted[msg.sender] = true;

        emit Voted(pollId, optionIndex, msg.sender);
    }

    // Get number of options in a poll
    function getOptionsCount(uint pollId) public view returns (uint) {
        require(pollId < pollCount && polls[pollId].exists, "Poll does not exist");
        return polls[pollId].options.length;
    }

    // Get an option string by index
    function getOption(uint pollId, uint index) public view returns (string memory) {
        require(pollId < pollCount && polls[pollId].exists, "Poll does not exist");
        require(index < polls[pollId].options.length, "Invalid index");
        return polls[pollId].options[index];
    }

    // Get votes of an option
    function getVotes(uint pollId, uint optionIndex) public view returns (uint) {
        require(pollId < pollCount && polls[pollId].exists, "Poll does not exist");
        require(optionIndex < polls[pollId].options.length, "Invalid option");
        return polls[pollId].votes[optionIndex];
    }

    // Determine and return the winning option index and vote count after poll ends
    function getWinner(uint pollId) public view returns (uint winningIndex, uint winningVotes) {
        require(pollId < pollCount && polls[pollId].exists, "Poll does not exist");
        Poll storage p = polls[pollId];
        require(block.timestamp > p.endTime, "Poll still open");

        uint bestIndex = 0;
        uint bestVotes = 0;
        for (uint i = 0; i < p.options.length; i++) {
            uint v = p.votes[i];
            if (v > bestVotes) {
                bestVotes = v;
                bestIndex = i;
            }
        }
        return (bestIndex, bestVotes);
    }
}
