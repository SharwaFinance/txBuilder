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
import {IHegicStrategy} from "./IHegicStrategy.sol";
import {IPositionsManager} from "./IPositionsManager.sol";
import {IProxySeller} from "./IProxySeller.sol";
import {ITxBuilderOpenHegic} from "./ITxBuilderOpenHegic.sol";

/**
 * @title Transaction Builder for Opening Hegic Option Positions
 * @author 0nika0
 * @notice This contract facilitates the opening of Hegic option positions using predefined parameters.
 */
contract TxBuilderOpenHegic is BaseTxBuilderOpen, ITxBuilderOpenHegic {

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

    // OWNER FUNCTIONS //

    /**
     * @dev See {ITxBuilderOpenHegic-setReferrer}.
     */
    function setReferrer(address newReferrer) external onlyOwner {
        referrer = newReferrer;
    }

    // EXTERNAL FUNCTIONS //  

    /**
     * @dev See {ITxBuilderOpenHegic-allApprove}.
     */
    function allApprove() external {
        ERC20(usdc).approve(proxySeller, type(uint256).max);
    }   

    // PUBLIC FUNCTIONS //  

    /**
     * @notice Calculate the amount of a token based on provided parameters.
     * @dev This public view function calculates the amount of a token based on a set of input parameters. 
     * It decodes the parameters, retrieves the necessary information from a Hegic strategy, 
     * calculates the premium amount from positive PNL (Profit and Loss), 
     * and ensures it does not exceed the maximum total cost.
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

    /**
     * @notice Process a transaction for opening a Hegic option position.
     * @dev This internal function processes a transaction for opening a Hegic option position based on provided parameters. 
     * It decodes the parameters to extract strategy, amount, period, additional data, and premium. 
     * It then performs the necessary actions to create and transfer the option token to the user.
     * @param parameters The encoded parameters for opening the option position.
     * @param buildID The unique identifier for the option position build.
     * @param user The address of the user who is opening the option position.
     */
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

    /**
     * @dev See {ITxBuilderOpenHegic-encodeFromHegic}.
     */
    function encodeFromHegic(
        IHegicStrategy strategy,
        uint256 amount,
        uint256 period,
        uint256 maxTotalCost,
        bytes[] memory additional
    ) external pure returns (bytes memory paramData) {
        return abi.encode(strategy, amount, period, maxTotalCost, additional);
    }

    /**
     * @dev See {ITxBuilderOpenHegic-decodeFromHegic}.
     */
    function decodeFromHegic(
        bytes memory paramData
    ) public pure returns (
        IHegicStrategy strategy,
        uint256 amount,
        uint256 period,
        uint256 maxTotalCost,
        bytes[] memory additional
    ) {
        (
            strategy,
            amount,
            period,
            maxTotalCost,
            additional
        ) = abi.decode(paramData, (
            IHegicStrategy,
            uint256,
            uint256,
            uint256,
            bytes[]
        ));
    }


}
