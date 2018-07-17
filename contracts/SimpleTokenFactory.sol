pragma solidity ^0.4.24;


import "./MintableTokenFactory.sol";


contract SimpleTokenFactory is AbstractTokenFactory {

    function createSimpleToken(bytes code, uint[] holders) public {
        address token = createSimpleTokenInternal(code, holders);
        OwnableImpl(token).transferOwnership(msg.sender);
    }

    function createSimpleTokenInternal(bytes code, uint[] memory holders) internal returns (address) {
        address token = deploy(code);
        emit TokenCreated(token);
        createTokenHolders(token, holders);
        return token;
    }
}
