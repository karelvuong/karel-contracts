// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { Disperse } from "../src/Disperse.sol";
import "forge-std/Script.sol";

contract DisperseScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        new Disperse(deployer);

        vm.stopBroadcast();
    }
}
