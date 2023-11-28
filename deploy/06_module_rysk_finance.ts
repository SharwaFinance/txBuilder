import {HardhatRuntimeEnvironment} from "hardhat/types"
import { ethers } from "hardhat"

async function deployment(hre: HardhatRuntimeEnvironment): Promise<void> {
  const {deployments, getNamedAccounts} = hre
  const { deploy, execute, get } = deployments
  const {deployer} = await getNamedAccounts()

  const IBeyondPricer = await get("IBeyondPricer")
  const IOptionExchange = await get("IOptionExchange")
  const IAlphaPortfolioValuesFeed = await get("IAlphaPortfolioValuesFeed")
  const USDC = await get("USDC") 
  const WETH = await get("WETH")
  const WBTC = await get("WBTC")

  console.log("module rysk finance start...")

  const txBuilderOpenRyskFinance = await deploy("TxBuilderOpenRyskFinance", {
    from: deployer,
    log: true,
    args: [
      USDC.address,
      WETH.address,
      WBTC.address,
      IBeyondPricer.address,
      IOptionExchange.address,
      IAlphaPortfolioValuesFeed.address
    ],
  })

  await execute(
    "TxBuilder",
    {log: true, from: deployer},
    "setModule",
    3,
    {
      moduleAddress: txBuilderOpenRyskFinance.address, 
      name: "rysk_finance"
    }
  )

  await execute(
    "TxBuilderOpenRyskFinance",
    {log: true, from: deployer},
    "allApprove",
  )

}

deployment.tags = ["module_rysk_finance"]
deployment.dependencies = ["preparation", "txBuilder"]

export default deployment
