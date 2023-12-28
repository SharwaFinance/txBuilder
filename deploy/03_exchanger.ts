import {HardhatRuntimeEnvironment} from "hardhat/types"

async function deployment(hre: HardhatRuntimeEnvironment): Promise<void> {
  const {deployments, getNamedAccounts, network} = hre
  const { deploy, get } = deployments
  const {deployer} = await getNamedAccounts()

  const swapRouter = await get("swapRouter")
  const role_manager = await get("RoleManager")
  const WETH = await get("WETH")

  await deploy("Exchanger", {
    from: deployer,
    log: true,
    args: [
      swapRouter.address,
      role_manager.address,
      WETH.address
    ],
  })

}

deployment.tags = ["exchanger"]
deployment.dependencies = ["preparation", "role_manager"]

export default deployment
