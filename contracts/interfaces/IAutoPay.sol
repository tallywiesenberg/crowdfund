pragma solidity ^0.8.0;

interface IAutoPay {

    function setupDataFeed(
        address _token,
        bytes32 _queryId,
        uint256 _reward,
        uint256 _startTime,
        uint256 _interval,
        uint256 _window,
        bytes calldata _queryData
    ) external;

    function fundFeed(
        bytes32 _feedId,
        bytes32 _queryId,
        uint256 _amount
    ) external;

}