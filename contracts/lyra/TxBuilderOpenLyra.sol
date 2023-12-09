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
import {IOptionMarket} from "./IOptionMarket.sol";
import {IOptionToken} from "./IOptionToken.sol";
import {ITxBuilderOpenLyra} from "./ITxBuilderOpenLyra.sol";

/**
 * @title TxBuilderOpenLyra
 * @author 0nika0
 * @notice A contract for building and processing Lyra option transactions.
 */
contract TxBuilderOpenLyra is BaseTxBuilderOpen, ITxBuilderOpenLyra {
    
    address public optionMarket; 
    address public optionToken; 
    address public referrer;

    constructor(
        address _optionMarket,
        address _optionToken,
        address _referrer
    ) {
        optionMarket = _optionMarket;
        optionToken = _optionToken;
        referrer = _referrer;
    }

    // OWNER FUNCTIONS //

    /**
     * @dev See {ITxBuilderOpenLyra-setReferrer}.
     */
    function setReferrer(address newReferrer) external onlyOwner {
        referrer = newReferrer;
    }

    // EXTERNAL FUNCTIONS //  

    /**
     * @dev See {ITxBuilderOpenLyra-allApprove}.
     */
    function allApprove() external {
        IOptionMarket(optionMarket).quoteAsset().approve(optionMarket, type(uint256).max);
        IOptionMarket(optionMarket).baseAsset().approve(optionMarket, type(uint256).max);
    }

    // PUBLIC FUNCTIONS //  

    /**
     * @notice Calculate the amount of a token based on provided parameters.
     * @dev This public view function calculates the amount of a token based on a set of input parameters.
     * It decodes the parameters, retrieves the necessary information from a Lyra strategy,
     * and calculates the amount based on the option type and related factors.
     * @param parameters The encoded parameters for the calculation.
     * @return token The address of the token to be calculated.
     * @return amount The calculated amount of the token.
     */
    function calculateAmount(
        bytes memory parameters
    ) public view override returns (
        address token,
        uint256 amount
    ) {
        (
            IOptionMarket.TradeInputParameters memory params
        ) = decodeFromLyra(parameters);

        if (params.optionType == IOptionMarket.OptionType.LONG_CALL || params.optionType == IOptionMarket.OptionType.LONG_PUT) {
            amount = params.maxTotalCost / (1e18 / 10 ** IOptionMarket(optionMarket).quoteAsset().decimals());
            token = address(IOptionMarket(optionMarket).quoteAsset());
        } else if (params.optionType == IOptionMarket.OptionType.SHORT_CALL_QUOTE || params.optionType == IOptionMarket.OptionType.SHORT_PUT_QUOTE) {
            amount = params.setCollateralTo / (1e18 / 10 ** IOptionMarket(optionMarket).quoteAsset().decimals());
            token = address(IOptionMarket(optionMarket).quoteAsset());
        } else if (params.optionType == IOptionMarket.OptionType.SHORT_CALL_BASE) {
            amount = params.setCollateralTo / (1e18 / 10 ** IOptionMarket(optionMarket).baseAsset().decimals());
            token = address(IOptionMarket(optionMarket).baseAsset());
        }
    }

    // INTERNAL FUNCTIONS //   

    /**
     * @notice Process a transaction for opening a Lyra option position.
     * @dev This internal function processes a transaction for opening a Lyra option position based on provided parameters.
     * It decodes the parameters, retrieves the necessary information from a Lyra strategy,
     * calculates the required Lyra asset, and performs the necessary actions to create and transfer the option token to the user.
     * @param parameters The encoded parameters for opening the option position.
     * @param buildID The unique identifier for the option position build.
     * @param user The address of the user who is opening the option position.
     */
    function _processTx(
        bytes memory parameters,
        uint256 buildID,
        address user
    ) override internal {
        (
            IOptionMarket.TradeInputParameters memory params
        ) = decodeFromLyra(parameters);

        params.referrer = referrer; 
        
        (address lyraAsset,) = calculateAmount(parameters);
        
        uint256 id = IOptionToken(optionToken).nextId();
        
        IOptionMarket(optionMarket).openPosition(params);
        
        ERC20(lyraAsset).transfer(user, ERC20(lyraAsset).balanceOf(address(this)));
        
        IOptionToken(optionToken).transferFrom(address(this), user, id);

        if (params.optionType == IOptionMarket.OptionType.SHORT_CALL_BASE) {
            IOptionMarket(optionMarket).quoteAsset().transfer(user, IOptionMarket(optionMarket).quoteAsset().balanceOf(address(this)));
        }
        
        emit OpenPositionByLyra(
            buildID,
            params.strikeId,
            params.positionId,
            params.iterations,
            params.optionType,
            params.amount,
            params.setCollateralTo,
            params.minTotalCost,
            params.maxTotalCost,
            params.referrer,
            id
        );
    }

    // PURE FUNCTIONS //

    /**
     * @dev See {ITxBuilderOpenLyra-encodeFromLyra}.
     */
    function encodeFromLyra(IOptionMarket.TradeInputParameters memory params) external pure returns (bytes memory paramData) {
        return abi.encode(params);
    }

    /**
     * @dev See {ITxBuilderOpenLyra-decodeFromLyra}.
     */
    function decodeFromLyra(bytes memory paramData) public pure returns (IOptionMarket.TradeInputParameters memory params) {
        (
            params
        ) = abi.decode(paramData, (
            IOptionMarket.TradeInputParameters
        ));
    }
}
