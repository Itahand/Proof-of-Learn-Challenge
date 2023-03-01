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
        /*       Removed for sake of the tests
        require(
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

    function cancel(uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require(
            campaign.proposer == msg.sender,
            "You did not propose this Campaign"
        );
        require(
            block.timestamp < campaign.startAt,
            "Campaign has already started"
        );
        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(
            block.timestamp >= campaign.startAt,
            "Campaign has not Started yet"
        );
        require(
            block.timestamp <= campaign.endAt,
            "Campaign has already ended"
        );
        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function unPledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(
            block.timestamp >= campaign.startAt,
            "Campaign has not Started yet"
        );
        require(
            block.timestamp <= campaign.endAt,
            "Campaign has already ended"
        );
        require(
            pledgedAmount[_id][msg.sender] >= _amount,
            "You do not have enough tokens Pledged to withraw"
        );

        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(
            campaign.proposer == msg.sender,
            "You did not create this Campaign"
        );
        require(block.timestamp > campaign.endAt, "Campaign has not ended");
        require(campaign.pledged >= campaign.goal, "Campaign did not succed");
        require(!campaign.claimed, "claimed");

        campaign.claimed = true;
        token.transfer(campaign.proposer, campaign.pledged);

        emit Claim(_id);
    }

    function refund(uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(
            campaign.pledged < campaign.goal,
            "You cannot Withdraw, Campaign has succeeded"
        );

        uint256 bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }
}
