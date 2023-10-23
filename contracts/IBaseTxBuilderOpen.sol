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


interface IBaseTxBuilderOpen {
    // PUBLIC FUNCTONS //

    /**
     * @notice Calculate the amount of a token based on provided parameters.
     * @dev This function calculates the amount of a token based on a set of input parameters.
     * @param parameters The encoded parameters for the calculation.
     * @return token The address of the token to be calculated.
     * @return amount The calculated amount of the token.
     */
    function calculateAmount(
        bytes memory parameters
    ) external view returns (
        address token,
        uint256 amount
    ); 

     // EXTERNAL FUNCTIONS //

    /**
     * @notice Process a transaction for opening an option position.
     * @dev This function processes a transaction for opening an option position based on the provided parameters.
     * @param parametersArray The encoded parameters for opening the option position.
     * @param buildID The unique identifier for the option position build.
     * @param user The address of the user who is opening the option position.
     */
    function processTx(
        bytes memory parametersArray,
        uint256 buildID,
        address user
    ) external;



}
