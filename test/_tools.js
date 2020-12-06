const { burnAddress, maxPermit } = require("./_constants");

module.exports = {
  parseTokens(amount, decimals) {
    return BigInt(10) ** BigInt(decimals) * BigInt(amount);
  },
  async burn(token, account) {
    await token.transfer(burnAddress, await token.balanceOf(account), {
      from: account,
    });
  },
  useApproval(token, address) {
    return async function approve(account) {
      await token.approve(address, maxPermit, {
        from: account,
      });
    };
  },
  useSwapper(liquidator, dexName, testAmount) {
    return {
      async single(buyToken, sellToken, account, amount = undefined) {
        return liquidator.swapTokenOnDEX(buyToken, sellToken, amount || testAmount, 20000, account, dexName, {
          from: account,
        });
      },
      async multiple(buyToken, sellTokens, amounts, account) {
        return liquidator.swapTokensOnDEX(
          buyToken,

          sellTokens,
          amounts,
          20000,
          account,
          dexName,
          {
            from: account,
          }
        );
      },
    };
  },
  accountPool(accounts) {
    let index = 0;
    return function (title, func) {
      it(title, () => {
        index++;
        return func(accounts[index - 1]);
      });
    };
  },
};
