/** @format */

const { expect } = require("chai");
const { ethers } = require("hardhat");
// Utility function to parse ether
const tokens = (n: number) => {
  return ethers.utils.parseUnits(n.toString(), "ether");
};

describe("Proof of Learn Crowdfunding Challenge", () => {
  let deployer: any,
    user1: any,
    user2: any,
    testToken: any,
    accounts,
    crowdfunding: any,
    maxTime = 1000;

  beforeEach(async () => {
    const ProofOfLearnCrowdfunding = await ethers.getContractFactory(
      "ProofOfLearnCrowdFunding"
    );
    const Token = await ethers.getContractFactory("Token");

    testToken = await Token.deploy("Noah", "NOAH", "1000000");
    // Deploying with the Noah token address and 100 as maximum duration
    crowdfunding = await ProofOfLearnCrowdfunding.deploy(
      testToken.address,
      maxTime
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
      expect(await crowdfunding.maxDuration()).to.equal(maxTime);
    });
  });
  // Functionality Tests //
  describe("Functionality", () => {
    let transaction, result: any;
    let goal = 1000;
    let endTime = 200000;
    let startTime = 100000;

    beforeEach(async () => {
      // Deposit token
      transaction = await crowdfunding
        .connect(user1)
        .launch(goal, startTime, endTime);
      result = await transaction.wait();
    });

    it("The address of the first campaign is equal to user1", async () => {
      let result = await crowdfunding.campaigns(1);
      expect(await result.proposer).to.equal(user1.address);
    });

    it("Emits a Launch event", async () => {
      const event = result.events[0];
      expect(event.event).to.equal("Launch");

      const args = event.args;
      expect(args.id).to.equal(1);
      expect(args.proposer).to.equal(user1.address);
      expect(args.goal).to.equal(goal);
      expect(args.startAt).to.equal(startTime);
      expect(args.endAt).to.equal(endTime);
    });

    describe("Cancel", () => {
      it("Can't cancel when the campaign has started", async () => {
        expect(crowdfunding.connect(user1).cancel(1)).to.be.reverted;
      });
      it("Can't cancel when is another address attempts to cancel", async () => {
        expect(crowdfunding.connect(user2).cancel(1)).to.be.reverted;
      });
    });

    describe("Funding", () => {
      it("A user successfully funds a campaign", async () => {
        expect(crowdfunding.connect(deployer).pledge(1, 100)).to.not.be
          .reverted;
      });
    });

    describe("Failure", () => {
      it("Fails when startTime is higher than endTime", async () => {
        let goal = 1000;
        let endTime = 2000000000000;
        let startTime = 10000;
        await expect(
          crowdfunding.connect(user1).launch(goal, startTime, endTime)
        ).to.be.reverted;
      });
    });
  });
});
