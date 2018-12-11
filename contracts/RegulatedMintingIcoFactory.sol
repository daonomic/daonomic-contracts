pragma solidity ^0.4.24;


import "./RegulatedTokenFactory.sol";
import "./AbstractIcoFactory.sol";


contract RegulatedMintingIcoFactory is AbstractIcoFactory, AbstractTokenFactory, RegulatedTokenFactory {

    constructor(RegulatorServiceImpl _regulatorService) RegulatedTokenFactory(_regulatorService) public {
    }

    function createIco(bytes tokenCode, address operator, address[] memory kycProviders, uint16[] memory jurisdictions, address[] memory rules, bytes saleCode) public {
        address token = createTokenInternal(tokenCode, operator, kycProviders, jurisdictions, rules);
        setKycProviders(token, operator, kycProviders);
        setRules(token, jurisdictions, rules);

        address sale = deploy(concat(saleCode, bytes32(token)));
        finishCreate(token, sale);
    }

    function finishCreate(address token, address sale) internal {
        SecuredImpl(token).transferRole("minter", sale);
        transferOwnerships(token, sale);
    }

    function transferOwnerships(address token, address sale) internal {
        emit SaleCreated(sale);
        RegulatedTokenImpl(token).setRegulatorService(regulatorService);
        OwnableImpl(sale).transferOwnership(msg.sender);
        OwnableImpl(token).transferOwnership(msg.sender);
    }
}