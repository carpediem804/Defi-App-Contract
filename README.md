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



## Deloyed Goreli 
Deploying contracts with the account :  0x73e4160145caFC3495F2993FaF86c91F16e54622

Factory Contract Deployed at :  0xeA8B952Ed4E5393C1935Ba25Fe3e5A2bc85D824C

Token Contract Deployed at :  0xEF81F5c21741a3cD4e6287EAEc7C35012e670338

Exchange Contract Deployed at :  0xB322C31048A7aD9e6C600Cee2d7AFb8D62775AB0



```shell
yarn
yarn hardhat compile
yarn hardhat test test/Exchange.ts

# deploy
yarn  hardhat run --network goerli scripts/deploy.ts
#red hat verify
yarn hardhat verify --network goerli
```
