function createNetwork(name) {
  var os = require('os');
  var json = require(os.homedir() + "/.ethereum/" + name + ".json");
  var gasPrice = json.gasPrice != null ? json.gasPrice : 2000000000;

  return {
    provider: () => createProvider(json.address, json.key, json.url, gasPrice),
    from: json.address,
    gas: 1000000,
    gasPrice: gasPrice,
    network_id: json.network_id
  };
}

function createProvider(address, key, url, gasPrice) {
  console.log("creating provider for address: " + address + " gasPrice: " + gasPrice);
  var HDWalletProvider = require("truffle-hdwallet-provider");
  return new HDWalletProvider(key, url);
}

module.exports = {
  networks: {
    ropsten: createNetwork("ropsten"),
    mainnet: createNetwork("mainnet"),
    ops: createNetwork("ops"),
  },

  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
       version: "0.5.6",    // Fetch exact version from solc-bin (default: truffle's version)
       settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200
        },
        evmVersion: "petersburg"
       }
    }
  }
}
