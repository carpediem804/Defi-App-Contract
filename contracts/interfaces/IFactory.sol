//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

interface IFactory {
    function getExchangeAddress (address _token) external view returns( address);
 
}