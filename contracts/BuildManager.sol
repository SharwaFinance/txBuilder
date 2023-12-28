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

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IBuildManager} from "./IBuildManager.sol";

/**
 * @title BuildManager
 * @author 0nika0
 * @dev A contract that manages the build ID generation and assignment for transactions.
 *      It allows the owner to set the transaction builder contract and provides functions
 *      to retrieve the current build ID and increment it externally, ensuring proper access control.
 */
contract BuildManager is Ownable, IBuildManager {

    uint256 private nextBuildID = 1;
    address public txBuilder;

    // OWNER FUNCTIONS //

    function setTxBuilder(address newTxBuilder) external onlyOwner {
        txBuilder = newTxBuilder;
    }

    // VIEW FUNCTIONS //

    function getBuildID() external view returns (uint256) {
        return nextBuildID;
    }

    // EXTERNAL FUNCTIONS //

    function increaseBuildID() external {
        require(msg.sender == txBuilder, "you do not have access rights");
        nextBuildID++;
    }
}
