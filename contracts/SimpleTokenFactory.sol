pragma solidity ^0.5.0;


import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "./AbstractTokenFactory.sol";


contract SimpleTokenFactory is AbstractTokenFactory {

    function createToken(bytes memory code, bytes memory poolsCode) public {
        address token = createTokenInternal(code, poolsCode);
        afterTokenCreate(token);
    }

    function afterTokenCreate(address token) internal {
        MinterRole(token).addMinter(msg.sender);
        MinterRole(token).renounceMinter();
    }

    function createTokenInternal(bytes memory code, bytes memory poolsCode) internal returns (address) {
        address token = deploy(code);
        emit TokenCreated(token);
        if (poolsCode.length != 0) {
            deployPoolsInternal(poolsCode, token);
        }
        return token;
    }

    function deployPoolsInternal(bytes memory poolsCode, address token) internal {
        address pools = deploy(concat(poolsCode, addressToBytes32(token)));
        Ownable(pools).transferOwnership(msg.sender);
        MinterRole(token).addMinter(pools);
        emit PoolsCreated(pools);
    }
}
