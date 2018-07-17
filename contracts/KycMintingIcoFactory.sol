pragma solidity ^0.4.24;


import "@daonomic/util/contracts/SafeMath.sol";
import "./KycProviderFactory.sol";
import "./MintableTokenFactory.sol";
import "./SimpleTokenFactory.sol";


contract KycMintingIcoFactory is KycProviderFactory, MintableTokenFactory, SimpleTokenFactory {
    event SaleCreated(address addr);

    function createIco(bytes tokenCode, uint[] memory holders, bytes saleCode, address operator, address kycProvider) public {
        if (kycProvider == address(0)) {
            kycProvider = createKycProvider(operator);
        }
        address token = createTokenInternal(tokenCode, holders);
        address sale = deploy(concat(saleCode, bytes32(token), bytes32(address(kycProvider))));
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