pragma solidity ^0.4.24;

import "@daonomic/regulated/contracts/KycProviderImpl.sol";
import "@daonomic/regulated/contracts/WhitelistKycProvider.sol";


contract WhitelistFactory {
    event KycProviderCreated(address addr);

    function createWhitelist(address operator) internal returns (address) {
        WhitelistKycProvider newWhitelist = new WhitelistKycProvider();
        newWhitelist.transferRole("operator", operator);
        newWhitelist.transferOwnership(msg.sender);
        emit KycProviderCreated(address(newWhitelist));
        return address(newWhitelist);
    }
}
