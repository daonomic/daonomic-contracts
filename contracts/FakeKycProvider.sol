pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;


import "@daonomic/interfaces/contracts/KycProvider.sol";
import "@daonomic/regulated/contracts/Jurisdictions.sol";


contract FakeKycProvider is KycProvider, Jurisdictions {
    function resolve(address /*_address*/) constant public returns (Investor) {
        return Investor(OTHER, "");
    }
}
