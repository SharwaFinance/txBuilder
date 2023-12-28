import {HardhatRuntimeEnvironment} from "hardhat/types"

async function deployment(hre: HardhatRuntimeEnvironment): Promise<void> {
  const {deployments, getNamedAccounts, network} = hre
  const { deploy } = deployments
  const {deployer} = await getNamedAccounts()

  // await deploy("BuildManager", {
  //   from: deployer,
  //   log: true,
  //   args: [],
  // })
}

deployment.tags = ["build_manager"]

export default deployment
