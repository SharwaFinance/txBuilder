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

import {IDopexV2OptionMarket} from "./IDopexV2OptionMarket.sol";

interface ITxBuilderOpenDopex {

    // ONLY OWNER FUNCTIONS //  

    function allApprove(address token, address dopexV2OptionMarket, uint256 amount) external;

    // PURE FUNCTIONS //

    function encodeFromDopex(
        IDopexV2OptionMarket dopexV2OptionMarket,
        uint256 optionAmount,
        IDopexV2OptionMarket.OptionParams calldata params
    ) external pure returns (bytes memory paramData);

    function decodeFromDopex(
        bytes memory paramData
    ) external pure returns (
        IDopexV2OptionMarket dopexV2OptionMarket,
        uint256 optionAmount,
        IDopexV2OptionMarket.OptionParams calldata params
    );

    // EVENTS //

    event OpenPositionByDopex(
        uint256 indexed buildID,
        address user,
        IDopexV2OptionMarket.OptionParams params,
        uint256 optionAmount,
        uint256 premium
    );
}