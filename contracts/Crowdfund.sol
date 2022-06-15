//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "usingtellor/contracts/UsingTellor.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IAutoPay.sol";

contract CrowdFund is UsingTellor {

    //token interface
    IERC20 public token;
    IAutoPay public autoPay;

    //query type
    string queryType;

    //list of artists (array of addresses)
    address[] public artists;
    //mapping of artists (address) to Agreement (struct)
    mapping(address => Agreement) public agreements;    

    //Agreement struct
    struct Agreement {
        //funders (dynamic array of addresses)
        address[] funders;
        //contributions (mapping address -> contribution uint)
        mapping(address => uint) contributions;
        //total donation in TRB (uint)
        uint totalDonation;
        //unclaimed donatins (uint)
        uint unclaimedDonation;
        //default status (bool or enum?)
        bool defaulted;
        //tellor query id (bytes32)
        bytes32 queryId;
        //start time
        uint startTime;
        //end time
        uint endTime;
        //url to additional agreement details
        string agreementURI;
    }

    //events

        //new proposal for funding from artist
        event FundingRequest(address _artist, bytes32 _queryId, string _agreementURI);

        //new donation sent
        event Donation(address _contributor, uint _donation);

        //new artist default
        event Default(address _artist);

        //withdrawal
        event FundingClaimed(address _artist, uint _amountClaimed);


    //functions

        //constructor
            //set tellor oracle address (polygon)
    constructor(
        address payable _tellorAddress,
        address payable _autoPay,
        address payable _token) UsingTellor(_tellorAddress) {

            token = IERC20(_token);
            autoPay = IAutoPay(_autoPay);
            queryType = "AccountabilityCheck";

    }

    //artist proposes funding and scedules Tellor oracle accountability check-ins
    function requestFunding(string memory _agreementURI) external {

        bytes memory queryData = abi.encode(queryType, abi.encode(_agreementURI));
        //generate Tellor query id
        bytes32 queryId = keccak256(
            abi.encode(queryData)
        );

        //create new Agreement struct
        Agreement storage newAgreement = agreements[msg.sender];
        //fill in Agreement struct from method args
            //empty funders mapping
            //total donation in TRB = 0
            //terminated = False
            //tellor query id = hmmm.... (generated elsewhere?)
            newAgreement.queryId = queryId;
            //url to additional agreement details
            newAgreement.agreementURI = _agreementURI;

        //append Agreement struct to list of agreements
        artists.push(msg.sender);

        //set up the schedule of tips for your tellor price feed
        autoPay.setupDataFeed(queryId, 10**17, block.timestamp, 86400*3, 86400, 0, queryData);

        bytes32 feedId = keccak256(
            abi.encode(
                queryId, //queryId (created above)
                10**17, //reward per submission (.1 TRB)
                block.timestamp, //when we start tipping (we'll start now)
                86400*3, //interval between windows for reporters to claim tips (3 days)
                86400, //window per interval to claim tips (1 day)
                0 //price threshold (set to 0 b/c this is not a price feed!)
            ));

        autoPay.fundFeed(feedId, queryId, 5**18);

        //emit AgreementOpened event
        emit FundingRequest(msg.sender, queryId, _agreementURI);
    }

    //fund project (takes artist address (address), donation amount (uint))
    function fundProject(address _artist, uint _donation) external {
        //fill in Agreement struct from method args
        Agreement storage belovedProject = agreements[_artist];
            //append sender address to funders array
            belovedProject.funders.push(msg.sender);
            //add contribution amount to contributions mapping
            belovedProject.contributions[msg.sender] = _donation;
            //total donations += donation amount
            belovedProject.totalDonation += _donation;
        //transferFrom donation amount to this contract
        token.approve(address(this), _donation);
        token.transferFrom(msg.sender, address(this), _donation);

        //emit Donation event
        emit Donation(msg.sender, _donation);
    }
    //default artist
    function defaultArtist(address _artist) external {

        //read tellor oracle on Agreement's query Id
        (bool success, bytes memory keptCommitment, uint timestamp) = getCurrentValue(
            agreements[_artist].queryId
        );
        //require tellor oracle believes artist didn't deliver
        require(success);
        require(timestamp - block.timestamp <= 86400*3);
        require(keccak256(keptCommitment) == keccak256("0"), "artist cannot be defaulted");
        //change values on Agreement struct
            //default status = True
            agreements[_artist].defaulted = true;
            //for i in funders:
            for(uint i = 0; i < agreements[_artist].funders.length; i++) {
                //save contribution to memory
                uint thisContribution = agreements[_artist].contributions[agreements[_artist].funders[i]];
                //set contribution in storage to 0
                agreements[_artist].contributions[agreements[_artist].funders[i]] = 0;
                //transfer contributions back to contributors
                token.transferFrom(address(this), agreements[_artist].funders[i], thisContribution);
            }
            //set total donation to 0
            agreements[_artist].totalDonation = 0;
        //emit AgreementDefaulted event
        emit Default(_artist);

    }
    //artist withdraws funds they've earned in protocol
    function claimFunding() external {
        //read tellor oracle on Agreement's query Id
        (bool success, bytes memory keptCommitment, uint timestamp) = getCurrentValue(
            agreements[msg.sender].queryId
        );
        //require tellor oracle believes artist has de
        require(success);
        require(timestamp - block.timestamp <= 86400*3);
        require(keccak256(keptCommitment) == keccak256("1"), "artist should be defaulted");

        uint unclaimedDonation = agreements[msg.sender].unclaimedDonation;
        //set total donation to 0
        agreements[msg.sender].unclaimedDonation = 0;
        //transfer unclaimed donations
        token.transferFrom(address(this), msg.sender, unclaimedDonation);
        //emit AgreementDefaulted event
        emit FundingClaimed(msg.sender, unclaimedDonation);
    }

}
