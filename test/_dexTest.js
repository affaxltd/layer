const { parseTokens, burn, useApproval, useSwapper, accountPool } = require("./_tools");
const { getWeth, wethAddress } = require("./_weth");
const { burnAddress } = require("./_constants");

const truffleAssert = require("truffle-assertions");

const Layer = artifacts.require("Layer");
const IERC20 = artifacts.require("IERC20");

const nonExistant = burnAddress;
const usdcAddress = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48";
const daiAddress = "0x6b175474e89094c44da98b954eedeac495271d0f";

module.exports = function testDex(dexName, contractName) {
  const DexContract = artifacts.require(contractName);

  contract(`${dexName} V2 Dex Contract`, async (accounts) => {
    const testAmount = parseTokens(1, 18).toString();
    const pool = accountPool(accounts);

    let setup = false;

    let layerContract;
    let dexContract;
    let daiToken;

    let usdcToken;
    let wethToken;

    let daiApproval;
    let usdcApproval;
    let wethApproval;

    let swapper;

    async function reset(account) {
      await burn(daiToken, account);
      await burn(usdcToken, account);
      await burn(wethToken, account);
    }

    async function resetBalances() {
      for (let index = 0; index < accounts.length; index++) {
        await reset(accounts[index]);
        await getWeth(accounts[index]);
      }
    }

    async function setupCoreProtocol() {
      layerContract = await Layer.new();
      dexContract = await DexContract.new();

      daiToken = await IERC20.at(daiAddress);
      usdcToken = await IERC20.at(usdcAddress);
      wethToken = await IERC20.at(wethAddress);

      daiApproval = useApproval(daiToken, layerContract.address);
      usdcApproval = useApproval(usdcToken, layerContract.address);
      wethApproval = useApproval(wethToken, layerContract.address);

      swapper = useSwapper(layerContract, dexName, testAmount);

      await layerContract.addDex(dexName, dexContract.address);
    }

    beforeEach(async function () {
      if (setup) return;

      await setupCoreProtocol();
      await resetBalances();

      setup = true;
    });

    pool("Dex should return over zero", async () => {
      const swapDex = await DexContract.at(await layerContract.getDex(dexName));

      const return1 = await swapDex.getReturn(daiAddress, wethAddress, testAmount);

      const return2 = await swapDex.getReturn(usdcAddress, wethAddress, testAmount);

      assert.isAbove(parseInt(return1), 0, "Dex returned 0 for asset 1");
      assert.isAbove(parseInt(return2), 0, "Dex returned 0 for asset 2");
    });

    pool("Dex should be listed in the dexes", async () => {
      const dexes = await layerContract.getAllDexes();
      assert.include(dexes, dexName, "Dex doesn't exist in layer");
    });

    pool("Dex should swap single token", async (account) => {
      await wethApproval(account);

      await swapper.single(daiAddress, wethAddress, account);

      assert.isAbove(parseInt(await daiToken.balanceOf(account)), 0, "No tokens received");
    });

    pool("Dex should swap multiple tokens", async (account) => {
      await wethApproval(account);
      await daiApproval(account);

      await swapper.single(daiAddress, wethAddress, account);

      await swapper.multiple(
        usdcAddress,
        [wethAddress, daiAddress],
        [testAmount, await daiToken.balanceOf(account)],
        account
      );

      assert.isAbove(parseInt(await usdcToken.balanceOf(account)), 0, "No tokens received");
    });

    pool("Dex should swap single token and between tokens", async (account) => {
      await wethApproval(account);
      await daiApproval(account);

      await swapper.single(daiAddress, wethAddress, account);

      await swapper.single(usdcAddress, daiAddress, account);

      assert.isAbove(parseInt(await usdcToken.balanceOf(account)), 0, "No tokens swapped");
    });

    pool("Dex shouldn't allow swaps with more tokens than in account", async (account) => {
      await wethApproval(account);

      await truffleAssert.reverts(swapper.single(daiAddress, wethAddress, account, parseTokens(200000, 18).toString()));

      assert.isOk(
        BigInt(0) === BigInt(await daiToken.balanceOf(account)),
        "Tokens received even without balance of weth"
      );
    });

    pool("Dex shouldn't error out on non existing tokens", async (account) => {
      await wethApproval(account);

      const swapDex = await DexContract.at(await layerContract.getDex(dexName));
      const result = await swapDex.getReturn(nonExistant, wethAddress, testAmount);

      assert.equal(parseInt(result), 0, "Got a return on non existant token");
    });
  });
};
