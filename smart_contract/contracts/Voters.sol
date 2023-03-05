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
                collisionHash(hsh),
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

    function mapUserToElection(uint256 electionID, uint256 userID) external {
        userToElection[electionID][userID] = true;
    }

    function removeUserElectionMap(uint256 electionID, uint256 userID)
        external
    {
        userToElection[electionID][userID] = false;
    }

    function getUnaddedUserToElection(uint256 electionID)
        external
        view
        returns (User[] memory)
    {
        User[] memory temp = new User[](userlist.length);
        uint256 counter = 0;
        for (uint256 i = 0; i < userlist.length; i++) {
            if (
                userlist[i].isValidated == true &&
                userToElection[electionID][i] != true
            ) {
                temp[counter] = userlist[i];
                counter++;
            }
        }
        User[] memory result = new User[](counter);
        for (uint256 i = 0; i < counter; i++) {
            result[i] = temp[i];
        }
        return result;
    }

    function getAddedUserToElection(uint256 electionID)
        external
        view
        returns (User[] memory)
    {
        User[] memory temp = new User[](userlist.length);
        uint256 counter = 0;
        for (uint256 i = 0; i < userlist.length; i++) {
            if (
                userlist[i].isValidated == true &&
                userToElection[electionID][i] == true
            ) {
                temp[counter] = userlist[i];
                counter++;
            }
        }
        User[] memory result = new User[](counter);
        for (uint256 i = 0; i < counter; i++) {
            result[i] = temp[i];
        }
        return result;
    }

    function isCandidateMapped(uint256 electionID, uint256 regNo)
        public
        view
        returns (bool)
    {
        if (candidateMap[regNo][electionID] == true) {
            return true;
        } else {
            return false;
        }
    }

    function getCandidates(uint256 id)
        external
        view
        returns (Candidate[] memory)
    {
        Candidate[] memory temp = new Candidate[](candidateList.length);
        uint256 counter = 0;
        for (uint256 i = 0; i < candidateList.length; i++) {
            if (electionToCandidate[id][i] == true) {
                temp[counter] = candidateList[i];
                counter++;
            }
        }
        Candidate[] memory result = new Candidate[](counter);
        for (uint256 i = 0; i < counter; i++) {
            result[i] = temp[i];
        }
        return result;
    }

    function mapCandidate(
        uint256 regNo,
        uint256 electionID,
        uint256 candidateID
    ) external {
        candidateMap[regNo][electionID] = !candidateMap[regNo][electionID];
        electionToCandidate[electionID][candidateID] = !electionToCandidate[
            electionID
        ][candidateID];
        if (candidateMap[regNo][electionID] == false) {
            electionList[electionID].candidateCount--;
        }
    }

    function addCandidate(
        string memory name,
        uint256 regNo,
        uint256 electionID
    ) public {
        require(!isCandidateMapped(electionID, regNo), "Already Added!");
        uint256 candidateID = candidateList.length;
        candidateList.push(Candidate(candidateID, name, regNo, 0));
        candidateMap[regNo][electionID] = true;
        electionToCandidate[electionID][candidateID] = true;
        electionList[electionID].candidateCount++;
    }

    function removeElection(uint256 id) external {
        electionList[id].deleted = true;
    }

    function addElection(string memory name) external {
        uint256 ID = electionList.length;
        electionList.push(
            Election(ID, name, 0, 0, false, false, UserToId[getSender()])
        );
        addCandidate("None of the Above", 0, ID);
    }

    function auditElections(uint256 id) external {
        electionList[id].isActive = !electionList[id].isActive;
    }

    function isAdminMain() private view returns (bool) {
        if (UserToId[getSender()] == 0) return true;
        else return false;
    }

    function getElectionList() external view returns (Election[] memory) {
        uint256 cnt = electionList.length;
        Election[] memory temp = new Election[](cnt);
        uint256 counter = 0;
        bool flag = isAdminMain();
        for (uint256 i = cnt; i > 0; i--) {
            if (electionList[i - 1].deleted == false) {
                if (flag == true) {
                    temp[counter] = electionList[i - 1];
                    counter++;
                } else if (
                    electionList[i - 1].createdBy == UserToId[getSender()]
                ) {
                    temp[counter] = electionList[i - 1];
                    counter++;
                }
            }
        }
        Election[] memory result = new Election[](counter);
        for (uint256 i = 0; i < counter; i++) {
            result[i] = temp[i];
        }
        return result;
    }

    function getActiveElections() external view returns (Election[] memory) {
        Election[] memory temp = new Election[](electionList.length);
        uint256 counter = 0;
        bool flag = isAdminMain();
        for (uint256 i = 0; i < electionList.length; i++) {
            if (
                electionList[i].isActive == true &&
                electionList[i].deleted == false
            ) {
                if (flag == true) {
                    temp[counter] = electionList[i];
                    counter++;
                } else if (electionList[i].createdBy == UserToId[getSender()]) {
                    temp[counter] = electionList[i];
                    counter++;
                }
            }
        }
        Election[] memory result = new Election[](counter);
        for (uint256 i = 0; i < counter; i++) {
            result[i] = temp[i];
        }
        return result;
    }

    function isUserRegistered() public view returns (bool) {
        if (userExists[getSender()] == true) {
            return true;
        } else {
            return false;
        }
    }

    function loginUser(string memory pass, string memory aadhar)
        external
        view
        returns (bool)
    {
        require(isUserRegistered());
        User memory tmp = userlist[UserToId[getSender()]];
        bytes32 chkHash = keccak256(abi.encode(pass));
        if (
            tmp.pass == chkHash &&
            (keccak256(abi.encodePacked(tmp.aadhar)) ==
                keccak256(abi.encodePacked(aadhar)))
        ) {
            return true;
        } else {
            return false;
        }
    }

    function setPass(string memory _pass) public {
        userlist[UserToId[getSender()]].pass = keccak256(abi.encode(_pass));
    }

    function switchRole(uint256 id) public {
        require(id != 0);
        require(id != UserToId[getSender()]);
        UserRole[id] = !UserRole[id];
    }

    function getUserRole(uint256 id) public view returns (bool) {
        return UserRole[id];
    }

    function collisionHash(string memory _string1)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_string1));
    }

    function addUser(
        string memory aadhar,
        string memory name,
        string memory email,
        string memory pass,
        string memory cid,
        string memory key,
        bool isValidated
    ) external {
        require(!isUserRegistered(), "Already Registered!");
        uint256 userID = userlist.length;
        bytes32 hsh = collisionHash(pass);
        UserToId[getSender()] = userID;
        UserRole[userID] = false;
        userlist.push(
            User(userID, aadhar, name, email, hsh, cid, key, isValidated)
        );
        userExists[getSender()] = true;
    }

    function ValidateUser(uint256 userID) public {
        userlist[userID].isValidated = true;
        voterList.push(userlist[userID]);
    }

    function getUserList() external view returns (User[] memory) {
        User[] memory temp = new User[](userlist.length);
        uint256 counter = 0;
        for (uint256 i = 0; i < userlist.length; i++) {
            if (userlist[i].isValidated == false) {
                temp[counter] = userlist[i];
                counter++;
            }
        }
        User[] memory result = new User[](counter);
        for (uint256 i = 0; i < counter; i++) {
            result[i] = temp[i];
        }
        return result;
    }

    function getVoterList() external view returns (User[] memory) {
        User[] memory result = new User[](voterList.length);
        for (uint256 i = 0; i < voterList.length; i++) {
            result[i] = voterList[i];
        }
        return result;
    }

    function getSender() public view returns (address) {
        return msg.sender;
    }

    function getUserDetails() public view returns (User memory) {
        require(userExists[getSender()] == true, "User does not exist");
        return userlist[UserToId[getSender()]];
    }

    function getMappedElections(uint256 id)
        public
        view
        returns (Election[] memory)
    {
        Election[] memory temp = new Election[](electionList.length);
        uint256 counter = 0;
        for (uint256 i = 0; i < electionList.length; i++) {
            if (
                electionList[i].isActive == true &&
                electionList[i].deleted == false &&
                userToElection[i][id] == true
            ) {
                temp[counter] = electionList[i];
                counter++;
            }
        }
        Election[] memory result = new Election[](counter);
        for (uint256 i = 0; i < counter; i++) {
            result[i] = temp[i];
        }
        return result;
    }

    function getAllMappedElections(uint256 id)
        public
        view
        returns (Election[] memory)
    {
        Election[] memory temp = new Election[](electionList.length);
        uint256 counter = 0;
        for (uint256 i = 0; i < electionList.length; i++) {
            if (userToElection[i][id] == true) {
                temp[counter] = electionList[i];
                counter++;
            }
        }
        Election[] memory result = new Election[](counter);
        for (uint256 i = 0; i < counter; i++) {
            result[i] = temp[i];
        }
        return result;
    }

    function checkVote(uint256 userid, uint256 electionid)
        public
        view
        returns (bool)
    {
        return userVote[userid][electionid];
    }

    function castVote(
        uint256 userid,
        uint256 electionid,
        uint256 candidateid
    ) public {
        require(
            UserToId[getSender()] == userid,
            "Unauthorized access detected!"
        );
        require(!userVote[userid][electionid], "Already Voted!");
        userElectionCandidateMap[userid][electionid] = candidateid;
        userVote[userid][electionid] = true;
        candidateList[candidateid].voteCount++;
        electionList[electionid].totalVote++;
        setHistory(userid, electionid, candidateid, block.timestamp);
    }

    function setHistory(
        uint256 userid,
        uint256 electionid,
        uint256 candidateid,
        uint256 time
    ) public {
        userHistory[userid].push(
            History(
                electionList[electionid].name,
                candidateList[candidateid].name,
                time
            )
        );
    }

    function getHistory(uint256 userid) public view returns (History[] memory) {
        return userHistory[userid];
    }

    function findWinner(uint256 electionID) external {
        require(electionList[electionID].deleted == false);
        require(electionList[electionID].isActive == false);
        require(electionList[electionID].totalVote > 0);
        Candidate[] memory tmp = new Candidate[](candidateList.length);
        uint256 counter = 0;
        uint256 maxVote = 0;
        for (uint256 i = 0; i < candidateList.length; i++) {
            if (
                electionToCandidate[electionID][i] == true &&
                candidateList[i].voteCount >= maxVote &&
                candidateList[i].regNo != 0
            ) {
                maxVote = candidateList[i].voteCount;
                tmp[counter] = candidateList[i];
                counter++;
            }
        }
        Candidate[] memory res = new Candidate[](counter);
        for (uint256 i = 0; i < counter; i++) {
            res[i] = tmp[i];
        }
        if (res.length == 0) {
            electionWinner[electionID] = Candidate(0, "No Winner", 0, 0);
            winnerMapped[electionID] = true;
        } else if (res.length == 1) {
            electionWinner[electionID] = res[0];
            winnerMapped[electionID] = true;
        }
        emit getWinnerArr(res);
    }

    function setTieWinner(uint256 electionID, Candidate memory cnd) public {
        cnd.voteCount++;
        electionWinner[electionID] = cnd;
        winnerMapped[electionID] = true;
    }

    function getWinner(uint256 electionID)
        public
        view
        returns (Candidate memory)
    {
        if (winnerMapped[electionID]) {
            return electionWinner[electionID];
        } else {
            return Candidate(0, "null", 0, 0);
        }
    }
}
