function createProvider(host) {
    var ProviderEngine = require("web3-provider-engine");
    var WalletSubprovider = require('web3-provider-engine/subproviders/wallet.js');
    var Web3Subprovider = require("web3-provider-engine/subproviders/web3.js");
    var Web3 = require("web3");
    var FilterSubprovider = require('web3-provider-engine/subproviders/filters.js')
    var Wallet = require("ethereumjs-wallet");

    function createEngine(url, wallet) {
        var engine = new ProviderEngine();
        engine.addProvider(new WalletSubprovider(wallet, {}));
        engine.addProvider(new FilterSubprovider());
        engine.addProvider(new Web3Subprovider(new Web3.providers.HttpProvider(url)));
        engine.on('error', function(err) {
            console.error(err.stack)
        });
        return engine;
    }

    var wallet = Wallet.fromPrivateKey(new Buffer("00120de4b1518cf1f16dc1b02f6b4a8ac29e870174cb1d8575f578480930250a", "hex"));
    var engine = createEngine("http://" + host + ":8545", wallet);
    engine.start();
    return engine;
}

module.exports = {
  networks: {
    dev: {
      provider: () => createProvider("localhost"),
      from: "0xc66d094ed928f7840a6b0d373c1cd825c97e3c7c",
      gas: 3000000,
      gasPrice: 1000000000,
      network_id: "*"
    },
    ops: {
      provider: () => createProvider("ops"),
      from: "0xc66d094ed928f7840a6b0d373c1cd825c97e3c7c",
      gas: 3000000,
      gasPrice: 1000000000,
      network_id: "*"
    },
    kovan: {
      provider: () => createProvider("ether-dev"),
      from: "0xc66d094ed928f7840a6b0d373c1cd825c97e3c7c",
      gas: 4000000,
      gasPrice: 1000000000,
      network_id: "*"
    },
    kovan_trezor: {
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
      gas: 1000000,
	    gasPrice: 3000000000
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};