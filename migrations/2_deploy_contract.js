const Layer = artifacts.require("Layer");
const LayerRegistry = artifacts.require("LayerRegistry");

const dexes = [
  ["univ2", "UniswapDex"],
  ["sushi", "SushiswapDex"],
  ["balancer", "BalancerDex"],
  ["curve", "CurveDex"],
  ["defiswap", "DefiswapDex"],
];

module.exports = async function (deployer) {
  try {
    await deployer.deploy(Layer);
    await deployer.deploy(LayerRegistry);
    const layer = await Layer.deployed();
    const layerRegistry = await LayerRegistry.deployed();

    for (const dex of dexes) {
      const Dex = artifacts.require(dex[1]);
      await deployer.deploy(Dex);
      const dexContract = await Dex.deployed();
      await layer.addDex(dex[0], dexContract.address);
    }

    await layerRegistry.setLayer(layer.address);
  } catch (e) {
    console.error(e);
  }
};
