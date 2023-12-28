import {HardhatRuntimeEnvironment} from "hardhat/types"
import { ethers } from "hardhat"

async function deployment(hre: HardhatRuntimeEnvironment): Promise<void> {
  const {deployments, getNamedAccounts} = hre
  const { deploy, execute, get } = deployments
  const {deployer} = await getNamedAccounts()

  const USDCe = await get("USDCe") 
  const WETH = await get("WETH")
  const WETH_USDC_DopexV2OptionMarket = "0x764fa09d0b3de61eed242099bd9352c1c61d3d27"

  // const TxBuilderOpenDopex = await deploy("TxBuilderOpenDopex", {
  //   from: deployer,
  //   log: true
  // })

  // await execute(
  //   "TxBuilder",
  //   {log: true, from: deployer},
  //   "setModule",
  //   5,
  //   {
  //     moduleAddress: TxBuilderOpenDopex.address, 
  //     name: "dopex"
  //   }
  // )

  // await execute(
  //   "TxBuilderOpenDopex",
  //   {log: true, from: deployer},
  //   "allApprove",
  //   USDCe.address,
  //   WETH_USDC_DopexV2OptionMarket, 
  //   ethers.constants.MaxUint256
  // )

  // await execute(
  //   "TxBuilderOpenDopex",
  //   {log: true, from: deployer},
  //   "allApprove",
  //   WETH.address,
  //   WETH_USDC_DopexV2OptionMarket, 
  //   ethers.constants.MaxUint256
  // )
}

deployment.tags = ["module_dopex"]
deployment.dependencies = ["preparation", "txBuilder"]

export default deployment
