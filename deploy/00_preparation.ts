import {HardhatRuntimeEnvironment} from "hardhat/types"

async function deployment(hre: HardhatRuntimeEnvironment): Promise<void> {
  const {deployments, getNamedAccounts, network} = hre
  const {deploy, save, getArtifact} = deployments
  const {deployer} = await getNamedAccounts()

  save("IQuoter", {
    address: "0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6",
    abi: await getArtifact("contracts/exchanger/IQuoter.sol:IQuoter").then((x) => x.abi),
  })

  save("USDT", {
    address: "0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9",
    abi: await getArtifact("@openzeppelin/contracts/token/ERC20/ERC20.sol:ERC20").then((x) => x.abi),
  })

  save("USDCe", {
    address: "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8",
    abi: await getArtifact("@openzeppelin/contracts/token/ERC20/ERC20.sol:ERC20").then((x) => x.abi),
  })

  save("WETH", {
    address: "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1",
    abi: await getArtifact("@openzeppelin/contracts/token/ERC20/ERC20.sol:ERC20").then((x) => x.abi),
  })
  save("WBTC", {
    address: "0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f",
    abi: await getArtifact("@openzeppelin/contracts/token/ERC20/ERC20.sol:ERC20").then((x) => x.abi),
  })

  save("DAI", {
    address: "0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1",
    abi: await getArtifact("@openzeppelin/contracts/token/ERC20/ERC20.sol:ERC20").then((x) => x.abi),
  })

  save("swapRouter", {
    address: "0xE592427A0AEce92De3Edee1F18E0157C05861564",
    abi: await getArtifact("@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol:ISwapRouter").then((x) => x.abi),
  })

  save("optionMarketETH", {
    address: "0x919E5e0C096002cb8a21397D724C4e3EbE77bC15",
    abi: await getArtifact("contracts/lyra/IOptionMarket.sol:IOptionMarket").then((x) => x.abi),
  })

  save("optionMarketBTC", {
    address: "0xe044919cf58dFb066FC9DE7c69C7db19f336B20c",
    abi: await getArtifact("contracts/lyra/IOptionMarket.sol:IOptionMarket").then((x) => x.abi),
  })

  save("lyra_ethErc721", {
    address: "0xe485155ce647157624C5E2A41db45A9CC88098c3",
    abi: await getArtifact("contracts/lyra/IOptionToken.sol:IOptionToken").then((x) => x.abi),
  })

  save("lyra_btcErc721", {
    address: "0x0e97498F3d91756Ec7F2d244aC97F6Ea9f4eBbC3",
    abi: await getArtifact("contracts/lyra/IOptionToken.sol:IOptionToken").then((x) => x.abi),
  })

  save("operationalTreasury", {
    address: "0xec096ea6eB9aa5ea689b0CF00882366E92377371",
    abi: await getArtifact("contracts/hegic/IOperationalTreasury.sol:IOperationalTreasury").then((x) => x.abi),
  })

  save("hegicErc721", {
    address: "0x5Fe380D68fEe022d8acd42dc4D36FbfB249a76d5",
    abi: await getArtifact("contracts/hegic/IPositionsManager.sol:IPositionsManager").then((x) => x.abi),
  })

}

deployment.tags = ["preparation"]
export default deployment
