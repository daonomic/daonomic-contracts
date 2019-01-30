pragma solidity ^0.5.0;


import "./TokenPools.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./SimpleTokenFactory.sol";
import "./AbstractIcoFactory.sol";


contract SimpleIcoFactory is AbstractIcoFactory, SimpleTokenFactory  {

    function createIco(bytes memory tokenCode, bytes memory saleCode, bytes memory poolsCode) public {
        address token = createTokenInternal(tokenCode, poolsCode);
        address sale = deploy(concat(saleCode, addressToBytes32(token)));
        finishCreate(token, sale);
    }

    function finishCreate(address token, address sale) internal {
        MinterRole(token).addMinter(sale);
        MinterRole(token).renounceMinter();
        Ownable(sale).transferOwnership(msg.sender);
        emit SaleCreated(sale);
    }
}