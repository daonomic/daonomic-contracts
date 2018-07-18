pragma solidity ^0.4.24;


import "@daonomic/util/contracts/SafeMath.sol";
import "@daonomic/util/contracts/SecuredImpl.sol";
import "./MintableTokenFactory.sol";
import "./SimpleTokenFactory.sol";
import "./AbstractIcoFactory.sol";


contract SimpleMintingIcoFactory is AbstractIcoFactory, MintableTokenFactory, SimpleTokenFactory {

    function createIco(bytes tokenCode, uint[] memory holders, bytes saleCode) public {
        address token = createTokenInternal(tokenCode, holders);
        address sale = deploy(concat(saleCode, bytes32(token)));
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