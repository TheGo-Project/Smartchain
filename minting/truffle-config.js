module.exports = {
    networks: {
      development: {
        host: "", //NA for now, Conifgure later,
        port: 7545, // Default port for Ganache
        network_id: "*", // Netwoerk ID will be configured wwhile deploying
      },
      ropsten: {
        provider: () => new HDWalletProvider(process.env.MNEMONIC, `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`), // Infura API key is required
        network_id: 3,
        gas: 5500000,
        confirmations: 2,
        timeoutBlocks: 200,
        skipDryRun: true
      },
    },
  
    compilers: {
      solc: {
        version: "^0.8.0"
      }
    }
  };
  