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
    struct Campaign {
        address proposer;
        uint256 goal;
        uint256 pledged;
        uint256 startAt;
        uint256 endAt;
        bool claimed;
    }

    IERC20 public immutable token;
    uint256 public count;
    uint256 public maxDuration;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public pledgedAmount;

    constructor(address _token, uint256 _maxDuration) {
        token = IERC20(_token);
        maxDuration = _maxDuration;
    }
}
