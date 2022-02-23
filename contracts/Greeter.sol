//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract CrowdFund {
    string private greeting;

//storage

    //Tellor interface

    //list of agreement creators (array of addresses)
    //mapping of agreement creators (address) to Agreement (struct)
    //mapping of artists (address) to termination status (bool or enum?)

    //Agreement struct
        //funders (dynamic array of addresses)
        //total donation in TRB (uint)
        //termination status (bool or enum?)
        //tellor query id (bytes32)
        //start time
        //end time
        //url to additional agreement details


//events

    //new proposal for funding from artist

    //new request for art from funder

    //new agreement

    //new donation sent

    //new artist termination

    //new completion of agreement

//functions

    //constructor
        //set tellor oracle address (polygon)

    //artist proposes funding
        //create new Agreement struct
        //fill in Agreement struct from method args
            //empty funders mapping
            //total donation in TRB = 0
            //terminated = 0
            //tellor query id = hmmm.... (generated elsewhere?)
            //url to additional agreement details
        //append Agreement struct to list of agreements

    //funder proposes art project
        //require funder TRB balance is greater than attempted funding amount
        //create new Agreement struct
        //fill in Agreement struct from method args
            //trb staked = 0
            //map funder address to amount funded in TRB in funder mapping
            //total donation in TRB = amount funded in TRB
            //terminated = False
            //tellor query id = query id
            //url to additional agreement details
        //append agreement struct to list of agreements
        //transferFrom stake amount in trb to this contract

    //default artist
        //read tellor oracle on Agreement's query Id
        //

    //begin agreement (once both stake and funding are received)

    //close agreement (funds are returned ammicably)

    constructor(string memory _greeting) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }
}
