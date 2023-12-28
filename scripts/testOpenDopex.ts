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
import {TxBuilderOpenDopex} from "../typechain-types";
import {IOptionExchange} from "../typechain-types";
import { IAlphaPortfolioValuesFeed } from "../typechain-types";
import { IBeyondPricer } from "../typechain-types";
import { IUniswapFreeAmounts } from "../typechain-types";
import { UniswapV3Pool } from "../typechain-types";
import { Position, TickMath, Pool, Tick,  } from "@uniswap/v3-sdk";
import { Token, ChainId } from '@uniswap/sdk-core'
import axios, { AxiosRequestConfig } from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const hre = require("hardhat");

chai.use(solidity)
const {expect} = chai

async function main() {
  
  const {deploy, get, execute} = deployments

  const ProtocolType = {
    lyra_eth: 0,
    lyra_btc: 1,
    hegic: 2,
    rysk_finance: 3,
    premia: 4,
    dopex: 5
  }

  let txBuilder = (await hre.ethers.getContract("TxBuilder")) as TxBuilder
  let TxBuilderOpenDopex = (await hre.ethers.getContract("TxBuilderOpenDopex")) as TxBuilderOpenDopex
  let exchanger = (await hre.ethers.getContract("Exchanger")) as Exchanger  
  let USDCe = (await hre.ethers.getContract("USDCe")) as ERC20

  const [ deployer ] = await hre.ethers.getSigners()
  
  // await USDCe.connect(deployer).approve(exchanger.address, parseUnits("3", 6))
  // await WETH.connect(deployer).approve(exchanger.address, ethers.constants.MaxUint256)
  // await WBTC.connect(deployer).approve(exchanger.address, ethers.constants.MaxUint256)

  // let uniswapFreeAmounts = (await hre.ethers.getContract("IUniswapFreeAmounts")) as IUniswapFreeAmounts

  // const tickLower = -198920;
  // const tickUpper = -198910;
  // const amount0 = parseUnits("0.123858830730003001", 18).toHexString()
  // const amount1 = 0

  // const UniswapV3Pool_WETH_USDC = (await hre.ethers.getContract("IUniswapV3Pool_WETH_USDC")) as UniswapV3Pool
  // const tokenA = new Token(ChainId.ARBITRUM_ONE, await UniswapV3Pool_WETH_USDC.token0(), 18)
  // const tokenB = new Token(ChainId.ARBITRUM_ONE, await UniswapV3Pool_WETH_USDC.token1(), 18)
  // const poolFee = await UniswapV3Pool_WETH_USDC.fee()
  // const slot0 = await UniswapV3Pool_WETH_USDC.slot0()
  // const sqrtRatioX96 = slot0.sqrtPriceX96
  // const liquidity = await UniswapV3Pool_WETH_USDC.liquidity()
  // const tickCurrent = slot0.tick

  // const pool = new Pool(
  //   tokenA,
  //   tokenB,
  //   poolFee,
  //   sqrtRatioX96.toHexString(),
  //   liquidity.toHexString(),
  //   tickCurrent
  // );
  
  // console.log('\ntickCurrent', tickCurrent, "\ntickLower", tickLower, "\ntickUpper", tickUpper)
  // const position = Position.fromAmounts({
  //   pool: pool,
  //   tickLower: tickLower,
  //   tickUpper: tickUpper,
  //   amount0: amount0,
  //   amount1: amount1,
  //   useFullPrecision: true
  // });

  // console.log("position.liquidity:", position.liquidity.toString());

  // const query = `{
  //   strikes(
  //     first: 1000,
  //     where: { pool: "${UniswapV3Pool_WETH_USDC.address.toLowerCase()}", tickLower:${tickLower}, tickUpper:${tickUpper}},
  //   ) {
  //     handler
  //     tickLower
  //     tickUpper
  //     pool
  //     usedLiquidity
  //     totalLiquidity
  //   }
  // }`;
  
  // const requestData = { query };

  // const config: AxiosRequestConfig = {
  //   headers: {
  //     'Content-Type': 'application/json',
  //   },
  // };
  
  // const strikeData = (await axios.post(
  //   'https://gateway-arbitrum.network.thegraph.com/api/1c958dac2af0db36a8e674bfdf557728/subgraphs/id/CDZoLyr2nbkKBPtN3jsV4ZCxPatDd9zBfmYvp9xG8RcN',
  //   requestData,
  //   config
  // )).data.data.strikes[0]

  // const free_liquidity = strikeData.totalLiquidity - strikeData.usedLiquidity

  // console.log("free liquidity", free_liquidity)

  // const ret = await uniswapFreeAmounts.getFreeAmounts(
  //   TickMath.getSqrtRatioAtTick(tickCurrent).toString(),
  //   TickMath.getSqrtRatioAtTick(tickLower).toString(),
  //   TickMath.getSqrtRatioAtTick(tickUpper).toString(),
  //   BigInt(free_liquidity)
  // )
  // console.log("free amounts", ret.toString())

  const moduleArray = [
    await txBuilder.module(ProtocolType.dopex)
  ]

  const parametersArray = [
      await TxBuilderOpenDopex.encodeFromDopex(
        "0x764fa09d0b3de61eed242099bd9352c1c61d3d27",
        "2358269",
        {
          optionTicks: [{
            _handler: "0xe11d346757d052214686bcbc860c94363afb4a9a",
            pool: "0xc31e54c7a869b9fcbecc14363cf510d1c41fa443",
            tickLower: -198920,
            tickUpper: -198910,
            liquidityToUse: "98358848478499"
          }],
          tickLower: -198920,
          tickUpper: -198910,
          ttl: 86400,
          isCall: false,
          maxCostAllowance: "20000"
        }
      )
  ]

  const swapDataArray = [
    await exchanger.encodeFromExchange({
      path: solidityPack(["address", "uint24", "address"], [USDCe.address, 3000, USDCe.address]),
      tokenIn: USDCe.address,
      tokenOut: USDCe.address,
      amountIn: "20000",
      amountOutMinimum: "20000",
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
