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

  console.log("Factory Contract Deployed at : ", contract.address);
  console.log("Token Contract Deployed at : ", THTokenContract.address);
  console.log("Exchange Contract Deployed at : ", ExchangeContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
