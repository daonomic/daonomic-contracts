pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;


import "@daonomic/regulated/contracts/KycProviderImpl.sol";
import "@daonomic/regulated/contracts/RegulatorServiceImpl.sol";
import "./AbstractTokenFactory.sol";
import "./FakeKycProvider.sol";
import "@daonomic/regulated/contracts/AllowRegulationRule.sol";


contract RegulatedTokenFactory is AbstractTokenFactory, Jurisdictions {
    event KycProviderCreated(address addr);

    RegulatorServiceImpl public regulatorService;
    FakeKycProvider public fakeKycProvider;
    AllowRegulationRule public allowRegulationRule;

    constructor(RegulatorServiceImpl _regulatorService, FakeKycProvider _fakeKycProvider, AllowRegulationRule _allowRegulationRule) public {
        regulatorService = _regulatorService;
        fakeKycProvider = _fakeKycProvider;
        allowRegulationRule = _allowRegulationRule;
    }

    function createRegulatedToken(bytes code, address operator, address[] memory kycProviders, uint16[] memory jurisdictions, address[] memory rules, uint[] memory holders) public {
        address token = createRegulatedTokenInternal(code, operator, kycProviders, jurisdictions, rules, holders);
        OwnableImpl(token).transferOwnership(msg.sender);
    }

    function createRegulatedTokenInternal(bytes code, address operator, address[] memory kycProviders, uint16[] memory jurisdictions, address[] memory rules, uint[] memory holders) internal returns (address) {
        address token = deploy(concat(code, bytes32(address(regulatorService))));
        emit TokenCreated(token);
        createTokenHolders(token, holders);
        setKycProviders(token, operator, kycProviders);
        setRules(token, jurisdictions, rules);
        return token;
    }

    function createTokenHolders(address _token, uint[] _amounts) internal {
        address[] memory fakeProviders = new address[](1);
        fakeProviders[0] = address(fakeKycProvider);
        regulatorService.setKycProviders(_token, fakeProviders);
        regulatorService.setRule(_token, OTHER, allowRegulationRule);
        super.createTokenHolders(_token, _amounts);
    }

    function setKycProviders(address token, address operator, address[] memory kycProviders) internal {
        for (uint i = 0; i < kycProviders.length; i++) {
            if (kycProviders[i] == address(0)) {
                kycProviders[i] = createKycProvider(operator);
            }
        }
        regulatorService.setKycProviders(token, kycProviders);
    }

    function createKycProvider(address operator) internal returns (address) {
        KycProviderImpl newKyc = new KycProviderImpl();
        newKyc.transferRole("operator", operator);
        newKyc.transferOwnership(msg.sender);
        emit KycProviderCreated(address(newKyc));
        return address(newKyc);
    }

    function setRules(address token, uint16[] memory jurisdictions, address[] memory rules) internal {
        require(jurisdictions.length == rules.length);
        for (uint i = 0; i < jurisdictions.length; i++) {
            regulatorService.setRule(token, jurisdictions[i], rules[i]);
        }
    }
}
