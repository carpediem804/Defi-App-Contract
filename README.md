# Defi App Swap Contract

 Uniswap V1 version 

 Exchange Contract (ERC20)
 - addLiquidity
 - removeLiquidity
 - ethToTokenSwap
 - ethToTokenTransfer
 - ethToToken
 - tokenToEthSwap
 - getPrice (CSMM)
 - getOutputAmount (CPMM)
 - getOutputAmountWithFee

Factory Contract 
- createExchange
- getExchangeAddress


StakingReward Contract 
- totalSupply
- balanceOf
- stake
- withDraw
- getReward
- notifyRewardAmount
- lastTimeRewardApplicable
- rewardPerToken
- earned
- updateReward


NFT Contract 
- setBaseURI
- setSale
- mintPlanet
- tokenURI
- withdraw



## Deloyed Goreli 
Deploying contracts with the account :  0x73e4160145caFC3495F2993FaF86c91F16e54622

Factory Contract Deployed at :  [0xeA8B952Ed4E5393C1935Ba25Fe3e5A2bc85D824C](https://goerli.etherscan.io/address/0xeA8B952Ed4E5393C1935Ba25Fe3e5A2bc85D824C#code)

Token Contract Deployed at :  [0xEF81F5c21741a3cD4e6287EAEc7C35012e670338](https://goerli.etherscan.io/address/0xEF81F5c21741a3cD4e6287EAEc7C35012e670338#code)

Exchange Contract Deployed at :  [0xB322C31048A7aD9e6C600Cee2d7AFb8D62775AB0](https://goerli.etherscan.io/address/0xB322C31048A7aD9e6C600Cee2d7AFb8D62775AB0#code)

StakingReward Contract Deployed at :  [0x2EeB3cEbF066E016a5A12048FD0F3d11026efef2](https://goerli.etherscan.io/address/0x2EeB3cEbF066E016a5A12048FD0F3d11026efef2#code)

NFT Contract Deployed at : [0xAdEE79E77c46f9266Cfb4332F822c740Cd630363](https://goerli.etherscan.io/address/0xAdEE79E77c46f9266Cfb4332F822c740Cd630363#code)

```shell
yarn
yarn hardhat compile
yarn hardhat test test/Exchange.ts

# deploy
yarn  hardhat run --network goerli scripts/deploy.ts
#red hat verify
yarn hardhat verify --network goerli
```
