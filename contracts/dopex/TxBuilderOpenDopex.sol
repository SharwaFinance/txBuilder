pragma solidity 0.8.19;

/**
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SharwaFinance
 * Copyright (C) 2023 SharwaFinance
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

import {BaseTxBuilderOpen, ERC20} from "../BaseTxBuilderOpen.sol";
import {ITxBuilderOpenDopex} from "./ITxBuilderOpenDopex.sol";
import {IDopexV2OptionMarket, IUniswapV3Pool} from "./IDopexV2OptionMarket.sol";

contract TxBuilderOpenDopex is BaseTxBuilderOpen, ITxBuilderOpenDopex {

    uint8 public immutable putAssetDecimals = 6;

    // EXTERNAL FUNCTIONS //  

    function allApprove(address token, address dopexV2OptionMarket, uint256 amount) external onlyOwner {
        ERC20(token).approve(dopexV2OptionMarket, amount);
    }   

    // PUBLIC FUNCTIONS //  

    function calculateAmount(
        bytes memory parameters
    ) public view override returns (
        address token,
        uint256 amount
    ) {
        (
            IDopexV2OptionMarket dopexV2OptionMarket,
            uint256 optionAmount,
            IDopexV2OptionMarket.OptionParams memory params
        ) = decodeFromDopex(parameters);

        IUniswapV3Pool uniswapPool = IUniswapV3Pool(params.optionTicks[0].pool);

        token = params.isCall ? uniswapPool.token0() : uniswapPool.token1();

        uint256 strike = dopexV2OptionMarket.getPricePerCallAssetViaTick(
            params.optionTicks[0].pool, 
            params.isCall ? params.tickUpper : params.tickLower
        );

        uint256 vol = dopexV2OptionMarket.ttlToVol(params.ttl);

        uint256 premium = dopexV2OptionMarket.getPremiumAmount(
            params.isCall ? false : true,
            block.timestamp + params.ttl,
            strike,
            dopexV2OptionMarket.getCurrentPricePerCallAsset(params.optionTicks[0].pool),
            vol,
            params.isCall 
                ? optionAmount
                : (optionAmount * (10 ** putAssetDecimals)) / strike 
        );

        uint256 protocolFees = dopexV2OptionMarket.getFee(
            optionAmount,
            vol,
            premium
        );

        amount = premium + protocolFees;
    } 

    // INTERNAL FUNCTIONS //    

    function _processTx(
        bytes memory parameters, 
        uint256 buildID,
        address user
    ) internal override {
        (
            IDopexV2OptionMarket dopexV2OptionMarket,
            uint256 optionAmount,
            IDopexV2OptionMarket.OptionParams memory params
        ) = decodeFromDopex(parameters);
        
        (address token, uint256 amount) = calculateAmount(parameters);
        
        uint256 optionIds = dopexV2OptionMarket.optionIds()+1;

        dopexV2OptionMarket.mintOption(params);

        dopexV2OptionMarket.transferFrom(address(this), user, optionIds);
        ERC20(token).transfer(user, ERC20(token).balanceOf(address(this)));
        
        emit OpenPositionByDopex(buildID, user, params, optionAmount, amount);
    }

    // PURE FUNCTIONS //

    function encodeFromDopex(
        IDopexV2OptionMarket dopexV2OptionMarket,
        uint256 optionAmount,
        IDopexV2OptionMarket.OptionParams memory params
    ) external pure returns (bytes memory paramData) {
        return abi.encode(dopexV2OptionMarket, optionAmount, params);
    }

    function decodeFromDopex(
        bytes memory paramData
    ) public pure returns (
        IDopexV2OptionMarket dopexV2OptionMarket,
        uint256 optionAmount,
        IDopexV2OptionMarket.OptionParams memory params
    ) {
        (
            dopexV2OptionMarket,
            optionAmount,
            params
        ) = abi.decode(paramData, (
            IDopexV2OptionMarket,
            uint256,
            IDopexV2OptionMarket.OptionParams
        ));
    }


}