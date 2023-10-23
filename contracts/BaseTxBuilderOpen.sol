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

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IBaseTxBuilderOpen} from "./IBaseTxBuilderOpen.sol";

/**
 * @title BaseTxBuilderOpen
 * @author 0nika0
 * @notice An abstract base contract for building and processing option transactions.
 * @dev This contract provides the foundational structure for creating and processing option transactions. 
 * It includes functions to handle transaction processing and token amount calculation.
 */
abstract contract BaseTxBuilderOpen is Ownable, IBaseTxBuilderOpen {

    // PUBLIC FUNCTONS //

    /**
     * @dev See {IBaseTxBuilderOpen-calculateAmount}.
     */
    function calculateAmount(
        bytes memory parameters
    ) public view virtual returns (
        address token,
        uint256 amount
    ) {}

    // EXTERNAL FUNCTIONS //

    /**
     * @dev See {IBaseTxBuilderOpen-processTx}.
     */
    function processTx(
        bytes memory parametersArray,
        uint256 buildID,
        address user
    ) external {
        _processTx(parametersArray, buildID, user);
    }

    function onERC721Received(
        address, 
        address, 
        uint256, 
        bytes calldata
    ) external returns(bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    } 

    // INTERNAL FUNCTIONS //

    /**
     * @notice Internal function to process a transaction for opening an option position.
     * @dev This internal function processes a transaction for opening an option position based on the provided parameters.
     * @param parametersArray The encoded parameters for opening the option position.
     * @param buildID The unique identifier for the option position build.
     * @param user The address of the user who is opening the option position.
     */
    function _processTx(
        bytes memory parametersArray,
        uint256 buildID,
        address user
    ) internal virtual {}
}
