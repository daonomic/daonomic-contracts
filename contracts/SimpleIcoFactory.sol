pragma solidity ^0.5.0;


import "@daonomic/lib/contracts/roles/WhitelistAdminRole.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "./TokenPools.sol";
import "./SimpleTokenFactory.sol";
import "./AbstractIcoFactory.sol";



contract SimpleIcoFactory is AbstractIcoFactory, SimpleTokenFactory {

    function createIco(bytes memory tokenCode, bytes memory saleCode, bytes memory poolsCode, address[] memory whitelistAdmins, uint ieoTokens) public {
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
        if (ieoTokens != 0) {
            ERC20Mintable(token).mint(msg.sender, ieoTokens);
        }
        MinterRole(token).renounceMinter();
    }

    function finishCreate(address token, address sale) internal {
        MinterRole(token).addMinter(sale);
        Ownable(sale).transferOwnership(msg.sender);
        emit SaleCreated(sale);
    }
}