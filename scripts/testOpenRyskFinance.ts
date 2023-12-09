import {ethers, deployments} from "hardhat"
import {BigNumber as BN, Signer} from "ethers"
import {solidity} from "ethereum-waffle"
import chai from "chai"
import { ERC20 } from "../typechain-types/@openzeppelin/contracts/token/ERC20";
import { IERC721 } from "../typechain-types/@openzeppelin/contracts/token/ERC721";
import { TxBuilder } from "../typechain-types";
import { Exchanger } from "../typechain-types";
import { parseUnits, formatUnits, solidityPack} from "ethers/lib/utils";
import { RoleManager } from "../typechain-types";
import {TxBuilderOpenRyskFinance} from "../typechain-types";
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
    rysk_finance: 3
  }

  let txBuilder = (await hre.ethers.getContract("TxBuilder")) as TxBuilder
  let TxBuilderOpenRyskFinance = (await hre.ethers.getContract("TxBuilderOpenRyskFinance")) as TxBuilderOpenRyskFinance
  let optioinExchanger = (await hre.ethers.getContract("IOptionExchange")) as IOptionExchange
  let alphaPortfolioValuesFeed = (await hre.ethers.getContract("IAlphaPortfolioValuesFeed")) as IAlphaPortfolioValuesFeed
  let exchanger = (await hre.ethers.getContract("Exchanger")) as Exchanger  
  let USDC = (await hre.ethers.getContract("USDC")) as ERC20
  let beyondPricer = (await hre.ethers.getContract("IBeyondPricer")) as IBeyondPricer

  const [ deployer ] = await hre.ethers.getSigners()
  
  // await USDC.connect(deployer).approve(exchanger.address, parseUnits("3", 6))
  // await WETH.connect(deployer).approve(exchanger.address, ethers.constants.MaxUint256)
  // await WBTC.connect(deployer).approve(exchanger.address, ethers.constants.MaxUint256)

  const param = [
    {
      actionType: 0,
      owner: "0x0000000000000000000000000000000000000000",
      secondAddress: "0x0000000000000000000000000000000000000000",
      asset: "0x0000000000000000000000000000000000000000",
      vaultId: 0,
      amount: 0,
      optionSeries: {
        expiration: 1701417600,
        strike: BN.from("2200000000000000000000"),
        isPut: false,
        underlying: "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1",
        strikeAsset: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831",
        collateral: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831"
      }, 
      indexOrAcceptablePremium: 0,
      data: "0x0000000000000000000000000000000000000000",
    },
    {
      actionType: 1,
      owner: "0x0000000000000000000000000000000000000000",
      secondAddress: "0x0641bc55DDAb3b9636e82CbF87EDE3c3c533039d",
      asset: "0x0000000000000000000000000000000000000000",
      vaultId: 0,
      amount: BN.from("100000000000000000"),
      optionSeries: {
        expiration: 1701417600,
        strike: BN.from("2200000000000000000000"),
        isPut: false,
        underlying: "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1",
        strikeAsset: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831",
        collateral: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831"
      }, 
      indexOrAcceptablePremium: 1000000,
      data: "0x0000000000000000000000000000000000000000",
    }
  ]

  // const optionDetails = await optioinExchanger.getOptionDetails(ethers.constants.AddressZero, param[0].optionSeries)
  // console.log("optionDetails: ", optionDetails.toString())

  // const oHash = await optioinExchanger.checkHash(param[0].optionSeries, optionDetails[2], false)
  // console.log("oHash: ", oHash)

  // const netDhvExposure = await alphaPortfolioValuesFeed.netDhvExposure(oHash)
  // console.log("netDhvExposure: ", netDhvExposure.toString())

  // const quoteOptionPrice = await beyondPricer.quoteOptionPrice(param[0].optionSeries, param[0].amount, false, netDhvExposure)
  // console.log("quoteOptionPrice: ", quoteOptionPrice.toString())

  const moduleArray = [
    await txBuilder.module(ProtocolType.rysk_finance)
  ]

  const preparationParametrsArray = [
    {
      operation: OperationType.RYSK,
      operationQueue: param
    }
  ]

  const parametersArray = [
      await TxBuilderOpenRyskFinance.encodeFromRyskFinance(
        preparationParametrsArray
      )
  ]

  const swapDataArray = [
    await exchanger.encodeFromExchange({
      path: solidityPack(["address", "uint24", "address"], [USDC.address, 3000, USDC.address]),
      tokenIn: USDC.address,
      tokenOut: USDC.address,
      amountIn: BN.from(1000000),
      amountOutMinimum: (await TxBuilderOpenRyskFinance.calculateAmount(parametersArray[0])).amount.mul(103).div(103),
      isETH: false,
      swap: false
    })
  ]

  await txBuilder.consolidationOfTransactions(moduleArray, parametersArray, swapDataArray, 0)
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
