// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Election {
    address public admin;
    bool public active;

    // Candidate Model
    struct Candidate {
        uint256 candidateId;
        string name;
        uint256 voteCount;
        string url;
    }

    // Voter Model
    struct Voter {
        string _name;
        address _address;
        bool _vote;
    }

    // Store candidates
    mapping(uint256 => Candidate) public candidates;
    // Store voters
    mapping(uint256 => Voter) public voters;
    uint256 public registeredCandidates = 0;
    uint256 public registeredVoters = 0;
    uint256 public voteCount = 0;
    uint256 public start;
    uint256 public end;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(admin == msg.sender, "Contact Admin to continue");
        _;
    }

    modifier isActive() {
        require(!active, "Voting is active. Reset values to continue");
        _;
    }

    function addCandidate(string memory _name, string memory _url)
        public
        onlyAdmin
        isActive
    {
        registeredCandidates++;
        candidates[registeredCandidates] = Candidate(
            registeredCandidates,
            _name,
            0,
            _url
        );
    }

    function addVoter(string memory _name, address _voterAddress)
        public
        onlyAdmin
        isActive
    {
        registeredVoters++;
        voters[registeredVoters] = Voter(_name, _voterAddress, false);
    }

    function vote(uint256 _candidateId) public {
        require(block.timestamp <= end, "Election Day is over");

        require(active, "Voting is not active.");

        uint256 index = getVoterIndex();
        require(
            voters[index]._address != address(0x0),
            "Voter not allowed to vote"
        );

        require(!voters[index]._vote, "Voter already voted");
        voters[index]._vote = true;
        candidates[_candidateId].voteCount++;
        voteCount++;
    }

    function getVoterIndex() public view returns (uint256 _voterIndex) {
        uint256 voterIndex;
        for (uint256 i = 1; i <= registeredVoters; i++) {
            if (voters[i]._address == msg.sender) {
                voterIndex = i;
            }
        }
        return voterIndex;
    }

    function setState() public {
        active = !active;
    }

    function startElection(uint256 time) public {
        active = true;
        start = block.timestamp;
        end = start + (60 * time); //time on minutes
    }

    function resetElection() public {
        active = false;
        registeredCandidates = 0;
        registeredVoters = 0;
        voteCount = 0;
        start = 0;
        end = 0;
    }

    function getTimeLeft() public view returns (uint256) {
        if (block.timestamp <= end) return end - block.timestamp;
        else return 0;
    }
}
