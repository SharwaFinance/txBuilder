import { parseUnits, formatUnits, solidityPack} from "ethers/lib/utils";

const OperationType = {
    OPYN: 0,
    RYSK: 1
}

const RyskActions = {
    ISSUE: 0, 
    BUYOPTION: 1, 
    SELLOPTION: 2, 
    CLOSEOPTION: 3 
}

const OpynActions = {
    OPENVAULT: 0,
    MINTSHORTOPTION: 1,
    BURNSHORTOPTION: 2,
    DEPOSITLONGOPTION: 3,
    WITHDRAWLONGOPTION: 4,
    DEPOSITCOLLATERAL: 5,
    WITHDRAWCOLLATERAL: 6,
    SETTLEVAULT: 7,
    REDEEM: 8,
    CALL: 9,
    LIQUIDATE: 10,
}

const Collateral = {
    PARTIALLY_COLLATERALISED: "0x0000000000000000000000000000000000000000000000000000000000000001", 
    FULLY_COLLATERALISED: "0x0000000000000000000000000000000000000000"
}

const ZeroAddress = "0x0000000000000000000000000000000000000000"
const USDC = "0xaf88d065e77c8cC2239327C5EDb3A432268e5831"
const WETH = "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1"
const Sender = "0x0641bc55DDAb3b9636e82CbF87EDE3c3c533039d"
const OptionExchanger = "0xC117bf3103bd09552F9a721F0B8Bce9843aaE1fa"

const WETHUSDC_08_December_2023_2050Call_USDC_Collateral = "0x552f73395A10Ab8dBefE2F16b208AC5717cCBcc1"
const WETHUSDC_08_December_2023_2100Call_USDC_Collateral = "0x64BEda4A29E9aad078b25bcC6CDCb193EF962042"

const CALL_CREDIT_SPREAD = [
    {
        operation: OperationType.RYSK, 
        operationQueue: [
            {
                actionType: RyskActions.ISSUE,
                owner: ZeroAddress,
                secondAddress: ZeroAddress,
                asset: ZeroAddress,
                vaultId: 0,
                amount: 0,
                optionSeries: {  
                    expiration: 1702022400,
                    strike: parseUnits("2100", 18),
                    isPut: false,
                    underlying: WETH,
                    strikeAsset: USDC,
                    collateral: USDC,
                },
                indexOrAcceptablePremium: 0,
                data: Collateral.FULLY_COLLATERALISED,
            },
            {
                actionType: RyskActions.BUYOPTION,
                owner: ZeroAddress,
                secondAddress: Sender,
                asset: ZeroAddress,
                vaultId: 0,
                amount: parseUnits("0.1", 18),
                optionSeries: {  
                    expiration: 1702022400,
                    strike: parseUnits("2100", 18),
                    isPut: false,
                    underlying: WETH,
                    strikeAsset: USDC,
                    collateral: USDC,
                },
                indexOrAcceptablePremium: 13937548,
                data: Collateral.FULLY_COLLATERALISED,
            },
        ]
    },
    {
        operation: OperationType.OPYN, 
        operationQueue: [
            {
                actionType: OpynActions.OPENVAULT,
                owner: Sender,
                secondAddress: Sender,
                asset: ZeroAddress,
                vaultId: 8,
                amount: 0,
                optionSeries: {
                    expiration: 1,
                    strike: 1,
                    isPut: true,
                    underlying: ZeroAddress,
                    strikeAsset: ZeroAddress,
                    collateral: ZeroAddress,
                },
                indexOrAcceptablePremium: 0,
                data: Collateral.PARTIALLY_COLLATERALISED,
            },
            {
                actionType: OpynActions.DEPOSITCOLLATERAL,
                owner: Sender,
                secondAddress: OptionExchanger,
                asset: USDC,
                vaultId: 8,
                amount: parseUnits("5", 6),
                optionSeries: {
                    expiration: 1,
                    strike: 1,
                    isPut: true,
                    underlying: ZeroAddress,
                    strikeAsset: ZeroAddress,
                    collateral: ZeroAddress,
                }, 
                indexOrAcceptablePremium: 0,
                data: Collateral.FULLY_COLLATERALISED,
            },
            {
                actionType: OpynActions.MINTSHORTOPTION,
                owner: Sender,
                secondAddress: OptionExchanger,
                asset: WETHUSDC_08_December_2023_2050Call_USDC_Collateral,
                vaultId: 8,
                amount: parseUnits("10", 6),
                optionSeries: {
                    expiration: 1,
                    strike: 1,
                    isPut: true,
                    underlying: ZeroAddress,
                    strikeAsset: ZeroAddress,
                    collateral: ZeroAddress,
                },  
                indexOrAcceptablePremium: 0,
                data: Collateral.FULLY_COLLATERALISED,
            },
            {
                actionType: OpynActions.DEPOSITLONGOPTION,
                owner: Sender,
                secondAddress: Sender,
                asset: WETHUSDC_08_December_2023_2100Call_USDC_Collateral,
                vaultId: 8,
                amount: parseUnits("10", 6),
                optionSeries: {
                    expiration: 1,
                    strike: 1,
                    isPut: true,
                    underlying: ZeroAddress,
                    strikeAsset: ZeroAddress,
                    collateral: ZeroAddress,
                },   
                indexOrAcceptablePremium: 0,
                data: Collateral.FULLY_COLLATERALISED
            }
        ]
    }
]







