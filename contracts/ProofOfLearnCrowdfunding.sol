// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {
    function transfer(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);
}

/**
 * @title Proof of Learn Crowdfunding Smart Contract Solidity Challenge
 */

contract ProofOfLearnCrowdFunding {
    ///// Contract variables /////
    IERC20 public immutable token;
    uint256 public count;
    uint256 public maxDuration;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public pledgedAmount;

    ///// Campaign struct with details /////
    struct Campaign {
        address proposer;
        uint256 goal;
        uint256 pledged;
        uint256 startAt;
        uint256 endAt;
        bool claimed;
    }

    ///// Events /////
    event Cancel(uint256 id);
    event Pledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Unpledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Claim(uint256 id);
    event Refund(uint256 id, address indexed caller, uint256 amount);
    event Launch(
        uint256 id,
        address indexed proposer,
        uint256 goal,
        uint32 startAt,
        uint64 endAt
    );

    ///// Constructor /////
    constructor(address _token, uint256 _maxDuration) {
        token = IERC20(_token);
        maxDuration = _maxDuration;
    }

    ///// Functions /////
    function launch(
        uint256 _goal,
        uint32 _startAt,
        uint64 _endAt
    ) external {
        /*         require(
            _startAt >= block.timestamp,
            "Start time is invalid: must be higher than current Block Timestamp"
        ); */
        require(_endAt > _startAt, "Start time must be lower than End time");
        require(
            _endAt <= block.timestamp + maxDuration,
            "End time exceeds the maximum Duration"
        );

        count += 1;
        campaigns[count] = Campaign({
            proposer: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }
}
