pragma solidity 0.8.9;

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

import {IHegicStrategy} from "./IHegicStrategy.sol";

interface ITxBuilderOpenHegic {

    // OWNER FUNCTIONS //

    /**
     * @notice Set a new referrer address.
     * @dev This external function allows the owner to update the referrer address associated with the contract.
     * @param newReferrer The new address to set as the referrer.
     */
    function setReferrer(address newReferrer) external;

    // EXTERNAL FUNCTIONS //  

    /**
     * @notice Grants an unlimited approval of USDC tokens to the proxy seller contract.
     * @dev This external function approves the proxy seller contract to spend an unlimited amount of USDC tokens on behalf of the calling user. 
     * It sets the approval amount to the maximum possible value, allowing the proxy seller to interact with USDC tokens without needing further approvals.
     */
    function allApprove() external;

    // PURE FUNCTIONS //

    /**
     * @notice Encodes parameters for interacting with a Hegic option strategy.
     * @dev This external function encodes various parameters, including the strategy contract, 
     * option amount, option period, maximum total cost, and additional data, 
     * into a single byte array for interactions with a Hegic option strategy.
     * @param strategy The address of the Hegic option strategy contract.
     * @param amount The amount of the option to be purchased.
     * @param period The duration of the option period in seconds.
     * @param maxTotalCost The maximum total cost allowed for the option purchase.
     * @param additional Additional data required for the strategy, encoded as bytes array.
     * @return paramData The encoded parameters as a bytes array.
     */
    function encodeFromHegic(
        IHegicStrategy strategy,
        uint256 amount,
        uint256 period,
        uint256 maxTotalCost,
        bytes[] memory additional
    ) external pure returns (bytes memory paramData);

    /**
     * @notice Decodes parameters from an encoded byte array.
     * @dev This public function decodes an encoded byte array containing parameters related to a Hegic option strategy. 
     * It extracts the strategy contract address, option amount, option period, maximum total cost, and additional data.
     * @param paramData The encoded parameters as a bytes array.
     * @return strategy The address of the Hegic option strategy contract.
     * @return amount The amount of the option.
     * @return period The duration of the option period in seconds.
     * @return maxTotalCost The maximum total cost allowed for the option purchase.
     * @return additional Additional data required for the strategy, decoded as bytes array.
     */
    function decodeFromHegic(
        bytes memory paramData
    ) external pure returns (
        IHegicStrategy strategy,
        uint256 amount,
        uint256 period,
        uint256 maxTotalCost,
        bytes[] memory additional
    );

    // EVENTS //

    /**
     * @notice Emitted when a Hegic option position is opened.
     * @dev This event is triggered when a user successfully opens a Hegic option position using this contract.
     * @param buildID The unique identifier for the option position build.
     * @param tokenID The identifier of the newly created Hegic option token.
     * @param strategy The address of the Hegic option strategy contract used for the position.
     * @param holder The address of the user who opened the option position.
     * @param amount The amount of the option that was purchased.
     * @param period The duration of the option period in seconds.
     * @param premium The premium paid for the option.
     */
    event OpenPositionByHegic(
        uint256 indexed buildID,
        uint256 tokenID,
        address strategy,
        address holder,
        uint256 amount,
        uint256 period,
        uint256 premium
    );
}