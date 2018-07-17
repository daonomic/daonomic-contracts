pragma solidity ^0.4.24;


import "./SimpleTokenFactory.sol";
import "./NonMintableTokenFactory.sol";
import "@daonomic/util/contracts/SafeMath.sol";


contract SimpleTransferringIcoFactory is SimpleTokenFactory, NonMintableTokenFactory {
    event SaleCreated(address addr);

    function afterTokenCreate(address token) internal {
        super.afterTokenCreate(token);
        BasicToken(token).transfer(msg.sender, BasicToken(token).balanceOf(this));
    }

    function createIco(bytes tokenCode, uint cap, uint[] memory holders, bytes saleCode) public {
        address token = createTokenInternal(tokenCode, holders);
        address sale = deploy(concat(saleCode, bytes32(token)));
        BasicToken(token).transfer(sale, cap);
        BasicToken(token).transfer(msg.sender, BasicToken(token).balanceOf(this));
        finishCreate(token, sale);
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