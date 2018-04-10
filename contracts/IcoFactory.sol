pragma solidity ^0.4.21;

import "@daonomic/util/contracts/SecuredImpl.sol";
import "@daonomic/util/contracts/OwnableImpl.sol";

contract IcoFactory {
    event TokenCreated(address addr);
    event SaleCreated(address addr);

    function createIco(bytes token, bytes sale) public {
        address tokenAddress = create(token);
        emit TokenCreated(tokenAddress);
        address saleAddress = create(concat(sale, bytes32(tokenAddress)));
        emit SaleCreated(saleAddress);
        SecuredImpl(tokenAddress).transferRole("minter", saleAddress);
        OwnableImpl(tokenAddress).transferOwnership(msg.sender);
        OwnableImpl(saleAddress).transferOwnership(msg.sender);
    }

    function create(bytes code) internal returns (address addr) {
        assembly {
            addr := create(0, add(code, 0x20), mload(code))
            switch extcodesize(addr) case 0 {revert(0, 0)} default {}
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