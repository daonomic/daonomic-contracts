pragma solidity ^0.4.24;


import "@daonomic/util/contracts/SafeMath.sol";
import "./SimpleTokenFactory.sol";
import "./AbstractIcoFactory.sol";
import "./WhitelistFactory.sol";


contract WhitelistMintingIcoFactory is AbstractIcoFactory, WhitelistFactory, SimpleTokenFactory {

    function createIco(bytes tokenCode, bytes saleCode, address operator, address whitelist) public {
        if (whitelist == address(0)) {
            whitelist = createWhitelist(operator);
        }
        address token = createTokenInternal(tokenCode);
        address sale = deploy(concat(saleCode, bytes32(token), bytes32(address(whitelist))));
        finishCreate(token, sale);
    }

    function finishCreate(address token, address sale) internal {
        SecuredImpl(token).transferRole("minter", sale);
        transferOwnerships(token, sale);
    }

    function transferOwnerships(address token, address sale) internal {
        emit SaleCreated(sale);
        OwnableImpl(sale).transferOwnership(msg.sender);
        OwnableImpl(token).transferOwnership(msg.sender);
    }
}