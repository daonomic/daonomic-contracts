module.exports = {
  networks: {
    kovan: {
      provider: () => {
        return require("@daonomic/trezor-web3-provider")("http://ether-dev:8545", "m/44'/1'/0'/4/0");
      },
      network_id: 3,
      from: "0xfe8f66be0fb118911342312520c7b3d77bbdcf64",
      gas: 2000000,
	  gasPrice: 1000000000
    },
    mainnet: {
      provider: () => {
        return require("@daonomic/trezor-web3-provider")("http://ether:8545", "m/44'/1'/0'/4/1");
      },
      network_id: 1,
      from: "0x23c029883a36e11aa19c7cf6b180b390fbf8b028",
      gas: 100000,
	  gasPrice: 1000000000
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};