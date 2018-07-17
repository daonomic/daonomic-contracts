pragma solidity ^0.4.24;


import "@daonomic/interfaces/contracts/BasicToken.sol";
import "./AbstractTokenFactory.sol";


contract NonMintableTokenFactory is AbstractTokenFactory {
    function initHolder(address token, address holder, uint amount) internal {
        BasicToken(token).transfer(holder, amount);
    }
}
