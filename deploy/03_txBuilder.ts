import {HardhatRuntimeEnvironment} from "hardhat/types"
import { toUtf8Bytes, keccak256 } from "ethers/lib/utils"

async function deployment(hre: HardhatRuntimeEnvironment): Promise<void> {
  const {deployments, getNamedAccounts, network} = hre
  const { deploy, execute, get } = deployments
  const {deployer} = await getNamedAccounts()

  const exchanger = await get("Exchanger")
  const TRADER_ROLE = keccak256(
    toUtf8Bytes("TRADER_ROLE"),
  )

  const txBuilder = await deploy("TxBuilder", {
    from: deployer,
    log: true,
    args: [
      exchanger.address
    ],
  })

  // await execute("RoleManager", {from: deployer}, "grantRole", TRADER_ROLE, txBuilder.address)
}

deployment.tags = ["txBuilder"]
deployment.dependencies = ["exchanger", "role_manager"]

export default deployment
