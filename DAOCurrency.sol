// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Basic ERC20 Interface
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract DAOToken is IERC20 {
    string public name = "DAO Token";
    string public symbol = "DT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * (10 ** uint256(decimals)); // 1 Million tokens
    mapping(address => uint256) balances;
    address public DAO;

    modifier onlyDAO() {
        require(msg.sender == DAO, "Only DAO can execute this");
        _;
    }

    constructor(address _DAO) {
        DAO = _DAO;
        balances[_DAO] = totalSupply;  // All initial tokens are given to the DAO
    }

    function transfer(address recipient, uint256 amount) external override onlyDAO returns (bool) {
        require(balances[DAO] >= amount, "Not enough tokens");
        balances[DAO] -= amount;
        balances[recipient] += amount;
        return true;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }
}

contract DAO {
    struct Proposal {
        address recipient;
        uint256 amount;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
        mapping(address => bool) hasVoted;
    }

    DAOToken public token;
    mapping(address => bool) public members;
    Proposal[] public proposals;

    modifier onlyMembers() {
        require(members[msg.sender], "Only members allowed");
        _;
    }

    constructor() {
        token = new DAOToken(address(this));
        members[msg.sender] = true; // Deployer becomes the first member
    }

    function proposeSpending(address _recipient, uint256 _amount) external onlyMembers {
        Proposal memory newProposal;
        newProposal.recipient = _recipient;
        newProposal.amount = _amount;
        proposals.push(newProposal);
    }

    function vote(uint256 _proposalId, bool _voteInFavor) external onlyMembers {
        Proposal storage proposal = proposals[_proposalId];

        require(!proposal.executed, "Proposal has already been executed");
        require(!proposal.hasVoted[msg.sender], "Member has already voted on this proposal");

        if (_voteInFavor) {
            proposal.yesVotes += 1;
        } else {
            proposal.noVotes += 1;
        }
        proposal.hasVoted[msg.sender] = true;
    }

    function executeProposal(uint256 _proposalId) external onlyMembers {
        Proposal storage proposal = proposals[_proposalId];

        require(!proposal.executed, "Proposal has already been executed");
        require(proposal.yesVotes > proposal.noVotes, "The majority did not vote in favor");

        bool success = token.transfer(proposal.recipient, proposal.amount);
        require(success, "Transfer failed");

        proposal.executed = true;
    }

    function joinDAO() external {
        // For simplicity, anyone can join the DAO in this example.
        members[msg.sender] = true;
    }
}
