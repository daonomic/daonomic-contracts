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
import "./NonMintableTokenFactory.sol";


contract TransferringIcoFactory is Jurisdictions, NonMintableTokenFactory, SimpleTokenFactory, RegulatedTokenFactory {
    using SafeMath for uint;

    event SaleCreated(address addr);

    constructor(RegulatorServiceImpl _regulatorService, FakeKycProvider _fakeKycProvider, AllowRegulationRule _allowRegulationRule) RegulatedTokenFactory(_regulatorService, _fakeKycProvider, _allowRegulationRule) public {
    }

    function createSimpleIco(bytes tokenCode, uint cap, uint[] memory holders, bytes saleCode) public {
        address token = createSimpleTokenInternal(tokenCode, holders);
        address sale = deploy(concat(saleCode, bytes32(token)));
        BasicToken(token).transfer(sale, cap);
        BasicToken(token).transfer(msg.sender, BasicToken(token).balanceOf(this));
        transferOwnerships(token, sale);
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