// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface ILayer {
  function swapTokenOnMultipleDEXes(
    uint256 amountIn,
    uint256 slippage,
    address payable target,
    address[] memory path,
    string[] memory dexes
  ) external returns (uint256);

  function swapTokenOnDEX(
    address buyToken,
    address sellToken,
    uint256 amountIn,
    uint256 slippage,
    address payable target,
    string memory dexName
  ) external returns (uint256);

  function swapTokensOnDEX(
    address buyToken,
    address[] memory sellTokens,
    uint256[] memory amountsIn,
    uint256 slippage,
    address payable target,
    string memory dexName
  ) external returns (uint256);

  function getBestDexForSwap(
    address buyToken,
    address sellToken,
    uint256 amount
  ) external view returns (string memory);

  function getAllDexes() external view returns (string[] memory);
}
