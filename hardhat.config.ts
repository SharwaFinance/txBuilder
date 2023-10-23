import { HardhatUserConfig } from "hardhat/config";
import "hardhat-deploy"
import "hardhat-deploy-ethers"
import "@keep-network/hardhat-local-networks-config"
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  localNetworksConfitg: "~/.hardhat/config.json",
  solidity: "0.8.9",
  namedAccounts: {
    deployer: {
      default: 0
    }
  },
};

export default config;
