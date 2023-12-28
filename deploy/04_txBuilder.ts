import {HardhatRuntimeEnvironment} from "hardhat/types"
import { toUtf8Bytes, keccak256 } from "ethers/lib/utils"

async function deployment(hre: HardhatRuntimeEnvironment): Promise<void> {
  const {deployments, getNamedAccounts, network} = hre
  const { deploy, execute, get } = deployments
  const {deployer} = await getNamedAccounts()

  const exchanger = await get("Exchanger")
  const buildManager = await get("BuildManager")

  const txBuilder = await deploy("TxBuilder", {
    from: deployer,
    log: true,
    args: [
      exchanger.address,
      buildManager.address
    ],
  })

  await execute(
    "BuildManager",
    {log: true, from: deployer},
    "setTxBuilder",
    txBuilder.address
  )

}

deployment.tags = ["txBuilder"]
deployment.dependencies = ["exchanger", "build_manager"]

export default deployment
