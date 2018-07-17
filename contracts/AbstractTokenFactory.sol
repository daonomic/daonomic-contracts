pragma solidity ^0.4.24;


import "./Deployer.sol";
import "./TokenHolder.sol";


contract AbstractTokenFactory is Deployer {
    event TokenCreated(address addr);
    event HolderCreated(address addr);

    function createTokenHolders(address token, uint[] amounts) internal {
        for (uint i = 0; i < amounts.length; i++) {
            TokenHolder deployed = new TokenHolder(token);
            deployed.transferOwnership(msg.sender);
            initHolder(token, deployed, amounts[i]);
            emit HolderCreated(deployed);
        }
    }

    function initHolder(address token, address holder, uint amount) internal;
}
