pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;


import "@daonomic/interfaces/contracts/KycProvider.sol";
import "@daonomic/regulated/contracts/Jurisdictions.sol";


contract FakeKycProvider is KycProvider, Jurisdictions {
    /**
     * @dev resolve investor address
     * @param _address Investor's Ethereum address
     * @return struct representing investor - its jurisdiction and some generic data
     */
    function resolve(address _address) constant public returns (Investor) {
        return Investor(OTHER, "");
    }
}
