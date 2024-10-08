// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Token1} from "../src/Token1.sol";
import {Token2} from "../src/Token2.sol";
import {Dex} from "../src/Dex.sol";

contract TokenDeployment is Script {
    Token1 public token1;
    Token2 public token2;
    Dex public dex;

    function setUp() public {}

    function run() public {
        // Load private key from .env file
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting the transaction
        vm.startBroadcast(privateKey);

        // Deploy Token1 with an initial supply of 1,000,000 tokens
        uint256 initialSupplyToken1 = 1_000_000 * 10 ** 18;
        token1 = new Token1(initialSupplyToken1);
        console.log("Token1 deployed at:", address(token1));

        // Deploy Token2 with an initial supply of 2,000,000 tokens
        uint256 initialSupplyToken2 = 2_000_000 * 10 ** 18;
        token2 = new Token2(initialSupplyToken2);
        console.log("Token2 deployed at:", address(token2));

        // Deploy Dex and pass the addresses of Token1 and Token2 to its constructor
        dex = new Dex(address(token1), address(token2));
        console.log("Dex deployed at:", address(dex));

        // Approve the Dex contract to spend Token1 and Token2
        token1.approve(address(dex), 500_000 * 10 ** 18); // Approve 500,000 Token1
        token2.approve(address(dex), 1_000_000 * 10 ** 18); // Approve 1,000,000 Token2
        console.log("Dex approved to spend tokens on behalf of deployer");

        // Provide initial liquidity to Dex
        dex.provideInitLiqudity(500_000 * 10 ** 18, 1_000_000 * 10 ** 18);
        console.log("Initial liquidity provided to Dex");

        // Stop broadcasting
        vm.stopBroadcast();
    }
}
