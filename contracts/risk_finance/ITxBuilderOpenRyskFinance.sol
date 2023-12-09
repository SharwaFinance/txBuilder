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

import {ICombinedActions} from "./ICombinedActions.sol";

interface ITxBuilderOpenRyskFinance {

    // EXTERNAL FUNCTIONS //  

    /**
     * @dev This external function `allApprove` is designed to approve a maximum amount of tokens
     * required for trading on a specific exchange. In this case, the function approves the maximum amount
     * of USDC, WETH, and WBTC tokens for use in transactions on the options exchange specified in the `optionExchange` variable.
     * 
     * Note: Approving tokens allows the contract to perform operations with these tokens on behalf of the contract owner,
     * in this context, on behalf of the contract containing this function.
     */
    function allApprove() external;

    // PURE FUNCTIONS //

    /**
     * @dev This external function `encodeFromRyskFinance` takes an array of Rysk Finance operation procedures
     * and encodes them into a byte array. This encoded data can be used to pass Rysk Finance operation details
     * between contracts or external systems.
     *
     * @param operationProcedures An array of Rysk Finance operation procedures to be encoded.
     * @return paramData The encoded byte array representing the Rysk Finance operation procedures.
     */
    function encodeFromRyskFinance(
        ICombinedActions.OperationProcedures[] memory operationProcedures
    ) external pure returns (bytes memory paramData);

    /**
     * @dev This public function `decodeFromRyskFinance` takes an encoded byte array containing Rysk Finance operation details
     * and decodes it into an array of operation procedures. This allows contracts to interpret and use Rysk Finance operations
     * encoded in external systems or passed as data.
     *
     * @param paramData The encoded byte array containing Rysk Finance operation details.
     * @return operationProcedures An array of decoded Rysk Finance operation procedures.
     */
    function decodeFromRyskFinance(
        bytes memory paramData
    ) external pure returns (
        ICombinedActions.OperationProcedures[] memory operationProcedures
    );

    // EVENTS //

    /**
     * @notice Emitted to signal the successful opening of a position by Rysk Finance.
     * @dev This event, `OpenPositionByRyskFinance`, provides information about the specific transaction build
     * identified by `buildID`, the involved `token` in the position, and an array of `OperationProcedures`
     * representing the steps taken in the process. This event is useful for tracking and monitoring transactions
     * related to opening positions initiated by Rysk Finance.
     * @param buildID The unique identifier for the transaction build associated with the opened position.
     * @param token The address of the token involved in the opened position.
     * @param operationProcedures An array of `OperationProcedures` representing the steps taken in the process of opening the position.
     */
    event OpenPositionByRyskFinance(
        uint256 indexed buildID,
        address token,
        ICombinedActions.OperationProcedures[] operationProcedures
    );
}