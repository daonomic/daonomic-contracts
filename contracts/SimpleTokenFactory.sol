pragma solidity ^0.4.24;


import "./MintableTokenFactory.sol";


contract SimpleTokenFactory is AbstractTokenFactory {

    function createToken(bytes code, uint[] holders) public {
        address token = createTokenInternal(code, holders);
        afterTokenCreate(token);
    }

    function afterTokenCreate(address token) internal {
        OwnableImpl(token).transferOwnership(msg.sender);
    }

    function createTokenInternal(bytes code, uint[] memory holders) internal returns (address) {
        address token = deploy(code);
        emit TokenCreated(token);
        createTokenHolders(token, holders);
        return token;
    }
}
