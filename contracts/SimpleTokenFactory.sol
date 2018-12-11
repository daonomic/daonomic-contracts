pragma solidity ^0.4.24;


import "./AbstractTokenFactory.sol";
import "@daonomic/util/contracts/OwnableImpl.sol";


contract SimpleTokenFactory is AbstractTokenFactory {

    function createToken(bytes code) public {
        address token = createTokenInternal(code);
        afterTokenCreate(token);
    }

    function afterTokenCreate(address token) internal {
        OwnableImpl(token).transferOwnership(msg.sender);
    }

    function createTokenInternal(bytes code) internal returns (address) {
        address token = deploy(code);
        emit TokenCreated(token);
        return token;
    }
}
