// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../interfaces/ILiquidityDex.sol";
import "../interfaces/IBalancerRouter.sol";
import "../interfaces/IBalancerRegistry.sol";
import "../interfaces/ITokenInterface.sol";

contract BalancerDex is ILiquidityDex {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

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
    IERC20(sellToken).safeTransferFrom(spender, address(this), amountIn);
    IERC20(sellToken).safeIncreaseAllowance(balancerRouter, amountIn);

    uint256 totalAmountOut = IBalancerRouter(balancerRouter).smartSwapExactIn(
      ITokenInterface(sellToken),
      ITokenInterface(buyToken),
      amountIn,
      minAmountOut,
      maxPools
    );

    IERC20(buyToken).safeTransfer(target, totalAmountOut);
    target.transfer(address(this).balance);
  }

  function getReturn(
    address buyToken,
    address sellToken,
    uint256 amountIn
  ) public override view returns (uint256) {
    address[] memory result = IBalancerRegistry(balancerRegistry).getPoolsWithLimit(sellToken, buyToken, 0, 1);

    if (result.length == 0) {
      return 0;
    }

    (, uint256 totalOutput) = IBalancerRouter(balancerRouter).viewSplitExactIn(sellToken, buyToken, amountIn, maxPools);

    return totalOutput;
  }
}
