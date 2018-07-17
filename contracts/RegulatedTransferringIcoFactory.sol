pragma solidity ^0.4.24;


import "./RegulatedTokenFactory.sol";
import "./NonMintableTokenFactory.sol";


contract RegulatedTransferringIcoFactory is NonMintableTokenFactory, RegulatedTokenFactory {
    event SaleCreated(address addr);

    constructor(RegulatorServiceImpl _regulatorService, FakeRegulatorService _fakeRegulatorService) RegulatedTokenFactory(_regulatorService, _fakeRegulatorService) public {
    }

    function createIco(bytes tokenCode, uint cap, address operator, address[] memory kycProviders, uint16[] memory jurisdictions, address[] memory rules, uint[] memory holders, bytes saleCode) public {
        address token = createRegulatedTokenInternal(tokenCode, operator, kycProviders, jurisdictions, rules, holders);
        address sale = deploy(concat(saleCode, bytes32(token)));
        emit SaleCreated(sale);

        BasicToken(token).transfer(sale, cap);
        BasicToken(token).transfer(msg.sender, BasicToken(token).balanceOf(this));

        setKycProviders(token, operator, kycProviders);
        setRules(token, jurisdictions, rules);
        finishCreate(token, sale);
    }

    function afterTokenCreate(address token) internal {
        BasicToken(token).transfer(msg.sender, BasicToken(token).balanceOf(this));
    }

    function finishCreate(address token, address sale) internal {
        RegulatedTokenImpl(token).setRegulatorService(regulatorService);
        OwnableImpl(sale).transferOwnership(msg.sender);
        OwnableImpl(token).transferOwnership(msg.sender);
    }
}