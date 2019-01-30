pragma solidity ^0.5.0;

import "@daonomic/sale/contracts/Pools.sol";

contract TokenPools is Pools {

    constructor(ERC20Mintable _token) Pools(_token) public {
        registerPool("direct", 1000 * 10 ** 3, 0, StartType.Direct); // Direct transfer
        registerPool("floating", 1000 * 10 ** 3, 1000 * 86400, StartType.Floating); // 1000 days
        registerPool("fixed", 1000 * 10 ** 3, 1548845542, StartType.Fixed); //Jan 30, 2019
    }
}
