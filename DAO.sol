// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAORules {

    struct Proposal {
        string rule;
        uint256 yesVotes;
        uint256 noVotes;
        mapping(address => bool) hasVoted;
    }

    address public owner;
    mapping(address => bool) public members;
    Proposal[] public proposals;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this");
        _;
    }

    modifier onlyMembers() {
        require(members[msg.sender], "Only members allowed");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addMember(address _member) external onlyOwner {
        members[_member] = true;
    }

    function removeMember(address _member) external onlyOwner {
        members[_member] = false;
    }

    function proposeRule(string calldata _rule) external onlyMembers {
        Proposal memory newProposal;
        newProposal.rule = _rule;
        proposals.push(newProposal);
    }

    function vote(uint256 _proposalId, bool _voteInFavor) external onlyMembers {
        require(!proposals[_proposalId].hasVoted[msg.sender], "Member has already voted on this proposal");

        if (_voteInFavor) {
            proposals[_proposalId].yesVotes += 1;
        } else {
            proposals[_proposalId].noVotes += 1;
        }
        proposals[_proposalId].hasVoted[msg.sender] = true;
    }

    function getProposalStatus(uint256 _proposalId) external view returns(string memory) {
        Proposal memory proposal = proposals[_proposalId];
        if (proposal.yesVotes > proposal.noVotes) {
            return "In Favor";
        } else if (proposal.yesVotes < proposal.noVotes) {
            return "Against";
        } else {
            return "Tied";
        }
    }
}
