// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "./ITokenInterface.sol";

struct Swap {
    address pool;
    address tokenIn;
    address tokenOut;
    uint256 swapAmount;
    uint256 limitReturnAmount;
    uint256 maxPrice;
}

interface IBalancerRouter {
    function smartSwapExactIn(
        ITokenInterface tokenIn,
        ITokenInterface tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut,
        uint256 nPools
    ) external payable returns (uint256 totalAmountOut);

    function viewSplitExactIn(
        address tokenIn,
        address tokenOut,
        uint256 swapAmount,
        uint256 nPools
    ) external view returns (bytes32 swaps, uint256 totalOutput);
}
