//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./THToken.sol";

contract MasterChef is Ownable{
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt; // 이미 수령하거나, 스테이킹하지 않아서 보상계산에서 제외하는 값 
    }

    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accTHPerShare; // 전체 LP토큰의 예치 수량이 변할때마다 계산하여 누적, accTHPerShare에 예치량을 곱하면 구간에서 보상의 개수를 구함 

    }

    //Goveranece token 
    THToken public th;

    // DEV address
    address public devaddr ; //일부 비용을 개발자 계정으로  수수료 목적

    uint256 public thPerBlock ; //블록마다 얼마나 가져갈지 

    PoolInfo[] public poolInfo;
    mapping(uint256 =>mapping(address=>UserInfo)) public userInfo;

    uint256 public totalAllocPoint =0;

    //the block number when th minging starts . 
    uint256 public startBlock ;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(THToken _th, address _devaddr, uint256 _thPerBlock, uint256 _startBlock){
        th = _th;
        devaddr = _devaddr;
        thPerBlock = _thPerBlock;
        startBlock = _startBlock;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

     // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
         if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(
            PoolInfo({lpToken: _lpToken, allocPoint: _allocPoint, lastRewardBlock: lastRewardBlock, accTHPerShare: 0})
        );
    }

    // Update the given pool's CAKE allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint, /// 1000 -> 20000
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint - prevAllocPoint + _allocPoint;
        }
    }

     // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to - _from;
    }

    

    // View function to see pending CAKEs on frontend.
    function pendingTH(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accTHPerShare = pool.accTHPerShare; //이전 구간까지 받게되는 하나당 reward
        uint256 lpSupply = pool.lpToken.balanceOf(address(this)); //master chef 스테이킹 된 LP토큰 개수 
        
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 thReward = multiplier * thPerBlock * pool.allocPoint / totalAllocPoint;
            accTHPerShare = accTHPerShare + (thReward * 1e12 / lpSupply);
        }
        return user.amount * accTHPerShare / 1e12 - user.rewardDebt;
    }
 
      // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public { // 출금, 입금 둘다 
    //가장 중요한 역할 : accRewardPerShare 업데이트 
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 thReward = multiplier * thPerBlock * pool.allocPoint / totalAllocPoint;
        th.mint(devaddr, thReward / 10); //개발자가 10프로
        th.mint(address(this), thReward); //master chef 주소에 lp토큰 민팅
        pool.accTHPerShare = pool.accTHPerShare + (thReward * 1e12 / lpSupply);
        pool.lastRewardBlock = block.number;
    }

     // Deposit LP tokens to MasterChef for CAKE allocation.
    function deposit(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);

        //pending되어 있는 토큰만큼 보상을 바로 줘버린다 
        if (user.amount > 0) {
            uint256 pending = user.amount * pool.accTHPerShare / 1e12 - user.rewardDebt; //user.rewardDebt = 이미 받아간거 
            
            if (pending > 0) {
                th.transfer(msg.sender, pending);
            }
        }

        if (_amount > 0) {
            pool.lpToken.transferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount + _amount;
        }
        user.rewardDebt = user.amount * pool.accTHPerShare / 1e12;
        emit Deposit(msg.sender, _pid, _amount);
    }


    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint256 pending = user.amount * pool.accTHPerShare / 1e12 - user.rewardDebt;
        if (pending > 0) {
            th.transfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount - _amount;
            pool.lpToken.transfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount * pool.accTHPerShare /1e12;
        emit Withdraw(msg.sender, _pid, _amount);
    }

     // Withdraw without caring about rewards. EMERGENCY ONLY.
     // 스테이킹한 토큰만 보내는 것 
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.transfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }


}