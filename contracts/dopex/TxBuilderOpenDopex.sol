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
import {IDopexV2OptionMarket} from "./IDopexV2OptionMarket.sol";

/**
 * @title Transaction Builder for Opening Hegic Option Positions
 * @author 0nika0
 * @notice This contract facilitates the opening of Hegic option positions using predefined parameters.
 */
contract TxBuilderOpenDopex is BaseTxBuilderOpen, ITxBuilderOpenDopex {

    address public proxySeller; 
    address public hegicErc721; 
    address public usdc; 
    address public referrer;

    constructor(
        address _proxySeller,
        address _hegicErc721,
        address _usdc,
        address _referrer
    ) {
        proxySeller = _proxySeller;
        hegicErc721 = _hegicErc721;
        usdc = _usdc;
        referrer = _referrer;
    }

    // EXTERNAL FUNCTIONS //  

    function allApprove() external {
        ERC20(usdc).approve(proxySeller, type(uint256).max);
    }   

    // PUBLIC FUNCTIONS //  

    function calculateAmount(
        bytes memory parameters
    ) public view override returns (
        address token,
        uint256 amount
    ) {
        token = usdc;

        (
            IHegicStrategy strategy,
            uint256 amountHegic,
            uint256 period,
            uint256 maxTotalCost,
            bytes[] memory additional
        ) = decodeFromHegic(parameters);

        (, uint128 positivepnl) = strategy.calculateNegativepnlAndPositivepnl(amountHegic, period, additional);

        require(uint256(positivepnl) <= maxTotalCost, "maximum total value exceeded");

        amount = uint256(positivepnl);
    } 

    // INTERNAL FUNCTIONS //    

    function _processTx(
        bytes memory parameters, 
        uint256 buildID,
        address user
    ) internal override {
        (
            IHegicStrategy strategy,
            uint256 amount,
            uint256 period,
            ,
            bytes[] memory additional
        ) = decodeFromHegic(parameters);
        
        (, uint256 premium) = calculateAmount(parameters);
        
        uint256 id = IPositionsManager(hegicErc721).nextTokenId();
        
        IProxySeller(proxySeller).buyWithReferal(
            strategy,
            amount,
            period,
            additional,
            referrer
        );
        
        IPositionsManager(hegicErc721).transferFrom(address(this), user, id);
        
        emit OpenPositionByHegic(buildID, id, address(strategy), user, amount, period, premium);
    }

    // PURE FUNCTIONS //

    function encodeFromDopex(
        IDopexV2OptionMarket.OptionParams calldata params
    ) external pure returns (bytes memory paramData) {
        return abi.encode(params);
    }

    function decodeFromDopex(
        bytes memory paramData
    ) public pure returns (
        IDopexV2OptionMarket.OptionParams calldata params
    ) {
        (
            params
        ) = abi.decode(paramData, (
            IDopexV2OptionMarket.OptionParams
        ));
    }


}
