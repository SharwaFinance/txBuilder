import {ethers, deployments} from "hardhat"
import {BigNumber as BN, Signer} from "ethers"
import {solidity} from "ethereum-waffle"
import chai from "chai"
import { ERC20 } from "../typechain-types/@openzeppelin/contracts/token/ERC20";
import { IERC721 } from "../typechain-types/@openzeppelin/contracts/token/ERC721";
import { parseUnits, formatUnits, solidityPack, toUtf8Bytes, keccak256 } from "ethers/lib/utils";
import { Exchanger } from "../typechain-types";
import { IQuoter } from "../typechain-types";
import { RoleManager } from "../typechain-types";
import { TxBuilder } from "../typechain-types";

const hre = require("hardhat");

chai.use(solidity)
const {expect} = chai

async function main() {
  
  const {deploy, get, execute} = deployments

  let exchanger = (await hre.ethers.getContract("Exchanger")) as Exchanger
  let IQuoter = (await hre.ethers.getContract("IQuoter")) as IQuoter
  // let USDC = (await hre.ethers.getContract("USDC")) as ERC20
  let WETH = (await hre.ethers.getContract("WETH")) as ERC20
  let WBTC = (await hre.ethers.getContract("WBTC")) as ERC20
  let DAI = (await hre.ethers.getContract("DAI")) as ERC20
  let RoleManager = (await hre.ethers.getContract("RoleManager")) as RoleManager
  let txBuilder = (await hre.ethers.getContract("TxBuilder")) as TxBuilder

  const TRADER_ROLE = keccak256(
    toUtf8Bytes("TRADER_ROLE"),
  )

  const [ deployer ] = await hre.ethers.getSigners()

  // await USDC.connect(deployer).approve(exchanger.address, ethers.constants.MaxUint256)
  // await WETH.connect(deployer).approve(exchanger.address, ethers.constants.MaxUint256)
  // await DAI.connect(deployer).approve(exchanger.address, ethers.constants.MaxUint256)

  await RoleManager.grantRole(TRADER_ROLE, deployer.address)
  // await RoleManager.grantRole(TRADER_ROLE, txBuilder.address)

  let data = {
    path: solidityPack(["address", "uint24", "address"], [WETH.address, 3000, WETH.address]),
    tokenIn: WETH.address,
    tokenOut: WETH.address,
    amountIn: parseUnits("0.01", 18),
    amountOutMinimum: parseUnits("0.01", 18),
    isETH: true,
    swap: true
  }

  // const QuoterData = await IQuoter.callStatic.quoteExactInput(
  //   solidityPack(["address", "uint24", "address"], [DAI.address, 3000, USDC.address]),
  //   parseUnits("300", 18)
  // )

  // console.log(formatUnits(QuoterData.toString(), 6))

  // console.log(exchanger.address)
  await txBuilder.setExchanger(exchanger.address)
  // console.log(await txBuilder.exchanger())

  // await exchanger.connect(deployer).swap(await exchanger.encodeFromExchange(data), deployer.address, deployer.address, {value: parseUnits("0.01", 18)})

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
