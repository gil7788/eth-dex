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
    constructor(address token1Address, address token2Address) Ownable(msg.sender) {
        _tokenA = ERC20(token1Address);
        _tokenB = ERC20(token2Address);
    }

    function provideInitLiqudity(uint256 token1Amount, uint256 token2Amount) public onlyOwner {
        _addLiquidity(token1Amount, token2Amount);
    }
    // Swap functionality

    function swap(address from, address to, uint256 amount) public {
        address tokenAAddress = address(_tokenA);
        address tokenBAddress = address(_tokenB);
        address owner = _msgSender();
        require(
            (from == tokenAAddress && to == tokenBAddress) || (from == tokenBAddress && to == tokenAAddress),
            "Invalid token pair"
        );

        ERC20 fromToken = ERC20(from);
        ERC20 toToken = ERC20(to);
        require(fromToken.balanceOf(owner) >= amount, "Insufficient Amount");

        uint256 price = getTokenPrice(from, to, amount);
        fromToken.transferFrom(owner, address(this), amount);
        toToken.transfer(owner, price);
    }

    function getTokenPrice(address from, address to, uint256 amount) internal view returns (uint256) {
        ERC20 erc20From = ERC20(from);
        ERC20 erc20To = ERC20(to);
        uint256 balanceFrom = erc20From.balanceOf(address(this));
        uint256 balanceTo = erc20To.balanceOf(address(this));

        uint256 price = (ceilDiv(balanceFrom, balanceFrom + amount) - 1) * balanceTo;
        return price;
    }

    function addLiquidity(address token, uint256 amount) public {
        require(token == address(_tokenA) || token == address(_tokenB), "Invalid token");

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
        require(token == address(_tokenA) || token == address(_tokenB), "Invalid Token");
        ERC20 erc20Token = ERC20(token);
        erc20Token.approve(address(this), amount);
    }

    function ceilDiv(uint256 x, uint256 y) public pure returns (uint256) {
        require(y != 0, "Invalid division by 0");
        if (x == 0) {
            return 0;
        }
        uint256 result = 1 + (x - 1) / y;
        return result;
    }
}
