import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  //config 의 private key에 맵핑되는 것
  console.log("Deploying contracts with the account : ", deployer.address);

  const Factory = await ethers.getContractFactory("Factory");
  const contract = await Factory.deploy();

  const THToken = await ethers.getContractFactory("Token");
  const THTokenContract = await THToken.deploy("TaeHongToken", "TH", 1000);

  const ExchangeFactory = await ethers.getContractFactory("Exchange");
  const ExchangeContract = await ExchangeFactory.deploy(
    THTokenContract.address
  );

  const StakingFactory = await ethers.getContractFactory("StakingRewords");
  const StakingContract = await StakingFactory.deploy(
    "0xEF81F5c21741a3cD4e6287EAEc7C35012e670338",
    "0xEF81F5c21741a3cD4e6287EAEc7C35012e670338"
  );

  const NFTFactory = await ethers.getContractFactory("NFT");
  const NFTContract = await NFTFactory.deploy();

  console.log("Factory Contract Deployed at : ", contract.address);
  console.log("Token Contract Deployed at : ", THTokenContract.address);
  console.log("Exchange Contract Deployed at : ", ExchangeContract.address);
  console.log("StakingReward Contract Deployed at : ", StakingContract.address);
  console.log("NFT Contract Deployed at :", NFTContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
