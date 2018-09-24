pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;


import "@daonomic/regulated/contracts/Jurisdictions.sol";
import "@daonomic/regulated/contracts/RegulatorServiceImpl.sol";
import "@daonomic/regulated/contracts/RegulatedTokenImpl.sol";
import "@daonomic/regulated/contracts/AllowRegulationRule.sol";
import "./AbstractTokenFactory.sol";
import "./KycProviderFactory.sol";
import "./FakeRegulatorService.sol";


contract RegulatedTokenFactory is Jurisdictions, AbstractTokenFactory, KycProviderFactory {

    RegulatorServiceImpl public regulatorService;
    FakeRegulatorService public fakeRegulatorService;

    constructor(RegulatorServiceImpl _regulatorService, FakeRegulatorService _fakeRegulatorService) public {
        regulatorService = _regulatorService;
        fakeRegulatorService = _fakeRegulatorService;
    }

    function createToken(bytes code, address operator, address[] memory kycProviders, uint16[] memory jurisdictions, address[] memory rules, uint[] memory holders) public {
        address token = createTokenInternal(code, operator, kycProviders, jurisdictions, rules, holders);
        setKycProviders(token, operator, kycProviders);
        setRules(token, jurisdictions, rules);
        afterTokenCreate(token);
        RegulatedTokenImpl(token).setRegulatorService(regulatorService);
        OwnableImpl(token).transferOwnership(msg.sender);
    }

    function afterTokenCreate(address token) internal;

    function createTokenInternal(bytes code, address operator, address[] memory kycProviders, uint16[] memory jurisdictions, address[] memory rules, uint[] memory holders) internal returns (address) {
        address token = deploy(concat(code, bytes32(address(regulatorService))));
        emit TokenCreated(token);
        RegulatedTokenImpl(token).setRegulatorService(fakeRegulatorService);
        createTokenHolders(token, holders);
        return token;
    }

    function setKycProviders(address token, address operator, address[] memory kycProviders) internal {
        for (uint i = 0; i < kycProviders.length; i++) {
            if (kycProviders[i] == address(0)) {
                kycProviders[i] = createKycProvider(operator);
            }
        }
        regulatorService.setKycProviders(token, kycProviders);
    }

    function setRules(address token, uint16[] memory jurisdictions, address[] memory rules) internal {
        require(jurisdictions.length == rules.length);
        for (uint i = 0; i < jurisdictions.length; i++) {
            regulatorService.setRule(token, jurisdictions[i], rules[i]);
        }
    }
}
