import { HardhatUserConfig } from "hardhat/config";
import "hardhat-deploy"
import "hardhat-deploy-ethers"
import "@keep-network/hardhat-local-networks-config"
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv"

dotenv.config()

const config: HardhatUserConfig = {
  localNetworksConfitg: "~/.hardhat/config.json",
  solidity: "0.8.9",
  namedAccounts: {
    deployer: {
      default: 0
    }
  },
  etherscan: {
    apiKey: process.env.ARBITRUM_API_KEY,
  },
};

export default config;
