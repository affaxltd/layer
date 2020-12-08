// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface ICurveAddressProvider {
  function get_registry() external view returns (address);
}
