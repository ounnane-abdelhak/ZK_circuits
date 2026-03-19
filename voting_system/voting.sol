// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVerifier {
    function verifyProof(
        uint[2] calldata a,
        uint[2][2] calldata b,
        uint[2] calldata c,
        uint[4] calldata pubSignals
    ) external view returns (bool);
}

contract Voting {
    IVerifier public verifier;

    uint public root;
    uint public electionID;
    bool public electionOpen;

    // nullifier => used
    mapping(uint => bool) public nullifiers;

    // 0, 1, 2 vote counts
    mapping(uint => uint) public voteCounts;

    address public admin;

    event VoteCast(uint nullifier, uint commitment);

    modifier AdminOnly(){
        require(msg.sender == admin,"not the admin");
        _;
    }

    constructor(address _verifier, uint _root, uint _electionID) {
        verifier = IVerifier(_verifier);
        root = _root;
        electionID = _electionID;
        admin = msg.sender;
        electionOpen = true;
    }

    function cast_vote(
        uint[2] calldata a,
        uint[2][2] calldata b,
        uint[2] calldata c,
        uint[4] calldata pubSignals
        // pubSignals[0] = nullifier
        // pubSignals[1] = commitment
        // pubSignals[2] = electionID
        // pubSignals[3] = root
        ) external {

            require(electionOpen == true, "election closed");
            require(root == pubSignals[3],"not the same roooot");
            require(!nullifiers[pubSignals[0]],"already votttttted");
            require(pubSignals[2] == electionID, "wrong election");
            require(verifier.verifyProof(a, b, c, pubSignals),"wrong proof");

            nullifiers[pubSignals[0]] = true;

            uint commitment = pubSignals[1];
            voteCounts[commitment]++;

            emit VoteCast(pubSignals[0], commitment);


        }

    function close_election() public  AdminOnly {
        electionOpen = false;
    }

    function getVoteCount(uint commitment) external view returns (uint) {
        return voteCounts[commitment];
    }

}