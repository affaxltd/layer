const { parseTokens } = require("./_tools");

const Weth = artifacts.require("IWETH");
const wethAddress = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2";

module.exports = {
  wethAddress: wethAddress,
  async getWeth(account) {
    const instance = await Weth.at(wethAddress);

    await instance.deposit({
      value: parseTokens(100, 18).toString(),
      from: account,
    });
  },
};
