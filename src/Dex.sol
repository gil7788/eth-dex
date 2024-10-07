// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Dex is Context, Ownable {
    ERC20 private _tokenA;
    ERC20 private _tokenB;

    /**
     * @dev Constructor that accepts the deployed addresses of Token1 and Token2.
     */
    constructor(
        address token1Address,
        address token2Address
    ) Ownable(msg.sender) {
        _tokenA = ERC20(token1Address);
        _tokenB = ERC20(token2Address);
    }

    function provideInitLiqudity(
        uint256 token1Amount,
        uint256 token2Amount
    ) public onlyOwner {
        _addLiquidity(token1Amount, token2Amount);
    }
    // Swap functionality
    function swap(address from, address to, uint256 amount) public {
        address tokenAAddress = address(_tokenA);
        address tokenBAddress = address(_tokenB);
        address owner = _msgSender();
        require(
            (from == tokenAAddress && to == tokenBAddress) ||
                (from == tokenBAddress && to == tokenAAddress),
            "Invalid token pair"
        );

        ERC20 fromToken = ERC20(from);
        ERC20 toToken = ERC20(to);
        require(fromToken.balanceOf(owner) >= amount, "Insufficient Amount");

        uint256 price = getTokenPrice(from, to, amount);
        fromToken.transferFrom(owner, address(this), amount);
        toToken.transfer(owner, price);
    }

    function getTokenPrice(
        address from,
        address to,
        uint256 amount
    ) internal view returns (uint256) {
        ERC20 erc20From = ERC20(from);
        ERC20 erc20To = ERC20(to);
        uint256 balanceFrom = erc20From.balanceOf(address(this));
        uint256 balanceTo = erc20To.balanceOf(address(this));

        uint256 price = (
            ceilDiv(balanceFrom * balanceTo, balanceFrom + amount)
        ) - balanceTo;
        return price;
    }

    function addLiquidity(address token, uint256 amount) public {
        require(
            token == address(_tokenA) || token == address(_tokenB),
            "Invalid token"
        );

        ERC20 erc20Token = ERC20(token);
        uint256 balanceFrom = erc20Token.balanceOf(address(this));

        if (token == address(_tokenA)) {
            uint256 balanceTo = _tokenB.balanceOf(address(this));
            uint256 amountTo = ceilDiv(amount * balanceTo, balanceFrom);
            _addLiquidity(amount, amountTo);
        } else if (token == address(_tokenB)) {
            uint256 balanceTo = _tokenA.balanceOf(address(this));
            uint256 amountTo = ceilDiv(amount * balanceTo, balanceFrom);
            _addLiquidity(amount, amountTo);
        }
    }

    function _addLiquidity(uint256 amountA, uint256 amountB) internal {
        address owner = _msgSender();
        approve(address(_tokenA), amountA);
        _tokenA.transferFrom(owner, address(this), amountA);
        approve(address(_tokenB), amountB);
        _tokenB.transferFrom(owner, address(this), amountB);
    }

    function approve(address token, uint256 amount) public {
        require(
            token == address(_tokenA) || token == address(_tokenB),
            "Invalid Token"
        );
        ERC20 erc20Token = ERC20(token);
        erc20Token.approve(address(this), amount);
    }

    function ceilDiv(uint256 x, uint256 y) internal pure returns (uint256) {
        require(y != 0, "invalid devition by 0");
        if (x == 0) {
            return 0;
        }
        uint256 result = 1 + (x - 1) / y;
        return result;
    }
}

contract Token1 is ERC20 {
    constructor(uint256 initialSupply) ERC20("Token1", "TK1") {
        _mint(msg.sender, initialSupply);
    }
}

contract Token2 is ERC20 {
    constructor(uint256 initialSupply) ERC20("Token2", "TK2") {
        _mint(msg.sender, initialSupply);
    }
}

contract DexInteraction {
    Dex private dex;
    ERC20 private token1;
    ERC20 private token2;

    /**
     * @dev Constructor that accepts the deployed Dex address and token addresses.
     */
    constructor(
        address dexAddress,
        address token1Address,
        address token2Address
    ) {
        dex = Dex(dexAddress);
        token1 = ERC20(token1Address);
        token2 = ERC20(token2Address);
    }

    /**
     * @dev Transfer all tokens from user to Dex using Dex's `addLiquidity` function.
     */
    function transferAllToDex() public {
        address owner = msg.sender;
        uint256 token1Balance = token1.balanceOf(owner);
        uint256 token2Balance = token2.balanceOf(owner);

        require(
            token1Balance > 0 || token2Balance > 0,
            "No tokens to transfer"
        );

        // Approve the Dex contract to spend user's tokens
        token1.approve(address(dex), token1Balance);
        token2.approve(address(dex), token2Balance);

        // Add liquidity to the Dex
        if (token1Balance > 0) {
            dex.addLiquidity(address(token1), token1Balance);
        }
    }

    function getToken1BalanceInDex() public view returns (uint256) {
        return token1.balanceOf(address(dex));
    }

    function getToken2BalanceInDex() public view returns (uint256) {
        return token2.balanceOf(address(dex));
    }

    function getDexLiquidity() public view returns (uint256) {
        uint256 token1Balance = getToken1BalanceInDex();
        uint256 token2Balance = getToken2BalanceInDex();
        return token1Balance * token2Balance;
    }
}
