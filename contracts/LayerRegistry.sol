// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/ILayerRegistry.sol";

contract LayerRegistry is Ownable, ILayerRegistry {
  address internal _layer;

  function setLayer(address newLayer) public onlyOwner {
    require(newLayer != address(0), "Layer is nill");
    _layer = newLayer;
  }

  function getLayer() public override view returns (address) {
    return _layer;
  }

  function getLayerReverts() public override view returns (address) {
    require(_layer != address(0), "Layer is nill");
    return _layer;
  }
}
