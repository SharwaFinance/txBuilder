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

import {ICombinedActions} from "./ICombinedActions.sol";
import {ITypes} from "./ITypes.sol";

interface IOptionExchange {
	/**
	 * @notice entry point to the contract for users, takes a queue of actions for both opyn and rysk and executes them sequentially
	 * @param  _operationProcedures an array of actions to be executed sequentially
	 */
	function operate(
		ICombinedActions.OperationProcedures[] memory _operationProcedures
	) external;

	function checkHash(
		ITypes.OptionSeries memory optionSeries,
		uint128 strikeDecimalConverted,
		bool isSell
	) external view returns (bytes32 oHash);

	function getOptionDetails(
		address seriesAddress,
		ITypes.OptionSeries memory optionSeries
	) external view returns (address, ITypes.OptionSeries memory, uint128);
}
