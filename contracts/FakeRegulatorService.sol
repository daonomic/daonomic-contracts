pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;


import "@daonomic/regulated/contracts/RegulatorService.sol";


contract FakeRegulatorService is RegulatorService {
    function canReceive(address _address, uint256 amount) constant public returns (bool) {
        return true;
    }

    function canSend(address _address, uint256 amount) constant public returns (bool) {
        return true;
    }

    function canMint(address _to, uint256 amount) constant public returns (bool) {
        return true;
    }

    function canTransfer(address _from, address _to, uint256 amount) constant public returns (bool) {
        return true;
    }
}
