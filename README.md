## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Setup
1. Pull basic foundry template.
```bash
$ forge init --template https://github.com/foundry-rs/forge-template eth-dex
```

2. Create, link and commit to repository
```bash
git commit
git remote add origin <REPO-URL>
```

3. Install openzeppelin dependecies
```bash
forge install OpenZeppelin/openzeppelin-contracts
```
Or
```bash
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```
### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### BuildBear
#### BuildBear Deployment
```bash
forge script script/Dex.s.sol:DexScript --rpc-url buildbear --broadcast --slow
```

To verify the deployed contracts, execute the following command:
```bash
forge verify-contract --constructor-args "" --etherscan-api-key "verifyContract" --verifier-url "<https://rpc.buildbear.io/verify/etherscan/gradual-blade-6d2a5b2a>" <DEPLOYED_CONTRACT_ADDRESS> src/Dex.sol:Dex
```
### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
