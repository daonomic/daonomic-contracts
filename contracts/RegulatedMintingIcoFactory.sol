pragma solidity ^0.4.24;


import "./MintableTokenFactory.sol";
import "./RegulatedTokenFactory.sol";


contract RegulatedMintingIcoFactory is MintableTokenFactory, RegulatedTokenFactory {
    event SaleCreated(address addr);

    constructor(RegulatorServiceImpl _regulatorService, FakeRegulatorService _fakeRegulatorService) RegulatedTokenFactory(_regulatorService, _fakeRegulatorService) public {
    }

    function createIco(bytes tokenCode, address operator, address[] memory kycProviders, uint16[] memory jurisdictions, address[] memory rules, uint[] memory holders, bytes saleCode) public {
        address token = createRegulatedTokenInternal(tokenCode, operator, kycProviders, jurisdictions, rules, holders);
        setKycProviders(token, operator, kycProviders);
        setRules(token, jurisdictions, rules);

        address sale = deploy(concat(saleCode, bytes32(token)));
        finishCreate(token, sale);
    }

    function afterTokenCreate(address token) internal {

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