const Layer = artifacts.require("Layer");
const UniswapDex = artifacts.require("UniswapDex");
const SushiswapDex = artifacts.require("SushiswapDex");
const BalancerDex = artifacts.require("BalancerDex");
const CurveDex = artifacts.require("CurveDex");

module.exports = async function (deployer) {
  try {
    await deployer.deploy(Layer);
    await deployer.deploy(UniswapDex);
    await deployer.deploy(SushiswapDex);
    await deployer.deploy(BalancerDex);
    await deployer.deploy(CurveDex);
  } catch (e) {}
};
