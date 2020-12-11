const HDWalletProvider = require("@truffle/hdwallet-provider");
const fs = require("fs");

const memo =
  (() => {
    try {
      return fs.readFileSync("private.key").toString().trim();
    } catch (e) {
      return undefined;
    }
  })() || "";

module.exports = {
  networks: {
    fork: {
      host: "127.0.0.1",
      port: 8545,
      gas: 5000000,
      gasPrice: 11000000000,
      network_id: 1,
    },
    kovan: {
      provider: () => new HDWalletProvider(memo, "https://kovan.infura.io/v3/bd0c2cf1b7de43c9a3a70ce2f577d29c"),
      gas: 5000000,
      gasPrice: 30000000000,
      network_id: 42,
    },
    mainnet: {
      provider: () => new HDWalletProvider(memo, "https://mainnet.infura.io/v3/bd0c2cf1b7de43c9a3a70ce2f577d29c"),
      gas: 5000000,
      gasPrice: 11000000000,
      network_id: 1,
    },
  },
  compilers: {
    solc: {
      version: "0.6.12",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
};
