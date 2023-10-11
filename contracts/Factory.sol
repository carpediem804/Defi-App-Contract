//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import './Exchange.sol';

contract Factory{

    mapping(address => address) tokenToExchangeAddress ;


    function createExchange(address _token)public returns(address) {
        Exchange exchange = new Exchange(_token);
        tokenToExchangeAddress[_token] = address(exchange);

        return address(exchange);
    }

    function getExchangeAddress (address _token) public view returns( address){
        return tokenToExchangeAddress[_token];
    }
}