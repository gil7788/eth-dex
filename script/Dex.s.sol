// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Dex} from "../src/Dex.sol";

contract DexScript is Script {
    Dex public dex;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        dex = new Dex();

        vm.stopBroadcast();
    }
}
