import {HardhatRuntimeEnvironment} from "hardhat/types"
import { ethers } from "hardhat"

async function deployment(hre: HardhatRuntimeEnvironment): Promise<void> {
  const {deployments, getNamedAccounts} = hre
  const { deploy, execute, get } = deployments
  const {deployer} = await getNamedAccounts()

  const referrer = "0x683ad8b899cd14d8e077c9a623e8b3fed65a8c09"
  const proxySeller = await get("proxySeller")
  const hegicErc721 = await get("hegicErc721") 
  const USDC = await get("USDCe") 

  const txBuilderOpenHegic = await deploy("TxBuilderOpenHegic", {
    from: deployer,
    log: true,
    args: [
      proxySeller.address,
      hegicErc721.address,
      USDC.address,
      referrer
    ],
  })

  await execute(
    "TxBuilder",
    {log: true, from: deployer},
    "setModule",
    2,
    {
      moduleAddress: txBuilderOpenHegic.address, 
      name: "hegic"
    }
  )

  await execute(
    "TxBuilderOpenHegic",
    {log: true, from: deployer},
    "allApprove",
  )

  await execute(
    "TxBuilder",
    {log: true, from: deployer},
    "allApprove",
    USDC.address,
    txBuilderOpenHegic.address,
    ethers.constants.MaxUint256
  )

}

deployment.tags = ["module_hegic"]
deployment.dependencies = ["preparation", "txBuilder"]

export default deployment
