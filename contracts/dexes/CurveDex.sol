// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../interfaces/ILiquidityDex.sol";
import "../interfaces/ICurveAddressProvider.sol";
import "../interfaces/ICurveRegistry.sol";
import "../interfaces/ICurveSwap.sol";

contract CurveDex is ILiquidityDex {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint256 private constant maxPools = 3;

  receive() external payable {}

  address internal constant curveProvider = 0x0000000022D53366457F9d5E68Ec105046FC4383;

  function doSwap(
    address buyToken,
    address sellToken,
    uint256 amountIn,
    uint256 minAmountOut,
    address spender,
    address payable target
  ) public override {
    (address pool, int128 i, int128 j, uint256 dy) = _init(buyToken, sellToken, amountIn);

    require(dy > 0, "Would not receive any tokens");

    IERC20(sellToken).safeTransferFrom(spender, address(this), amountIn);
    IERC20(sellToken).safeIncreaseAllowance(pool, amountIn);

    uint256 initialAmount = IERC20(buyToken).balanceOf(address(this));

    ICurveSwap(pool).exchange(i, j, amountIn, minAmountOut);

    uint256 totalAmountOut = IERC20(buyToken).balanceOf(address(this)).sub(initialAmount);

    require(totalAmountOut >= minAmountOut, "Did not receive tokens");

    IERC20(buyToken).safeTransfer(target, totalAmountOut);
    target.transfer(address(this).balance);
  }

  function getReturn(
    address buyToken,
    address sellToken,
    uint256 amountIn
  ) public override view returns (uint256) {
    (, , , uint256 dy) = _init(buyToken, sellToken, amountIn);
    return dy;
  }

  function _init(
    address buyToken,
    address sellToken,
    uint256 amountIn
  )
    internal
    view
    returns (
      address pool,
      int128 i,
      int128 j,
      uint256 dy
    )
  {
    address registry = _registry();
    pool = _pool(registry, buyToken, sellToken);

    if (pool == address(0)) {
      dy = 0;
    } else {
      uint256 coinCount = ICurveRegistry(registry).get_n_coins(pool);
      address[8] memory coins = ICurveRegistry(registry).get_coins(pool);

      i = _index(coins, coinCount, sellToken);
      j = _index(coins, coinCount, buyToken);
      dy = ICurveSwap(pool).get_dy(i, j, amountIn);
    }
  }

  function _index(
    address[8] memory coins,
    uint256 count,
    address coin
  ) internal pure returns (int128) {
    int128 result = -1;

    for (uint256 i = 0; i < count; i++) {
      if (coins[i] == coin) {
        result = int128(i);
        break;
      }
    }

    require(result != -1, "Token not found in list");
    return result;
  }

  function _pool(
    address registry,
    address buyToken,
    address sellToken
  ) internal view returns (address) {
    return ICurveRegistry(registry).find_pool_for_coins(sellToken, buyToken);
  }

  function _registry() internal view returns (address) {
    address registry = ICurveAddressProvider(curveProvider).get_registry();
    require(registry != address(0), "Registry address invalid");
    return registry;
  }
}
