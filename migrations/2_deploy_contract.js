const Liquidator = artifacts.require("Liquidator");
const UniswapDex = artifacts.require("UniswapDex");

module.exports = async function (deployer) {
	try {
		await deployer.deploy(Liquidator);
		await deployer.deploy(UniswapDex);
	} catch (e) {}
};
