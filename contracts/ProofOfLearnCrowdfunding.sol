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
    IERC20 public immutable token;

    constructor(address _token) {
        token = IERC20(_token);
    }
}
