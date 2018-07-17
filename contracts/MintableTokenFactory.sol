pragma solidity ^0.4.24;


import "@daonomic/interfaces/contracts/MintableToken.sol";
import "./AbstractTokenFactory.sol";


contract MintableTokenFactory is AbstractTokenFactory {
    function initHolder(address token, address holder, uint amount) internal {
        MintableToken(token).mint(holder, amount);
    }
}
