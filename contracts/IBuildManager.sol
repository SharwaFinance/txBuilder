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

interface IBuildManager {
    // OWNER FUNCTIONS //

    /**
     * @dev Allows the owner to set the address of the transaction builder contract.
     * @param newTxBuilder The new address of the transaction builder contract.
     */
    function setTxBuilder(address newTxBuilder) external;

    // VIEW FUNCTIONS //

    /**
     * @dev Retrieves the current build ID.
     * @return uint256 The current build ID.
     */
    function getBuildID() external view returns (uint256);

    // EXTERNAL FUNCTIONS //

    /**
     * @dev Increments the build ID externally, allowing the designated transaction builder contract to update it.
     *      Requires the caller to be the set transaction builder contract to have access rights.
     */
    function increaseBuildID() external;
}