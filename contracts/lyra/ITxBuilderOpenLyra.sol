pragma solidity ^0.8.3;

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

import {IOptionMarket} from "./IOptionMarket.sol";

interface ITxBuilderOpenLyra {

    // OWNER FUNCTIONS //

    /**
     * @notice Set a new referrer address.
     * @dev This external function allows the owner to update the referrer address associated with the contract.
     * @param newReferrer The new address to set as the referrer.
     */
    function setReferrer(address newReferrer) external;

    // EXTERNAL FUNCTIONS //  

    /**
     * @notice Grants an unlimited approval for assets to be used in the OptionMarket.
     * @dev This external function allows the contract owner to grant an unlimited approval for the quote asset and base asset to be used within the OptionMarket contract. 
     * It sets the approval amount to the maximum possible value, allowing the OptionMarket to interact with these assets without needing further approvals.
     */
    function allApprove() external;

    // PURE FUNCTIONS //

    /**
     * @notice Encodes parameters for interacting with a Lyra option strategy.
     * @dev This external function encodes the provided trade input parameters into a bytes array for interactions with a Lyra option strategy.
     * @param params The trade input parameters to encode.
     * @return paramData The encoded parameters as a bytes array.
     */
    function encodeFromLyra(IOptionMarket.TradeInputParameters memory params) external pure returns (bytes memory paramData);

    /**
     * @notice Decodes parameters from an encoded byte array.
     * @dev This public function decodes an encoded byte array containing trade input parameters related to a Lyra option strategy.
     * @param paramData The encoded parameters as a bytes array.
     * @return params The decoded trade input parameters.
     */
    function decodeFromLyra(bytes memory paramData) external pure returns (IOptionMarket.TradeInputParameters memory params);

    // EVENTS //

    /**
     * @notice Emitted when a position is opened using the Lyra protocol.
     * @dev This event is emitted when a user opens a position using the Lyra protocol, recording important details of the transaction.
     * @param buildID The unique identifier for the Lyra option position build.
     * @param strikeId The identifier for the strike price of the option.
     * @param positionId The identifier for the option position.
     * @param iterations The number of iterations for the Lyra option.
     * @param optionType The type of the Lyra option (e.g., LONG_CALL, LONG_PUT, SHORT_CALL_BASE).
     * @param amount The amount of the Lyra option.
     * @param setCollateralTo The collateral amount set for the option.
     * @param minTotalCost The minimum total cost allowed for the option.
     * @param maxTotalCost The maximum total cost allowed for the option.
     * @param referrer The referrer associated with the option transaction.
     * @param tokenID The unique identifier of the Lyra option token.
     */
    event OpenPositionByLyra(
        uint256 indexed buildID,
        uint256 strikeId,
        uint256 positionId,
        uint256 iterations,
        IOptionMarket.OptionType optionType,
        uint256 amount,
        uint256 setCollateralTo,
        uint256 minTotalCost,
        uint256 maxTotalCost,
        address referrer,
        uint256 tokenID
    );
}
