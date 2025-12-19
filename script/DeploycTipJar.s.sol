// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {cTipJar} from "../src/cTipJar.sol";

/**
 * @title DeploycTipJar
 * @notice Deployment script for cTipJar contract on Celo.
 * @dev Run with: forge script script/DeploycTipJar.s.sol --rpc-url <celo-rpc> --private-key <pk>
 */
contract DeploycTipJar is Script {
    address constant CUSD = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1; // cUSD on Celo Sepolia
    address constant OWNER = 0x6108F2c669f96Fac888F6d92799AecfcdcC055Ce; // From .env

    function run() external {
        vm.startBroadcast();
        cTipJar tipJar = new cTipJar(CUSD, OWNER);
        vm.stopBroadcast();

        console.log("cTipJar deployed at:", address(tipJar));
    }
}