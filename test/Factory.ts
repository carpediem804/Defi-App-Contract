import { ethers } from "hardhat";
import { expect } from "chai";

import { Exchange } from "../typechain-types/contracts/Exchange";
import { Token } from "../typechain-types/contracts/Token";
import { Factory } from "../typechain-types/contracts/Factory";

import { BigNumber } from "ethers";

const toWei = (value: number) => ethers.utils.parseEther(value.toString());
const toEther = (value: BigNumber) => ethers.utils.formatEther(value);
const getBalance = ethers.provider.getBalance;

describe("Factory", () => {
  let owner: any;
  let user: any;
  let factory: Factory;
  let token: Token;

  beforeEach(async () => {
    [owner, user] = await ethers.getSigners();
    const TokenFactory = await ethers.getContractFactory("Token");
    token = await TokenFactory.deploy("TaehongToken", "TH", toWei(50));
    await token.deployed();

    const FactoryFactory = await ethers.getContractFactory("Factory");
    factory = await FactoryFactory.deploy();
    await factory.deployed();
  });

  describe("deploy Factory Contract ", async () => {
    it("correct depoly Factory Contract ", async () => {
      // callstatic 내부적으로 view funct ion 호출 되서 내부값은 쓰지않고 결과만 리턴
      const exchageAddress = await factory.callStatic.createExchange(
        token.address
      );

      console.log("exchageAddress:", exchageAddress);
      //call static으로 호출해서 값이 없다
      console.log(await factory.getExchangeAddress(token.address));

      await factory.createExchange(token.address);
      expect(await factory.getExchangeAddress(token.address)).eq(
        exchageAddress
      );
    });
  });
});
