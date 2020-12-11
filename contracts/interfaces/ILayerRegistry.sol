// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface ILayerRegistry {
  function getLayer() external view returns (address);

  function getLayerReverts() external view returns (address);
}
