// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface ICurveRegistry {
  function find_pool_for_coins(address _from, address _to) external view returns (address);

  function find_pool_for_coins(
    address _from,
    address _to,
    uint256 i
  ) external view returns (address);

  function get_n_coins(address _pool) external view returns (uint256);

  function get_coins(address _pool) external view returns (address[8] memory);
}
