const HDWalletProvider = require("@truffle/hdwallet-provider");
const fs = require("fs");

module.exports = {
  networks: {
    fork: {
      host: "127.0.0.1",
      port: 8545,
      gas: 5000000,
      gasPrice: 13000000000,
      network_id: 1,
    },
    kovan: {
      provider: () =>
        new HDWalletProvider(
          fs.readFileSync("private.key").toString().trim(),
          "https://kovan.infura.io/v3/bd0c2cf1b7de43c9a3a70ce2f577d29c"
        ),
      gas: 5000000,
      gasPrice: 30000000000,
      network_id: 42,
    },
    mainnet: {
      provider: () =>
        new HDWalletProvider(
          fs.readFileSync("private.key").toString().trim(),
          "https://mainnet.infura.io/v3/bd0c2cf1b7de43c9a3a70ce2f577d29c"
        ),
      gas: 5000000,
      gasPrice: 13000000000,
      network_id: 1,
    },
  },
  compilers: {
    solc: {
      version: "0.6.12",
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
