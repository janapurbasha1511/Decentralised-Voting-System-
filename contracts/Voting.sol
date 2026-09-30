// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Voting {
    address public admin;

    bool public votingOpen;
    uint public votingEnd;

    struct Candidate {
        string name;
        uint voteCount;
    }

    Candidate[] public candidates;

    mapping(address => bool) public isRegistered;
    mapping(address => bool) public hasVoted;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    modifier beforeVotingStarts() {
        require(!votingOpen, "Setup is closed, voting already started");
        _;
    }

    modifier duringVoting() {
        require(votingOpen, "Voting has not started");
        require(block.timestamp <= votingEnd, "Voting period has ended");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // ---------- SETUP PHASE (admin only, before voting starts) ----------

    function addVoter(address _voter) public onlyAdmin beforeVotingStarts {
        isRegistered[_voter] = true;
    }

    function addCandidate(string memory _name) public onlyAdmin beforeVotingStarts {
        candidates.push(Candidate(_name, 0));
    }

    function startVoting(uint _durationInMinutes) public onlyAdmin beforeVotingStarts {
        require(candidates.length > 0, "Add at least one candidate first");
        votingOpen = true;
        votingEnd = block.timestamp + (_durationInMinutes * 1 minutes);
    }

    // ---------- VOTING PHASE ----------

    function vote(uint _candidateIndex) public duringVoting {
        require(isRegistered[msg.sender], "You are not registered to vote");
        require(!hasVoted[msg.sender], "You have already voted");
        require(_candidateIndex < candidates.length, "Invalid candidate");

        hasVoted[msg.sender] = true;
        candidates[_candidateIndex].voteCount++;
    }

    // ---------- VIEW HELPERS (usable any time) ----------

    function getCandidateCount() public view returns (uint) {
        return candidates.length;
    }

    function getCandidateName(uint _index) public view returns (string memory) {
        require(_index < candidates.length, "Invalid candidate");
        return candidates[_index].name;
    }

    function timeRemaining() public view returns (uint) {
        if (!votingOpen || block.timestamp >= votingEnd) {
            return 0;
        }
        return votingEnd - block.timestamp;
    }

    // ---------- RESULTS (only after voting ends) ----------

    function getResults() public view returns (string[] memory names, uint[] memory votes) {
        require(votingOpen, "Voting was never started");
        require(block.timestamp > votingEnd, "Results not available yet");

        names = new string[](candidates.length);
        votes = new uint[](candidates.length);

        for (uint i = 0; i < candidates.length; i++) {
            names[i] = candidates[i].name;
            votes[i] = candidates[i].voteCount;
        }
    }
}
