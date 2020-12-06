// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../libraries/UniswapV2Library.sol";
import "../libraries/SafeMath.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/ILiquidityDex.sol";
import "../interfaces/IUniswapV2Factory.sol";

contract UniswapDex is ILiquidityDex {
  using SafeMath for uint256;

  receive() external payable {}

  address private constant uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address private constant uniswapFactory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

  function doSwap(
    address buyToken,
    address sellToken,
    uint256 amountIn,
    uint256 minAmountOut,
    address spender,
    address payable target
  ) public override {
    require(IERC20(sellToken).transferFrom(spender, address(this), amountIn), "Transfer failed");

    address[] memory path = _getRoute(buyToken, sellToken);

    require(IERC20(sellToken).approve(uniswapRouter, amountIn), "Approval failed");

    IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(
      amountIn,
      minAmountOut,
      path,
      target,
      block.timestamp
    );

    target.transfer(address(this).balance);
  }

  function getReturn(
    address buyToken,
    address sellToken,
    uint256 amountIn
  ) public override view returns (uint256) {
    require(buyToken != sellToken, "Cannot buy and sell same token");

    address[] memory path = _getRoute(buyToken, sellToken);
    address weth = IUniswapV2Router02(uniswapRouter).WETH();
    IUniswapV2Factory factory = IUniswapV2Factory(uniswapFactory);

    if (path.length == 2) {
      if (factory.getPair(buyToken, sellToken) == address(0)) {
        return 0;
      }
    } else {
      if (
        factory.getPair(buyToken, weth) == address(0) ||
        factory.getPair(weth, sellToken) == address(0)
      ) {
        return 0;
      }
    }

    return IUniswapV2Router02(uniswapRouter).getAmountsOut(amountIn, path)[path.length - 1];
  }

  function _getRoute(address buyToken, address sellToken) internal pure returns (address[] memory) {
    require(buyToken != sellToken, "Cannot buy and sell same token");

    address weth = IUniswapV2Router02(uniswapRouter).WETH();

    if (sellToken == weth) {
      address[] memory path = new address[](2);
      path[0] = weth;
      path[1] = buyToken;
      return path;
    } else if (buyToken == weth) {
      address[] memory path = new address[](2);
      path[0] = sellToken;
      path[1] = weth;
      return path;
    } else {
      address[] memory path = new address[](3);
      path[0] = sellToken;
      path[1] = weth;
      path[2] = buyToken;
      return path;
    }
  }
}
