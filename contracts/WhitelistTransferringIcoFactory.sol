pragma solidity ^0.4.24;


import "./SimpleTokenFactory.sol";
import "./NonMintableTokenFactory.sol";
import "./AbstractIcoFactory.sol";
import "./WhitelistFactory.sol";


contract WhitelistTransferringIcoFactory is AbstractIcoFactory, WhitelistFactory, NonMintableTokenFactory, SimpleTokenFactory {

    function createIco(bytes tokenCode, uint cap, uint[] memory holders, bytes saleCode, address operator, address whitelist) public {
        if (whitelist == address(0)) {
            whitelist = createWhitelist(operator);
        }
        address token = createTokenInternal(tokenCode, holders);
        address sale = deploy(concat(saleCode, bytes32(token), bytes32(address(whitelist))));
        BasicToken(token).transfer(sale, cap);
        BasicToken(token).transfer(msg.sender, BasicToken(token).balanceOf(this));
        finishCreate(token, sale);
    }

    function afterTokenCreate(address token) internal {
        super.afterTokenCreate(token);
        BasicToken(token).transfer(msg.sender, BasicToken(token).balanceOf(this));
    }

    function finishCreate(address token, address sale) internal {
        transferOwnerships(token, sale);
    }

    function transferOwnerships(address token, address sale) internal {
        emit SaleCreated(sale);
        OwnableImpl(sale).transferOwnership(msg.sender);
        OwnableImpl(token).transferOwnership(msg.sender);
    }
}