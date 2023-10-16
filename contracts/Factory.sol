//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import './Exchange.sol';

contract Factory{

    mapping(address => address) tokenToExchangeAddress ;
    mapping(address => address) ExchangeToTokenAddress ;


    function createExchange(address _token)public returns(address) {
        Exchange exchange = new Exchange(_token);
        tokenToExchangeAddress[_token] = address(exchange);
        ExchangeToTokenAddress[address(exchange)] = _token;
        return address(exchange);
    }

    function getExchangeAddress (address _token) public view returns( address){
        return tokenToExchangeAddress[_token];
    }

    function getToken (address _exchange) public view returns( address){
        return ExchangeToTokenAddress[_exchange];
    }
}