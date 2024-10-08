// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Script, console} from "forge-std/Script.sol";
// import {Dex} from "../src/Dex.sol";

// contract DexScript is Script {
//     Dex public dex;

//     function setUp() public {}

//     function run() public {
//         // Load the private key from the .env file
//         uint256 privateKey = vm.envUint("PRIVATE_KEY");

//         // Start the broadcast with the private key
//         vm.startBroadcast(privateKey);

//         dex = new Dex();

//         vm.stopBroadcast();
//     }
// }
