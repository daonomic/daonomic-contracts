pragma solidity ^0.4.24;

import "@daonomic/regulated/contracts/KycProviderImpl.sol";
import "@daonomic/regulated/contracts/WhitelistKycProvider.sol";


contract KycProviderFactory {
    event KycProviderCreated(address addr);

    function createKycProvider(address operator) internal returns (address) {
        KycProviderImpl newKyc = new KycProviderImpl();
        newKyc.transferRole("operator", operator);
        newKyc.transferOwnership(msg.sender);
        emit KycProviderCreated(address(newKyc));
        return address(newKyc);
    }
}
