/** @format */

const { expect } = require("chai");
const { ethers } = require("hardhat");
// Utility function to parse ether
const tokens = (n: number) => {
  return ethers.utils.parseUnits(n.toString(), "ether");
};

describe("Proof of Learn Crowdfunding Challenge", () => {
  let deployer, user1, user2, testToken: any, accounts, crowdfunding: any;

  const feePercent = 10;

  beforeEach(async () => {
    const ProofOfLearnCrowdfunding = await ethers.getContractFactory(
      "ProofOfLearnCrowdFunding"
    );
    const Token = await ethers.getContractFactory("Token");

    testToken = await Token.deploy("Noah", "NOAH", "1000000");
    // Deploying with the Noah token address and 100 as maximum duration
    crowdfunding = await ProofOfLearnCrowdfunding.deploy(
      testToken.address,
      100
    );

    accounts = await ethers.getSigners();
    deployer = accounts[0];
    user1 = accounts[1];
    user2 = accounts[2];
  });

  describe("Deployment", () => {
    it("Uses correct Noah token address", async () => {
      expect(await crowdfunding.token()).to.equal(testToken.address);
    });
    it("Reflects the correct number value for the max duration", async () => {
      expect(await crowdfunding.maxDuration()).to.equal(100);
    });
  });
});
