import { expect } from "chai";
import { ethers, deployments } from "hardhat";
import { Signer } from "ethers";
import { TxBuilderOpenRyskFinance } from "../typechain-types";
import { MockAlphaPortfolioValuesFeed } from "../typechain-types";
import { MockBeyondPricer } from "../typechain-types";
import { MockOptionExchange } from "../typechain-types";

describe("RYSK_FINANCE.spec.ts", function () {
  let txBuilderOpenRyskFinance: TxBuilderOpenRyskFinance
  let alphaPortfolioValuesFeed: MockAlphaPortfolioValuesFeed
  let beyondPricer: MockBeyondPricer
  let optionExchange: MockOptionExchange
  let signers: Signer[]
  let oHash: string

  const OperationType = {
		OPYN: 0,
		RYSK: 1
	}

  beforeEach(async () => {
    await deployments.fixture(["module_rysk_finance"])

    txBuilderOpenRyskFinance = await ethers.getContract("TxBuilderOpenRyskFinance")
    alphaPortfolioValuesFeed = await ethers.getContract("IAlphaPortfolioValuesFeed")
    beyondPricer = await ethers.getContract("IBeyondPricer")
    optionExchange = await ethers.getContract("IOptionExchange")

    oHash = "0xdaa04c6823201a02626caa620d7d8de55a3251ff4d866c6066486b9b9c4f68f8"

    await optionExchange.setLocalData(oHash, "1800000000000000000000") 
    await alphaPortfolioValuesFeed.setNetDhvExposureMap(oHash, "5900000000000000000")
    await beyondPricer.setLocalData(1000000, 2000000, 3000000)

  });

  it("test", async () => {
    const data = await txBuilderOpenRyskFinance.encodeFromRyskFinance(
      [{
        operation: OperationType.RYSK,
        operationQueue: [
          {
            actionType: 1,
            owner: "0x0000000000000000000000000000000000000000",
            secondAddress: "0x0641bc55DDAb3b9636e82CbF87EDE3c3c533039d",
            asset: "0x0000000000000000000000000000000000000000",
            vaultId: 0,
            amount: "100000000000000000",
            optionSeries: {
              expiration: 1700812800,
              strike: "1800000000000000000000",
              isPut: true,
              underlying: "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1",
              strikeAsset: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831",
              collateral: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831",
            },
          indexOrAcceptablePremium: 312708,
          data: "0x0000000000000000000000000000000000000000",
          }
        ]
      }]
    )
    console.log("data", data)
  });
});