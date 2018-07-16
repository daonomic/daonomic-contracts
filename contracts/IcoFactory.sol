pragma solidity ^0.4.24;


import "@daonomic/util/contracts/SecuredImpl.sol";
import "@daonomic/util/contracts/OwnableImpl.sol";
import "@daonomic/interfaces/contracts/MintableToken.sol";
import "@daonomic/regulated/contracts/RegulatedTokenImpl.sol";
import "@daonomic/regulated/contracts/RegulatorServiceImpl.sol";
import "@daonomic/regulated/contracts/KycProviderImpl.sol";
import "@daonomic/regulated/contracts/AllowRegulationRule.sol";
import "@daonomic/regulated/contracts/UsRegulationRule.sol";
import "@daonomic/regulated/contracts/Jurisdictions.sol";
import "./TokenHolder.sol";
import "./SimpleTokenFactory.sol";
import "./RegulatedTokenFactory.sol";


contract IcoFactory is Jurisdictions, SimpleTokenFactory, RegulatedTokenFactory {
    using SafeMath for uint;

    event SaleCreated(address addr);

    constructor(RegulatorServiceImpl _regulatorService, FakeKycProvider _fakeKycProvider, AllowRegulationRule _allowRegulationRule) RegulatedTokenFactory(_regulatorService, _fakeKycProvider, _allowRegulationRule) public {
    }

    function createSimpleIco(bytes tokenCode, uint[] memory holders, bytes saleCode) public {
        address token = createSimpleTokenInternal(tokenCode, holders);
        address sale = deploy(concat(saleCode, bytes32(token)));
        finishCreate(token, sale);
    }

    function createTransferringIco(bytes tokenCode, uint cap, uint[] memory holders, bytes saleCode) public {
        address token = createSimpleTokenInternal(tokenCode, holders);
        address sale = deploy(concat(saleCode, bytes32(token)));
        BasicToken(token).transfer(sale, cap);
        BasicToken(token).transfer(msg.sender, BasicToken(token).totalSupply().sub(cap));
        transferOwnerships(token, sale);
    }

    function createKycIco(bytes tokenCode, uint[] memory holders, bytes saleCode, address operator, address kycProvider) public {
        if (kycProvider == address(0)) {
            kycProvider = createKycProvider(operator);
        }
        address token = createSimpleTokenInternal(tokenCode, holders);
        address sale = deploy(concat(saleCode, bytes32(token), bytes32(address(kycProvider))));
        finishCreate(token, sale);
    }

    function createSecurityIco(bytes tokenCode, address operator, address[] memory kycProviders, uint16[] memory jurisdictions, address[] memory rules, uint[] memory holders, bytes saleCode) public {
        address token = createRegulatedTokenInternal(tokenCode, operator, kycProviders, jurisdictions, rules, holders);
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