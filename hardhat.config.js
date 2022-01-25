require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${process.env.POLYGON_ENDPOINT}`,
      accounts: [process.env.PRIVATE_KEY],
    },
    mainnet: {
      url: `https://polygon-mainnet.infura.io/v3/${process.env.POLYGON_ENDPOINT}`,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  solidity: "0.8.4",
};
