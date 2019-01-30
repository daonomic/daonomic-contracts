pragma solidity ^0.5.0;

import "./Deployer.sol";

contract AbstractTokenFactory is Deployer {
    event TokenCreated(address addr);
    event PoolsCreated(address addr);
}
