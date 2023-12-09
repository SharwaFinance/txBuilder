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

    // EXTERNAL FUNCTIONS //  

    function allApprove() external;

    // PURE FUNCTIONS //

    function encodeFromDopex(
        IDopexV2OptionMarket.OptionParams calldata _params
    ) external pure returns (bytes memory paramData);

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