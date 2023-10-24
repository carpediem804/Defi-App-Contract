import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";

describe("NFT", () => {
  let owner: Signer;

  before(async () => {
    [owner] = await ethers.getSigners();
  });

  it("should have 10 nfts", async () => {
    const nft = await ethers.getContractFactory("NFT");
    const contract = await nft.deploy();

    await contract.deployed(); // 컨트렉트 배포될때까지 기다려라

    expect(await contract.balanceOf(await owner.getAddress())).to.be.equal(10);
  });
});
