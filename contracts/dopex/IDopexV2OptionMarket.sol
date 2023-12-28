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

import {IHandler} from "./IHandler.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IDopexV2OptionMarket is IERC721 {
    struct OptionTicks {
        IHandler _handler;
        IUniswapV3Pool pool;
        int24 tickLower;
        int24 tickUpper;
        uint256 liquidityToUse;
    }

    struct OptionParams {
        OptionTicks[] optionTicks;
        int24 tickLower;
        int24 tickUpper;
        uint256 ttl;
        bool isCall;
        uint256 maxCostAllowance;
    }

    function mintOption(OptionParams calldata _params) external;

    function optionIds() external view returns (uint256);
    
    function getPricePerCallAssetViaTick(
        IUniswapV3Pool _pool,
        int24 _tick
    ) external view returns (uint256);

    function getCurrentPricePerCallAsset(
        IUniswapV3Pool _pool
    ) external view returns (uint256);

    function getPremiumAmount(
        bool isPut,
        uint expiry,
        uint strike,
        uint lastPrice,
        uint baseIv,
        uint amount
    ) external view returns (uint256);

    function getFee(
        uint256 amount,
        uint256 iv,
        uint256 premium
    ) external view returns (uint256);

    function ttlToVol(uint256 ttl) external view returns(uint256);
}