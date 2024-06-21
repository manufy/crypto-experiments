module.exports = {
  networks: {
    development: {
      network_id: "5777",
      port: 8545,
      host: "127.0.0.1"
    }
  },
  mocha: {},
  compilers: {
    solc: {
      version: "0.8.19"
    }
  }
};
