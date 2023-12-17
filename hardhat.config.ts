import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import { getAccounts } from "./utils/account.util";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.18",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    "bsc-testnet": {
      url: process.env.URL_BSC_TESTNET || "",
      accounts: getAccounts(),
    },
    "jfin-testnet": {
      url: process.env.URL_JFIN_TESTNET || "",
      accounts: getAccounts(),
    },
    "bkc-testnet": {
      url: process.env.URL_BKC_TESTNET || "",
      accounts: getAccounts(),
    }
  },
  gasReporter: {
    enabled: process.env.GAS_REPORT === "true",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || "",
  },
  paths: {
    sources: "./contracts",
    tests: "/test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};

export default config;
