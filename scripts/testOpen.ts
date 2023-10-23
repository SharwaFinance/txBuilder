import {ethers, deployments} from "hardhat"
import {BigNumber as BN, Signer} from "ethers"
import {solidity} from "ethereum-waffle"
import chai from "chai"
import { ERC20 } from "../typechain-types/@openzeppelin/contracts/token/ERC20";
import { IERC721 } from "../typechain-types/@openzeppelin/contracts/token/ERC721";
import { TxBuilder } from "../typechain-types";
import { Exchanger } from "../typechain-types";
import { TxBuilderOpenHegic } from "../typechain-types";
import { TxBuilderOpenLyra } from "../typechain-types";
import { parseUnits, formatUnits, solidityPack} from "ethers/lib/utils";
import { RoleManager } from "../typechain-types";

const hre = require("hardhat");

chai.use(solidity)
const {expect} = chai

async function main() {
  
  const {deploy, get, execute} = deployments

  const OptionType = {
    LONG_CALL: 0,
    LONG_PUT: 1,
    SHORT_CALL_BASE: 2,
    SHORT_CALL_QUOTE: 3,
    SHORT_PUT_QUOTE: 4
  }

  // const parameters: {
  //   strikeId: BN;
  //   positionId: BN;
  //   optionType: Number;
  //   amount: BN;
  //   setCollateralTo: BN;
  //   iterations: BN;
  //   minTotalCost: BN;
  //   maxTotalCost: BN;
  // }

  const HegicStrategy_CALL_100_ETH_1 = '0x09a4B65b3144733f1bFBa6aEaBEDFb027a38Fb60'
  const HegicStrategy_CALL_100_ETH_2 = '0x6418C3514923a6464A26A2ffA5f17bF1efC96a21'
  const HegicStrategy_PUT_100_ETH_2  = '0x2739A4C003080A5B3Ade22b92c3321EDa2Da3A9e'

  const ProtocolType = {
    lyra_eth: 0,
    lyra_btc: 1,
    hegic: 2
  }

  let txBuilder = (await hre.ethers.getContract("TxBuilder")) as TxBuilder
  let txBuilderOpenHegic = (await hre.ethers.getContract("TxBuilderOpenHegic")) as TxBuilderOpenHegic
  let txBuilderOpenLyraETH = (await hre.ethers.getContract("txBuilderOpenLyraETH")) as TxBuilderOpenLyra
  let txBuilderOpenLyraBTC = (await hre.ethers.getContract("txBuilderOpenLyraBTC")) as TxBuilderOpenLyra
  let roleManager = (await hre.ethers.getContract("RoleManager")) as RoleManager
  let exchanger = (await hre.ethers.getContract("Exchanger")) as Exchanger  
  let USDC = (await hre.ethers.getContract("USDC")) as ERC20
  let USDT = (await hre.ethers.getContract("USDT")) as ERC20
  let WETH = (await hre.ethers.getContract("WETH")) as ERC20
  let WBTC = (await hre.ethers.getContract("WBTC")) as ERC20
  let hegicErc721 = (await hre.ethers.getContract("hegicErc721")) as IERC721

  const [ deployer ] = await hre.ethers.getSigners()

  // await txBuilder.withdrawERC20(USDC.address, deployer.address, await USDC.balanceOf(txBuilder.address));
  
  await USDT.connect(deployer).approve(exchanger.address, ethers.constants.MaxUint256)
  // await WETH.connect(deployer).approve(exchanger.address, ethers.constants.MaxUint256)
  // await WBTC.connect(deployer).approve(exchanger.address, ethers.constants.MaxUint256)

  const moduleArray = [
    await txBuilder.module(ProtocolType.hegic),
    await txBuilder.module(ProtocolType.lyra_eth)
  ]

  const parametersArray = [
      await txBuilderOpenHegic.encodeFromHegic(
        "0x09a4B65b3144733f1bFBa6aEaBEDFb027a38Fb60",
        parseUnits("0.01", 18),
        604800,
        BN.from("115792089237316195423570985008687907853269984665640564039457584007913129639935"), // maxTotalCost
        []
      ),
      await txBuilderOpenLyraETH.encodeFromLyra(
      {    
          strikeId: 395,
          positionId: 0,
          iterations: 1,
          optionType: 2,
          amount: BN.from("100000000000000000"),
          setCollateralTo: BN.from("100000000000000000"),
          minTotalCost: BN.from("2802148164891014958"),
          maxTotalCost: BN.from("115792089237316195423570985008687907853269984665640564039457584007913129639935"),
          referrer: ethers.constants.AddressZero
      }
    )
  ]

  const swapDataArray = [
    await exchanger.encodeFromExchange({
      path: solidityPack(["address", "uint24", "address"], [USDT.address, 3000, USDC.address]),
      tokenIn: USDT.address,
      tokenOut: USDC.address,
      amountIn: parseUnits("0.5", 6),
      amountOutMinimum: (await txBuilderOpenHegic.calculateAmount(parametersArray[0])).amount,
      isETH: false,
      swap: true
    }),
    await exchanger.encodeFromExchange({
      path: solidityPack(["address", "uint24", "address"], [USDT.address, 3000, WETH.address]),
      tokenIn: USDT.address,
      tokenOut: WETH.address,
      amountIn: parseUnits("190", 6),
      amountOutMinimum: parseUnits("0.1", 18),
      isETH: false,
      swap: true
    })
  ]

  // parseUnits("0.00817393", 18)

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
