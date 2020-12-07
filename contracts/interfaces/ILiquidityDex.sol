// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface ILiquidityDex {
  function doSwap(
    address buyToken,
    address sellToken,
    uint256 amountIn,
    uint256 minAmountOut,
    address spender,
    address payable target
  ) external;

  function getReturn(
    address buyToken,
    address sellToken,
    uint256 amountIn
  ) external view returns (uint256);
}
