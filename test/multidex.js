const { parseTokens, burn, accountPool } = require("./_tools");
const { getWeth, wethAddress } = require("./_weth");

const Layer = artifacts.require("Layer");
const IERC20 = artifacts.require("IERC20");

const dexes = [
  ["uniV2", "UniswapDex"],
  ["curve", "CurveDex"],
  ["univ2", "UniswapDex"],
];

const path = [
  wethAddress,
  "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599",
  "0xeb4c2781e4eba804ce9a9803c67d0893436bb27d",
  "0x408e41876cccdc0f92210600ef50372656052a38",
];

contract(`Test multi-dex`, async (accounts) => {
  const testAmount = parseTokens(1, 18).toString();
  const pool = accountPool(accounts);

  let layerContract;

  async function reset(account) {
    for (const address of path) {
      await burn(await IERC20.at(address), account);
    }
  }

  async function resetBalances() {
    await reset(accounts[0]);
    await getWeth(accounts[0]);
  }

  async function setupCoreProtocol() {
    layerContract = await Layer.new();

    const unique = [];

    for (const dex of dexes) {
      if (unique.filter((u) => u[0] === dex[0]).length > 0) continue;
      unique.push(dex);
    }

    for (const dex of unique) {
      const DexContract = artifacts.require(dex[1]);
      const dexContract = await DexContract.new();
      await layerContract.addDex(dex[0], dexContract.address);
    }
  }

  beforeEach(async function () {
    await setupCoreProtocol();
    await resetBalances();
  });

  pool("Should swap multiple tokens", async (account) => {
    await (await IERC20.at(path[0])).approve(layerContract.address, parseTokens(1000, 18).toString());

    await layerContract.swapTokenOnMultipleDEXes(
      testAmount,
      20000,
      account,
      path,
      dexes.map((d) => d[0])
    );

    const now = await (await IERC20.at(path[path.length - 1])).balanceOf(account, {
      from: account,
    });

    assert.isAbove(parseInt(now), 0, "Didn't receive equal");
  });
});
