pragma solidity ^0.4.22;

import "@daonomic/util/contracts/OwnableImpl.sol";
import "@daonomic/interfaces/contracts/Token.sol";

contract TokenHolder is OwnableImpl {
    Token public token;

    constructor(address _token) public {
        token = Token(_token);
    }

    function transfer(address beneficiary, uint256 amount) onlyOwner public {
        token.transfer(beneficiary, amount);
    }
}
