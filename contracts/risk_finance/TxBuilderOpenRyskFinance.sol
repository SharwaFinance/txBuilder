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
import {IBeyondPricer} from "./IBeyondPricer.sol";
import {IOptionExchange} from "./IOptionExchange.sol";
import {IAlphaPortfolioValuesFeed} from "./IAlphaPortfolioValuesFeed.sol";
import {ICombinedActions, ITxBuilderOpenRyskFinance} from "./ITxBuilderOpenRyskFinance.sol";
import {ITypes} from "./ITypes.sol";

/**
 * @title Rysk Finance Transaction Builder - Open Position
 * @author 0nika0
 * @notice A contract facilitating the opening of positions on the Rysk Finance protocol. 
 *         It provides functions to calculate transaction amounts, process transactions, and manage approvals.
 */
contract TxBuilderOpenRyskFinance is BaseTxBuilderOpen, ITxBuilderOpenRyskFinance {
    ERC20 public usdc;
    ERC20 public weth; 
    ERC20 public wbtc; 

    IBeyondPricer public pricer;
    IOptionExchange public optionExchange; 
    IAlphaPortfolioValuesFeed public portfolioValuesFeed;

    constructor(
        ERC20 _usdc,
        ERC20 _weth, 
        ERC20 _wbtc,
        IBeyondPricer _pricer,
        IOptionExchange _optionExchange,
        IAlphaPortfolioValuesFeed _portfolioValuesFeed
    ) {
        usdc = _usdc;
        weth = _weth; 
        wbtc = _wbtc;
        pricer = _pricer;
        optionExchange = _optionExchange;
        portfolioValuesFeed = _portfolioValuesFeed;
    }

    // EXTERNAL FUNCTIONS //  

    /**
     * @dev See {ITxBuilderOpenRyskFinance-allApprove}.
     */
    function allApprove() external {
        usdc.approve(address(optionExchange), type(uint256).max);
        weth.approve(address(optionExchange), type(uint256).max);
        wbtc.approve(address(optionExchange), type(uint256).max);
    }   

    // PUBLIC FUNCTIONS //  

    /**
     * @dev This public view function `calculateAmount` takes encoded parameters from Rysk Finance and decodes them
     * to determine the token and amount involved in the specified Rysk operations. The decoded parameters represent
     * a series of actions (operation procedures) related to Rysk Finance.
     *
     * @param parameters Encoded parameters containing Rysk Finance operation details.
     * @return token The address of the token involved in the Rysk operations.
     * @return amount The total amount associated with the specified Rysk operations.
     */
    function calculateAmount(
        bytes memory parameters
    ) public view override returns (
        address token,
        uint256 amount
    ) {
        (
            ICombinedActions.OperationProcedures[] memory operationProcedures
        ) = decodeFromRyskFinance(parameters);

        address verificationAddress;

        uint256 lenRyskActionArgs;

        for (uint256 i; i < operationProcedures.length; i++) {
            if (operationProcedures[i].operation == ICombinedActions.OperationType.RYSK) {
                    lenRyskActionArgs++;
            }
        }
        
        ICombinedActions.ActionArgs[] memory ryskActionArgs = new ICombinedActions.ActionArgs[](lenRyskActionArgs);

        for (uint256 i; i < lenRyskActionArgs; i++) {
            if (operationProcedures[i].operation == ICombinedActions.OperationType.RYSK) {
                for (uint256 index; index < operationProcedures[i].operationQueue.length; index++) {
                    ryskActionArgs[i] = operationProcedures[i].operationQueue[index];
                }
            }
        }

        for (uint256 i; i < lenRyskActionArgs; i++) {
            if (ryskActionArgs[i].actionType == 1 || ryskActionArgs[i].actionType == 2) {
                address collateral = ryskActionArgs[i].optionSeries.collateral;

                if (verificationAddress == address(0)) {
                    verificationAddress = collateral;
                }

                require(collateral == verificationAddress, "different collateral tokens");
                token = collateral;

                amount += ryskActionArgs[i].indexOrAcceptablePremium;
            }
        }
    }    

    // INTERNAL FUNCTIONS //    

    /**
     * @dev This internal function `_processTx` is responsible for processing a transaction based on Rysk Finance parameters.
     * It decodes the provided parameters, calculates the involved token and amount, performs operations on the options exchange,
     * transfers any remaining USDC, WETH, and WBTC balances back to the user, and emits an event to signal the opening of a position
     * by Rysk Finance.
     *
     * @param parameters Encoded parameters containing Rysk Finance operation details.
     * @param buildID Identifier for the build associated with the transaction.
     * @param user The address of the user initiating the transaction.
     */
    function _processTx(
        bytes memory parameters, 
        uint256 buildID,
        address user
    ) internal override {
        (
            ICombinedActions.OperationProcedures[] memory operationProcedures
        ) = decodeFromRyskFinance(parameters);
        
        (address token, ) = calculateAmount(parameters);
        
        optionExchange.operate(operationProcedures);

        uint256 balanceUSDC = ERC20(usdc).balanceOf(address(this));
        if (balanceUSDC != 0) {
            ERC20(usdc).transfer(user, balanceUSDC);
        }

        uint256 balanceWETH = ERC20(weth).balanceOf(address(this));
        if (balanceWETH != 0) {
            ERC20(weth).transfer(user, balanceWETH);
        }

        uint256 balanceWBTC = ERC20(wbtc).balanceOf(address(this));
        if (balanceWBTC != 0) {
            ERC20(wbtc).transfer(user, balanceWBTC);
        }
        
        emit OpenPositionByRyskFinance(buildID, token, operationProcedures);
    }

    // PURE FUNCTIONS //

    /**
     * @dev See {ITxBuilderOpenRyskFinance-encodeFromRyskFinance}.
     */
    function encodeFromRyskFinance(
        ICombinedActions.OperationProcedures[] memory operationProcedures
    ) external pure returns (bytes memory paramData) {
        return abi.encode(operationProcedures);
    }

    /**
     * @dev See {ITxBuilderOpenRyskFinance-decodeFromRyskFinance}.
     */
    function decodeFromRyskFinance(
        bytes memory paramData
    ) public pure returns (
        ICombinedActions.OperationProcedures[] memory operationProcedures
    ) {
        (
            operationProcedures
        ) = abi.decode(paramData, (
            ICombinedActions.OperationProcedures[]
        ));
    }
}
