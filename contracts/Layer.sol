// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "./interfaces/ILayer.sol";
import "./interfaces/ILiquidityDex.sol";

contract Layer is Ownable, ILayer {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint256 public constant MaxSlippage = 1e6;

  mapping(string => address) public getDex;
  string[] public allDexes;

  receive() external payable {}

  function swapTokenOnMultipleDEXes(
    uint256 amountIn,
    uint256 slippage,
    address payable target,
    address[] memory path,
    string[] memory dexes
  ) public override returns (uint256) {
    require(path.length == dexes.length.add(1), "Invalid number of inputs");
    require(path.length >= 3, "Not enough hops");

    _check(path[1], path[0], target, amountIn, slippage);

    IERC20(path[0]).safeTransferFrom(target, address(this), amountIn);

    uint256 amount = amountIn;

    for (uint256 i = 0; i < dexes.length; i++) {
      address buyToken = path[i + 1];
      address sellToken = path[i];

      require(buyToken != sellToken, "Cannot buy and sell same token");

      _swap(buyToken, sellToken, amount, slippage, msg.sender, address(this), dexes[i]);

      amount = IERC20(buyToken).balanceOf(address(this));
    }

    IERC20(path[path.length - 1]).safeTransfer(target, amount);
    target.transfer(address(this).balance);

    return amount;
  }

  function swapTokenOnDEX(
    address buyToken,
    address sellToken,
    uint256 amountIn,
    uint256 slippage,
    address payable target,
    string memory dexName
  ) public override returns (uint256) {
    require(_dexExists(dexName), "Dex does not exist");

    _check(buyToken, sellToken, target, amountIn, slippage);

    IERC20(sellToken).safeTransferFrom(target, address(this), amountIn);

    return _swap(buyToken, sellToken, amountIn, slippage, msg.sender, target, dexName);
  }

  function swapTokensOnDEX(
    address buyToken,
    address[] memory sellTokens,
    uint256[] memory amountsIn,
    uint256 slippage,
    address payable target,
    string memory dexName
  ) external override returns (uint256) {
    require(sellTokens.length > 0, "Arrays cannot be empty");
    require(sellTokens.length == amountsIn.length, "Arrays not matching");
    require(_dexExists(dexName), "Dex does not exist");

    uint256 total = 0;

    for (uint256 i = 0; i < sellTokens.length; i++) {
      total += swapTokenOnDEX(buyToken, sellTokens[i], amountsIn[i], slippage, target, dexName);
    }

    return total;
  }

  function getBestDexForSwap(
    address buyToken,
    address sellToken,
    uint256 amount
  ) public override view returns (string memory best, uint256 count) {
    best = allDexes[0];
    count = ILiquidityDex(getDex[best]).getReturn(buyToken, sellToken, amount);

    for (uint256 i = 0; i < allDexes.length; i++) {
      if (i == 0) continue;
      if (getDex[allDexes[i]] == address(0)) continue;

      string memory dexName = allDexes[i];
      uint256 newCount = ILiquidityDex(getDex[dexName]).getReturn(buyToken, sellToken, amount);

      if (newCount > count) {
        count = newCount;
        best = dexName;
      }
    }
  }

  function getAllDexes() public override view returns (string[] memory) {
    uint256 size = 0;
    uint256 index = 0;

    for (index = 0; index < allDexes.length; index++) {
      if (getDex[allDexes[index]] != address(0)) {
        size++;
      }
    }

    string[] memory arr = new string[](size);
    uint256 arrIndex = 0;

    for (index = 0; index < allDexes.length; index++) {
      if (getDex[allDexes[index]] != address(0)) {
        arr[arrIndex] = allDexes[index];
        arrIndex++;
      }
    }

    return arr;
  }

  function addDex(string memory name, address dexAddress) public onlyOwner {
    require(!_dexExists(name), "Dex already exists");
    getDex[name] = dexAddress;
    allDexes.push(name);
  }

  function setDex(string memory name, address dexAddress) public onlyOwner {
    require(_dexExists(name), "Dex does not exist");
    getDex[name] = dexAddress;
  }

  function deleteDex(string memory name) public onlyOwner {
    require(_dexExists(name), "Dex does not exist");
    getDex[name] = address(0);
  }

  function _check(
    address buyToken,
    address sellToken,
    address target,
    uint256 amountIn,
    uint256 slippage
  ) internal view {
    require(amountIn > 0, "No tokens being swapped");
    require(buyToken != sellToken, "Cannot buy and sell same token");
    require(slippage > 0, "Slippage cannot be 0");
    require(slippage <= MaxSlippage, "Slippage cannot over max");
    require(IERC20(sellToken).allowance(target, address(this)) >= amountIn, "Not approved");
    require(_balance(sellToken, target) >= amountIn, "Not enough tokens");
  }

  function _swap(
    address buyToken,
    address sellToken,
    uint256 amountIn,
    uint256 slippage,
    address initiator,
    address payable target,
    string memory dexName
  ) internal returns (uint256) {
    address dex = getDex[dexName];

    require(dex != address(0), "Dex does not exist");

    uint256 received = ILiquidityDex(dex).getReturn(buyToken, sellToken, amountIn);

    require(received > 0, "No tokens would be received");

    uint256 minAmountOut = _calculateMinimum(received, slippage);
    uint256 originalBalance = _balance(buyToken, target);

    IERC20(sellToken).safeIncreaseAllowance(dex, amountIn);

    ILiquidityDex(dex).doSwap(buyToken, sellToken, amountIn, minAmountOut, address(this), target);

    uint256 total = _balance(buyToken, target).sub(originalBalance);

    require(total >= minAmountOut, "Did not receive enough tokens");

    emit Swap(buyToken, sellToken, initiator, target, amountIn, slippage, total);

    return total;
  }

  function _calculateMinimum(uint256 amount, uint256 slippage) internal pure returns (uint256) {
    uint256 slippageAmount = amount.mul(slippage).div(MaxSlippage);
    return amount.sub(slippageAmount);
  }

  function _balance(address token, address target) internal view returns (uint256) {
    return IERC20(token).balanceOf(target);
  }

  function _dexExists(string memory name) internal view returns (bool) {
    return getDex[name] != address(0);
  }
}
