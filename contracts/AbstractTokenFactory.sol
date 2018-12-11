pragma solidity ^0.4.24;

import "./Deployer.sol";

contract AbstractTokenFactory is Deployer {
    event TokenCreated(address addr);
}
