const HDWalletProvider = require("@truffle/hdwallet-provider");
const fs = require("fs");
const mnemonic = fs.readFileSync("private.key").toString().trim();
const infura = fs.readFileSync("infura.key").toString().trim();

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
					mnemonic,
					"https://kovan.infura.io/v3/" + infura
				),
			gas: 5000000,
			gasPrice: 30000000000,
			network_id: 42,
		},
		mainnet: {
			provider: () =>
				new HDWalletProvider(
					mnemonic,
					"https://mainnet.infura.io/v3/" + infura
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
