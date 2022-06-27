// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
pragma abicoder v2;

import "./Ownable.sol";

contract USElection is Ownable {
    uint8 public constant BIDEN = 1;
    uint8 public constant TRUMP = 2;
    
    bool public electionEnded;
    
    mapping(uint8 => uint8) public seats;
    mapping(string => bool) public submitedStates;
    
    struct StateResult {
        string name;
        uint votesBiden;
        uint votesTrump;
        uint8 stateSeats;
    }
    
    modifier onlyActiveElection {
        require(!electionEnded, "Election has ended!");
        _;
    }

    function submitStateResult(StateResult calldata result) public onlyOwner onlyActiveElection {
        require(result.stateSeats > 0, "State seets cannot be empty!");
        require(!submitedStates[result.name], "This state has already submited results!");
        require(result.votesBiden != result.votesTrump, "There cannot be a tie");

        submitedStates[result.name] = true;

        uint8 winner = result.votesTrump > result.votesBiden ? TRUMP : BIDEN;
        seats[winner] += result.stateSeats;
    }
    
    function currentLeader() public view returns(uint8) {
        uint bidenSeats = seats[BIDEN];
        uint trumpSeats = seats[TRUMP];

        if (bidenSeats == trumpSeats) {
            return 0;
        }

        return bidenSeats > trumpSeats ? BIDEN : TRUMP;
    }
    
    function endElection() public onlyOwner onlyActiveElection {
        electionEnded = true;
    }
}