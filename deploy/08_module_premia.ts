import {HardhatRuntimeEnvironment} from "hardhat/types"
import { ethers } from "hardhat"

async function deployment(hre: HardhatRuntimeEnvironment): Promise<void> {
  const {deployments, getNamedAccounts} = hre
  const { deploy, execute, get } = deployments
  const {deployer} = await getNamedAccounts()

  const IPoolFactory = await get("IPoolFactory")
  const referrer = "0x683ad8b899cd14d8e077c9a623e8b3fed65a8c09"

  const TxBuilderOpenPremia = await deploy("TxBuilderOpenPremia", {
    from: deployer,
    log: true,
    args: [
      IPoolFactory.address,
      referrer
    ],
  })

  await execute(
    "TxBuilder",
    {log: true, from: deployer},
    "setModule",
    4,
    {
      moduleAddress: TxBuilderOpenPremia.address, 
      name: "premia"
    }
  )


}

deployment.tags = ["module_premia"]
deployment.dependencies = ["preparation", "txBuilder"]

export default deployment
