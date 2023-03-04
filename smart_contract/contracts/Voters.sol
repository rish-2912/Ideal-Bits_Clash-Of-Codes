// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract Voters {
    event getWinnerArr(Candidate[] res);
    struct User {
        uint256 id;
        string aadhar;
        string name;
        string email;
        bytes32 pass;
        string cid;
        string key;
        bool isValidated;
    }
    struct Candidate {
        uint256 id;
        string name;
        uint256 regNo;
        uint256 voteCount;
    }
    struct Election {
        uint256 id;
        string name;
        uint256 totalVote;
        uint256 candidateCount;
        bool isActive;
        bool deleted;
        uint256 createdBy;
    }
    struct History {
        string poll;
        string candidate;
        uint256 time;
    }
    User[] private userlist;
    User[] private voterList;
    Candidate[] private candidateList;
    Election[] private electionList;
    mapping(uint256 => Candidate) electionWinner;
    mapping(uint256 => bool) winnerMapped;
    mapping(uint256 => History[]) userHistory;
    mapping(address => uint256) UserToId;
    mapping(address => bool) userExists;
    mapping(uint256 => bool) UserRole;
    mapping(uint256 => mapping(uint256 => bool)) candidateMap;
    mapping(uint256 => mapping(uint256 => bool)) electionToCandidate;
    mapping(uint256 => mapping(uint256 => bool)) userToElection;
    mapping(uint256 => mapping(uint256 => bool)) userVote;
    mapping(uint256 => mapping(uint256 => uint256)) userElectionCandidateMap;

    constructor() {
        string
            memory hsh = "d%4c50e2dbA5&ed&dd90U&2d-R]73d1]Wc73+54u9bKx45672ib26f0p1Nmk_+20cpdC(b5712";
        address addr = 0xCDbD5B3D6347eedbDC0149bF920527D525412D25;
        userlist.push(
            User(
                0,
                "000000000000",
                "Admin",
                "admin@admin.admin",
                "1",
                "0",
                "MRSDSMCVGJSFENZT",
                true
            )
        );
        voterList.push(userlist[0]);
        UserRole[0] = true;
        UserToId[addr] = 0;
        userExists[addr] = true;
    }
}
