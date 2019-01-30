pragma solidity ^0.5.0;

contract Deployer {
    function addressToBytes32(address addr) pure internal returns (bytes32) {
        return bytes32(uint256(addr));
    }

    function deploy(bytes memory binary) internal returns (address result) {
        assembly {
            result := create(0, add(binary, 0x20), mload(binary))
            switch extcodesize(result) case 0 {revert(0, 0)} default {}
        }
    }

    function concat(bytes memory _bytes, bytes32 _word) internal pure returns (bytes memory result) {
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
                add(add(end, iszero(add(length, 0x20))), 31),
                not(31) // Round down to the nearest 32 bytes.
            ))
        }
    }

    function concat(bytes memory _bytes, bytes32 _word1, bytes32 _word2) internal pure returns (bytes memory result) {
        assembly {
            result := mload(0x40)

            //_bytes.length
            let length := mload(_bytes)
            //length of new bytes is _bytes.length + word length x 2 (0x20 x 2)
            mstore(result, add(length, 0x40))

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

            //store added words
            mstore(end, _word1)
            mstore(add(end, 0x20), _word2)
            end := add(mc, 0x40)

            //memory end including padding
            mstore(0x40, and(
                add(add(end, iszero(add(0x20, mload(_bytes)))), 31),
                not(31) // Round down to the nearest 32 bytes.
            ))
        }
    }
}
