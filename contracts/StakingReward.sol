//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract StakingRewords is Ownable{

    IERC20 public stakingToken;
    IERC20 public rewardsToken;

    //초당 리워드 개수 
    uint256 public rewardRate = 0;


    //스테이킹 기간
    uint256 public rewardsDutration = 365 days;

    // 스테이킹 끝나는 시간 
    uint256 public periodFinish = 0;

    //마지막 업데이트 시간 
    uint256 public lastUpdateTime;

    // 각 구간별 토킁당 리워드의 누적값 (전체 구간의 리워드 )
    // 토큰 1개당 리워드 값 스테이킹이 바뀔때 바뀐다 
    uint256 public rewardPerTokenStored;

    //이미 계산된 유저의 리워드 총합 
    mapping(address=>uint256) public userRewardPerTokenPaid ;

    //출금 가능한 누적된 리워드의 총합 (누적 보상) for dp 
    mapping(address=>uint256) public rewards ;

    //전체 스테이킹 된 토큰 개수 
    uint256 private _totalSupply ;

    //유저의 스테이킹 개수 
    mapping(address=>uint256) private _balances;

    constructor(address _rewardsToken, address _stackingToken){
        stakingToken = IERC20(_stackingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    function totalSupply () external view returns(uint256){
        return _totalSupply;
    }

    function balanceOf (address account) external view returns(uint256){
        return _balances[account];
    }

    function stake(uint256 amount) external updateReward(msg.sender){
        require(amount>0,"more than 0 ");
        _totalSupply +=amount;
        _balances[msg.sender] += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
    }


    function withDraw(uint256 amount) public updateReward(msg.sender) {
        require(amount>0,"more than 0 ");
        _totalSupply -=amount;
        _balances[msg.sender] -= amount;
        stakingToken.transfer(msg.sender, amount);
    }


    function getReward() public updateReward(msg.sender){
        uint256 reward = rewards[msg.sender];
        if(reward>0){
            rewards[msg.sender]=0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }


    function notifyRewardAmount(uint256 reward ) external onlyOwner updateReward(address(0)){
        //처음 보상을 설정하거나 스테이킹 기간이 끝난 경우 
        // period Finish 의 초기값이 0으로 설정되어 있다 
        if(block.timestamp>=periodFinish){
            //reward가 31536000 (60*60*24*365)라면 1초에 1개의 리워드 코인이 분배 
            rewardRate = reward/rewardsDutration;
        }else{
            //스테이킹 종료 전 추가로 리워드를 배정하는 경우 
            uint256 remaningTime = periodFinish -block.timestamp;
            uint256 leftover = remaningTime * rewardRate; //아직 분배되지 않은 리워드 코인 개수 
            rewardRate = reward + leftover / rewardsDutration;
        }

        uint256 balance = rewardsToken.balanceOf(address(this));
        require(
            rewardRate <= balance/rewardsDutration,
            // 보상하려고 남아 있는 리워드 코인 개수가 더 적다 
            " provided reward too high"
        );

        lastUpdateTime = block.timestamp;

        //스테이킹 종료 시간 업데이트, 현재 시간에서 1년을 연장한다 
        periodFinish = block.timestamp + rewardsDutration;
    }



    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    /**
        rewardPerToken : 
        구간에서 스테이킹 토큰 하나당 보상 토큰의 개수를 의미 
        rewardPerTokenStored : 구간 변화에 따른 rewardPerToken의 누적값
     */

    function rewardPerToken() public view returns(uint256){
        if(_totalSupply == 0){
            return rewardPerTokenStored;
        }

        return rewardPerTokenStored + (
            rewardRate*
            (lastTimeRewardApplicable()-lastUpdateTime)
            *1e18)//구간  
            / _totalSupply;
    }

    function earned (address account) public view returns(uint256){
        // _balances[account] *rewardPerToken() -> account의 전체 구간의 보상
        // _balances[account] *userRewardPerTokenPaid[account] -> 이미 계산된 바로 전 구간의 보상
        //userRewardPerTokenPaid[account] = 이미 계산되서 보상 되었다 
        // 5~15초 보상 구할때 이미 계산된 5~10초 꺼 뺀다 
        //보상에 누적된 보상 더하는거 
        return (
            _balances[account] *
            (rewardPerToken() - userRewardPerTokenPaid[account])
        )
        / 1e18 
        + rewards[account];// 5~10초 보상을 받지않았으면 rewards값에 저장되어 있다 
    }


    //balance가 바뀌기 전에 이거한다! 
    modifier updateReward(address account){
        lastUpdateTime = lastTimeRewardApplicable();

        // 토큰의 개수가 변할때마다 모든 account에 영향 
        rewardPerTokenStored = rewardPerToken();
        
        if(account != address(0)){
            //account에 해당하는 값만 바뀐다
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }



}