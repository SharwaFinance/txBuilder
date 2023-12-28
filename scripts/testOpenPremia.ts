import {ethers, deployments} from "hardhat"
import {BigNumber as BN, Signer} from "ethers"
import {solidity} from "ethereum-waffle"
import chai from "chai"
import { ERC20 } from "../typechain-types/@openzeppelin/contracts/token/ERC20";
import { IERC721 } from "../typechain-types/@openzeppelin/contracts/token/ERC721";
import { TxBuilder } from "../typechain-types";
import { Exchanger } from "../typechain-types";
import { parseUnits, formatUnits, solidityPack} from "ethers/lib/utils";
import {TxBuilderOpenPremia} from "../typechain-types";
import {IOptionExchange} from "../typechain-types";
import { IAlphaPortfolioValuesFeed } from "../typechain-types";
import { IBeyondPricer } from "../typechain-types";

const hre = require("hardhat");

chai.use(solidity)
const {expect} = chai

async function main() {
  
  const {deploy, get, execute} = deployments

  const OperationType = {
		OPYN: 0,
		RYSK: 1
	}

  const ProtocolType = {
    lyra_eth: 0,
    lyra_btc: 1,
    hegic: 2,
    rysk_finance: 3,
    premia: 4
  }

  let txBuilder = (await hre.ethers.getContract("TxBuilder")) as TxBuilder
  let TxBuilderOpenPremia = (await hre.ethers.getContract("TxBuilderOpenPremia")) as TxBuilderOpenPremia
  let exchanger = (await hre.ethers.getContract("Exchanger")) as Exchanger  
  let USDCe = (await hre.ethers.getContract("USDCe")) as ERC20
  let WETH = (await hre.ethers.getContract("WETH")) as ERC20
  let GMX = (await hre.ethers.getContract("GMX")) as ERC20

  const [ deployer ] = await hre.ethers.getSigners()
  
  // await USDCe.connect(deployer).approve(exchanger.address, parseUnits("1", 6))
  // await WETH.connect(deployer).approve(exchanger.address, "349734575733844")
  // await WBTC.connect(deployer).approve(exchanger.address, ethers.constants.MaxUint256)
  // await GMX.connect(deployer).approve(exchanger.address, "333425004149463") 

  const moduleArray = [
    await txBuilder.module(ProtocolType.premia)
  ]

  const parametersArray = [
      await TxBuilderOpenPremia.encodeFromPremia(
        "0xbae43c546DFADC69576aE73C68e0694A54F08e1B",
        {
          base: WETH.address,
          quote: USDCe.address,
          oracleAdapter: "0x68BDA63662b16550e86Ad16160625eb293AC3d5F",
          strike: "2300000000000000000000",  
          maturity: "1705046400",
          isCallPool: true
        },
        "10000000000000000",
        true,
        "449734575733844"
      )
  ]

  const swapDataArray = [
    await exchanger.encodeFromExchange({
      path: solidityPack(["address", "uint24", "address"], [WETH.address, 3000, WETH.address]),
      tokenIn: WETH.address,
      tokenOut: WETH.address,
      amountIn: BN.from("449734575733844"),
      amountOutMinimum: BN.from("449734575733844"),
      isETH: false,
      swap: false
    })
  ]

  const tx = await txBuilder.consolidationOfTransactions(moduleArray, parametersArray, swapDataArray, 0)
  console.log(tx)
 }

main()
  .then(() => {
	console.log("success")
	process.exit(0)
})
  .catch(e => {
	console.error(e)
	process.exit(1)
  })
