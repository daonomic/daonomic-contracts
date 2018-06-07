pragma solidity ^0.4.24;

import "@daonomic/util/contracts/SecuredImpl.sol";
import "@daonomic/util/contracts/OwnableImpl.sol";
import "@daonomic/interfaces/contracts/MintableToken.sol";
import "@daonomic/regulated/contracts/RegulatedTokenImpl.sol";
import "@daonomic/regulated/contracts/RegulatorServiceImpl.sol";
import "@daonomic/regulated/contracts/KycProviderImpl.sol";
import "@daonomic/regulated/contracts/AllowRegulationRule.sol";
import "@daonomic/regulated/contracts/Jurisdictions.sol";
import "./TokenHolder.sol";

contract IcoFactory is Jurisdictions {
    RegulatorServiceImpl public regulatorService;
    AllowRegulationRule public allowRegulationRule;

    event TokenCreated(address addr);
    event KycProviderCreated(address addr);
    event SaleCreated(address addr);
    event HolderCreated(address addr);

    constructor(RegulatorServiceImpl _regulatorService, AllowRegulationRule _allowRegulationRule) public {
        regulatorService = _regulatorService;
        allowRegulationRule = _allowRegulationRule;
    }

    function createIco(bytes token, address[] memory kycProviders, bytes sale, uint[] memory holders) public {
        address tokenAddress = createTokenInternal(token, kycProviders, holders);
        address saleAddress = deploy(concat(sale, bytes32(tokenAddress)));
        emit SaleCreated(saleAddress);
        SecuredImpl(tokenAddress).transferRole("minter", saleAddress);
        OwnableImpl(saleAddress).transferOwnership(msg.sender);
        OwnableImpl(tokenAddress).transferOwnership(msg.sender);
    }

    function createToken(bytes token, address[] memory kycProviders, uint[] memory holders) public {
        address tokenAddress = createTokenInternal(token, kycProviders, holders);
        OwnableImpl(tokenAddress).transferOwnership(msg.sender);
    }

    function createTokenInternal(bytes token, address[] memory kycProviders, uint[] memory holders) internal returns (address) {
        address tokenAddress;
        if (kycProviders.length != 0) {
            for (uint j = 0; j < kycProviders.length; j++) {
                if (kycProviders[j] == address(0)) {
                    KycProviderImpl newKyc = new KycProviderImpl();
                    newKyc.transferOwnership(msg.sender);
                    emit KycProviderCreated(address(newKyc));
                    kycProviders[j] = newKyc;
                }
            }
            tokenAddress = deploy(concat(token, bytes32(address(regulatorService))));
            regulatorService.setKycProviders(tokenAddress, kycProviders);
            regulatorService.setRule(tokenAddress, ALLOWED, address(allowRegulationRule));
        } else {
            tokenAddress = deploy(token);
        }
        emit TokenCreated(tokenAddress);
        for (uint i = 0; i < holders.length; i++) {
            TokenHolder deployed = new TokenHolder(tokenAddress);
            deployed.transferOwnership(msg.sender);
            MintableToken(tokenAddress).mint(deployed, holders[i]);
            emit HolderCreated(deployed);
        }
        return tokenAddress;
    }

    function deploy(bytes binary) internal returns (address result) {
        assembly {
            result := create(0, add(binary, 0x20), mload(binary))
            switch extcodesize(result) case 0 {revert(0, 0)} default {}
        }
    }

    function concat(bytes _bytes, bytes32 _word) internal pure returns (bytes result) {
        assembly {
            result := mload(0x40)

            //_bytes.length
            let length := mload(_bytes)
            //length of new bytes is _bytes.length + word length (0x20)
            mstore(result, add(length, 0x20))

            //current write memory location (memory counter)
            let mc := add(result, 0x20)
            let end := add(mc, length)

            for {
                //copy counter - read memory location
                let cc := add(_bytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            //store added word
            mstore(end, _word)
            end := add(mc, 0x20)

            //memory end including padding
            mstore(0x40, and(
                add(add(end, iszero(add(0x20, mload(_bytes)))), 31),
                not(31) // Round down to the nearest 32 bytes.
            ))
        }
    }
}