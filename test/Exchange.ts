import { ethers } from "hardhat";
import { expect } from "chai";

import { BigNumber } from "ethers";

import { Exchange } from "../typechain-types/contracts/Exchange";
import { Token } from "../typechain-types/contracts/Token";

const toWei = (value: number) => ethers.utils.parseEther(value.toString());
const toEther = (value: BigNumber) => ethers.utils.formatEther(value);

const getBalance = ethers.provider.getBalance;

describe("Exchange", () => {
  let owner: any;
  let user: any;
  let exchange: Exchange;
  let token: Token;

  beforeEach(async () => {
    [owner, user] = await ethers.getSigners();

    const TokenFactory = await ethers.getContractFactory("Token");
    token = await TokenFactory.deploy("GrayToken", "GRAY", toWei(50));
    await token.deployed();

    const ExchangeFactory = await ethers.getContractFactory("Exchange");
    exchange = await ExchangeFactory.deploy(token.address);
    await exchange.deployed();
  });

  describe("addLiquidity", async () => {
    it("add liguidty", async () => {
      await token.approve(exchange.address, toWei(500));
      await exchange.addLiquidity(toWei(500), { value: toWei(1000) });
      expect(await getBalance(exchange.address)).to.equal(toWei(1000));
      expect(await token.balanceOf(exchange.address)).to.equal(toWei(500));

      await token.approve(exchange.address, toWei(100));
      await exchange.addLiquidity(toWei(100), { value: toWei(200) });
      expect(await getBalance(exchange.address)).to.equal(toWei(1200));
      expect(await token.balanceOf(exchange.address)).to.equal(toWei(600));
    });
  });

  describe("removeLiquidity", async () => {
    it("remove liguidty", async () => {
      await token.approve(exchange.address, toWei(500));
      await exchange.addLiquidity(toWei(500), { value: toWei(1000) });
      expect(await getBalance(exchange.address)).to.equal(toWei(1000));
      expect(await token.balanceOf(exchange.address)).to.equal(toWei(500));

      await token.approve(exchange.address, toWei(100));
      await exchange.addLiquidity(toWei(100), { value: toWei(200) });
      expect(await getBalance(exchange.address)).to.equal(toWei(1200));
      expect(await token.balanceOf(exchange.address)).to.equal(toWei(600));

      await exchange.removeLiquidity(toWei(600));
      expect(await getBalance(exchange.address)).to.equal(toWei(600));
      expect(await token.balanceOf(exchange.address)).to.equal(toWei(300));
    });
  });

  // describe("swap", async () => {
  //   it("swap", async () => {
  //     await token.approve(exchange.address, toWei(1000));
  //     await exchange.addLiquidity(toWei(1000), { value: toWei(1000) });

  //     await exchange.connect(user).ethToTokenSwap({ value: toWei(1) });

  //     expect(await getBalance(exchange.address)).to.equal(toWei(1001)); //이더조회
  //     expect(await token.balanceOf(exchange.address)).to.equal(toWei(999));
  //     expect(await token.balanceOf(user.address)).to.equal(toWei(1));
  //     // expect(await getBalance(user.address)).to.equal(toWei(9999)); //이더조회 //유저는 가스비가 더들어서  에러발생한다
  //   });
  // });

  describe("getOutputAmount", async () => {
    it("correct get output amount ", async () => {
      await token.approve(exchange.address, toWei(4000));
      await exchange.addLiquidity(toWei(4000), { value: toWei(1000) });
      // 4:1  비율이다

      // get 1Eth : ??Gray
      console.log(
        toEther(
          await exchange.getOutputAmount(
            toWei(1),
            getBalance(exchange.address),
            token.balanceOf(exchange.address)
          )
        )
      );
    });
  });

  describe("ethToToKenSwap", async () => {
    it("correct ethToToKenSwap", async () => {
      await token.approve(exchange.address, toWei(4000));
      await exchange.addLiquidity(toWei(4000), { value: toWei(1000) });
      //4:1 비율

      //1ETH : ?? GRAY
      await exchange
        .connect(user)
        .ethToTokenSwap(toWei(3.99), { value: toWei(1) });

      console.log(toEther(await token.balanceOf(user.address)));
      // expect(await getBalance(exchange.address)).to.equal(toWei(1000));
      // expect(await token.balanceOf(exchange.address)).to.equal(toWei(1000));
    });
  });

  describe("swapWithFee", async () => {
    it("correct swapWithFee", async () => {
      await token.approve(exchange.address, toWei(50));

      //유동성 공급 50:50
      await exchange.addLiquidity(toWei(50), { value: toWei(50) });

      //유저 eth30, gray 18.6434 swap
      await exchange
        .connect(user)
        .ethToTokenSwap(toWei(18), { value: toWei(30) });
      //스왑후 유저의 gray 잔액 : 18.63
      console.log(toEther(await token.balanceOf(user.address)));

      //owner의 유동성 제거
      await exchange.removeLiquidity(toWei(50));
      // owwner의 잔고 50-18.6323 = 31.367
      console.log(toEther(await token.balanceOf(owner.address)));
    });
  });

  describe("tokenToTokenSwap", async () => {
    it("correct tokenToTokenSwap", async () => {
      [owner, user] = await ethers.getSigners();

      const FactoryFactory = await ethers.getContractFactory("Factory");
      const factory = await FactoryFactory.deploy();
      factory.deployed();

      //create Gray Token
      const TokenFactory = await ethers.getContractFactory("Token");
      const token = await TokenFactory.deploy("GrayToken", "GRAY", toWei(1010));
      await token.deployed();

      //create Red Token
      const TokenFactory2 = await ethers.getContractFactory("Token");
      const token2 = await TokenFactory2.deploy("RedToken", "RED", toWei(1000));
      await token2.deployed();

      //gray/eth pari exchange contract deploy
      const exchanageAddress = await factory.callStatic.createExchange(
        token.address
      );
      await factory.createExchange(token.address);

      //RED/eth pari exchange contract deploy
      const exchanage2Address = await factory.callStatic.createExchange(
        token2.address
      );
      await factory.createExchange(token2.address);

      //add riquidity
      await token.approve(exchanageAddress, toWei(1000));
      await token2.approve(exchanage2Address, toWei(1000));

      const ExchangeFactory = await ethers.getContractFactory("Exchange");
      await ExchangeFactory.attach(exchanageAddress).addLiquidity(toWei(1000), {
        value: 1000,
      });
      await ExchangeFactory.attach(exchanage2Address).addLiquidity(
        toWei(1000),
        { value: 1000 }
      );

      //swap
      // 유동성 공급을 위해 1000개 다썻음으로 10개 추가로 approve
      await token.approve(exchanageAddress, toWei(10));
      await ExchangeFactory.attach(exchanageAddress).tokenToTokenSwap(
        toWei(10),
        toWei(9),
        token.address
      );

      //red token balance >0
      console.log(toEther(await token2.balanceOf(owner.address)));
    });
  });
});
