import {HardhatRuntimeEnvironment} from "hardhat/types"
import { ethers } from "hardhat"

async function deployment(hre: HardhatRuntimeEnvironment): Promise<void> {
  const {deployments, getNamedAccounts, network} = hre
  const { deploy, execute, get } = deployments
  const {deployer} = await getNamedAccounts()

  const referrer = "0x683ad8b899cd14d8e077c9a623e8b3fed65a8c09"
  const lyra_ethErc721 = await get("lyra_ethErc721")
  const optionMarketETH = await get("optionMarketETH")
  const lyra_btcErc721 = await get("lyra_btcErc721")
  const optionMarketBTC = await get("optionMarketBTC")

  const txBuilderOpenLyraETH = await deploy("txBuilderOpenLyraETH", {
    contract: "TxBuilderOpenLyra",
    from: deployer,
    log: true,
    args: [
      optionMarketETH.address,
      lyra_ethErc721.address,
      referrer
    ],
  })

  await execute(
    "txBuilderOpenLyraETH",
    {log: true, from: deployer},
    "allApprove"
  )

  const txBuilderOpenLyraBTC = await deploy("txBuilderOpenLyraBTC", {
    contract: "TxBuilderOpenLyra",
    from: deployer,
    log: true,
    args: [
      optionMarketBTC.address,
      lyra_btcErc721.address,
      referrer
    ],
  })

  await execute(
    "txBuilderOpenLyraBTC",
    {log: true, from: deployer},
    "allApprove"
  )

  // TxBuilder preparation

  await execute(
    "TxBuilder",
    {log: true, from: deployer},
    "setModule",
    0,
    {
      moduleAddress: txBuilderOpenLyraETH.address, 
      name: "lyra_eth"
    }
  )

  await execute(
    "TxBuilder",
    {log: true, from: deployer},
    "setModule",
    1,
    {
      moduleAddress: txBuilderOpenLyraBTC.address, 
      name: "lyra_btc"
    }
  )

}

deployment.tags = ["module_lyra"]
deployment.dependencies = ["preparation", "txBuilder"]

export default deployment
