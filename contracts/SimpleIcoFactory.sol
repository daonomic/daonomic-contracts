pragma solidity ^0.5.0;


import "./TokenPools.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "@daonomic/lib/contracts/roles/WhitelistAdminRole.sol";
import "./SimpleTokenFactory.sol";
import "./AbstractIcoFactory.sol";



contract SimpleIcoFactory is AbstractIcoFactory, SimpleTokenFactory {

    function createIco(bytes memory tokenCode, bytes memory saleCode, bytes memory poolsCode, address[] memory whitelistAdmins) public {
        address token = createTokenInternal(tokenCode, poolsCode);
        if (saleCode.length != 0) {
            address sale = deploy(concat(saleCode, addressToBytes32(token)));
            for (uint i = 0; i < whitelistAdmins.length; i++) {
                address admin = whitelistAdmins[i];
                if (admin == address(0)) {
                    admin = msg.sender;
                }
                WhitelistAdminRole(sale).addWhitelistAdmin(admin);
            }
            finishCreate(token, sale);
        }
        MinterRole(token).renounceMinter();
    }

    function finishCreate(address token, address sale) internal {
        MinterRole(token).addMinter(sale);
        Ownable(sale).transferOwnership(msg.sender);
        emit SaleCreated(sale);
    }
}