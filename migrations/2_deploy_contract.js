const Layer = artifacts.require("Layer");
const UniswapDex = artifacts.require("UniswapDex");

module.exports = async function (deployer) {
  try {
    await deployer.deploy(Layer);
    await deployer.deploy(UniswapDex);
  } catch (e) {}
};
