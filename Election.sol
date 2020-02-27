pragma solidity >=0.5.0;

contract Election {

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }
    
    struct Voter {
        bytes32 voterKeyHash;
        bytes32 voterValueHash;
    }
    
    string name;
    address creator;
    
    // Records who has been added as a voter to prevent duplicate adds
    mapping(bytes32 => bytes32) validVoters;
    mapping(bytes32 => bool) voted;
    
    uint candidatesCount;
    mapping(uint => Candidate) candidates;
    mapping(string => uint) candidateNum;
    
    event votedEvent(uint indexed candidateId);

    constructor(string memory _name) public {
        name = _name;
        creator = msg.sender;
    }

    function addCandidate(string memory candidateName) public {
        require(msg.sender == creator, "Only the creator can add candidates.");
        require(candidateNum[candidateName] == 0, "Cannot add an existing candidate.");
        
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, candidateName, 0);
        candidateNum[candidateName] = candidatesCount;
    }
    
    function getNumCandidates() public view
        returns (uint)
    {
        return candidatesCount;
    }
    
    function getCandidateNumber(string memory candidateName) private view 
        returns (uint) {
            return candidateNum[candidateName];
        }
 
    function getCandidate(uint id) public view
        returns (uint, string memory, uint)
    {
        return (id, candidates[id].name, candidates[id].voteCount);
    }
    
    function addVoter(string memory key , string memory value) public {
        require(msg.sender == creator, "Only the creator can add valid voters.");
        Voter memory voter = createVoter(key, value);
        require(validVoters[voter.voterKeyHash] == 0, "This voter can already vote.");
        validVoters[voter.voterKeyHash] = voter.voterValueHash;
    }
    
    function createVoter(string memory key, string memory value) private 
        returns (Voter memory voter) {
            bytes32 keyHash = keccak256(abi.encodePacked(key));
            bytes32 valueHash = keccak256(abi.encodePacked(value));
            Voter memory voter = Voter(keyHash, valueHash);
            return voter;
        }
    function vote(string memory candidateName, string memory name, string memory pass) public {
        Voter memory voter = createVoter(name, pass);
        uint candidateId = getCandidateNumber(candidateName);
        vote(candidateId, voter.voterKeyHash, voter.voterValueHash);
    }
    
    function vote(uint candidateId, bytes32 voterKeyHash, bytes32 voterValueHash) private {
        require(validVoters[voterKeyHash] == voterValueHash, "Must be a valid voter.");
        require(!voted[voterKeyHash], "Cannot have already voted.");
        require((candidateId > 0) && (candidateId <= candidatesCount),
            "Must vote for valid candidate");

        voted[voterKeyHash] = true;
        candidates[candidateId].voteCount++;
        emit votedEvent(candidateId);
    }
}