// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../libraries/SafeMath.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/ILiquidityDex.sol";
import "../interfaces/IBalancerRouter.sol";
import "../interfaces/IBalancerRegistry.sol";
import "../interfaces/ITokenInterface.sol";

contract BalancerDex is ILiquidityDex {
  using SafeMath for uint256;

  uint256 private constant maxPools = 3;

  receive() external payable {}

  address internal constant balancerRouter = 0x3E66B66Fd1d0b02fDa6C811Da9E0547970DB2f21;
  address internal constant balancerRegistry = 0x7226DaaF09B3972320Db05f5aB81FF38417Dd687;

  function doSwap(
    address buyToken,
    address sellToken,
    uint256 amountIn,
    uint256 minAmountOut,
    address spender,
    address payable target
  ) public override {
    require(IERC20(sellToken).transferFrom(spender, address(this), amountIn), "Transfer failed");

    require(IERC20(sellToken).approve(balancerRouter, amountIn), "Approval failed");

    uint256 totalAmountOut = IBalancerRouter(balancerRouter).smartSwapExactIn(
      ITokenInterface(sellToken),
      ITokenInterface(buyToken),
      amountIn,
      minAmountOut,
      maxPools
    );

    IERC20(buyToken).transfer(target, totalAmountOut);
    target.transfer(address(this).balance);
  }

  function getReturn(
    address buyToken,
    address sellToken,
    uint256 amountIn
  ) public override view returns (uint256) {
    address[] memory result = IBalancerRegistry(balancerRegistry).getPoolsWithLimit(
      sellToken,
      buyToken,
      0,
      1
    );

    if (result.length == 0) {
      return 0;
    }

    (, uint256 totalOutput) = IBalancerRouter(balancerRouter).viewSplitExactIn(
      sellToken,
      buyToken,
      amountIn,
      maxPools
    );

    return totalOutput;
  }
}
