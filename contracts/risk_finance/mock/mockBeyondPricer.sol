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

import {ITypes} from "../ITypes.sol";

contract MockBeyondPricer {
	uint256 public localTotalPremium;
	int256 public localTotalDelta;
	uint256 public localTotalFees;

	function setLocalData(uint256 totalPremium, int256 totalDelta, uint256 totalFees) external {
		localTotalPremium = totalPremium;
		localTotalDelta = totalDelta;
		localTotalFees = totalFees;
	}

	function quoteOptionPrice(
		ITypes.OptionSeries memory _optionSeries,
		uint256 _amount,
		bool isSell,
		int256 netDhvExposure
	) external view returns (uint256 totalPremium, int256 totalDelta, uint256 totalFees) {
		totalPremium = localTotalPremium;
		totalDelta = localTotalDelta;
		totalFees = localTotalFees;
	}
}
