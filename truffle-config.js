const HDWalletProvider = require('@truffle/hdwallet-provider');
const provider= new HDWalletProvider({
  privateKeys:['PRIVATE_KEY'], //FIND YOUR PRIVATE KEY AT THE ACCOUNT DETAILS OF YOUR METAMASK WALLET
  providerOrUrl:"wss://data-seed-prebsc-1-s1.binance.org:8545"

})
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard BSC port (default: none)
      network_id: "*",       // Any network (default: none)
    },
    testnet: {
      provider: () => provider,
      network_id: "97",
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  contracts_directory: './src/contracts/',
  contracts_build_directory: './src/abis/',
  compilers: {
    solc: {
      version: "^0.6.12", // A version or constraint - Ex. "^0.5.0"
    }
  }
}