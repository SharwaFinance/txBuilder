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

import {IPoolFactory, UD60x18} from "./IPoolFactory.sol";

interface ITxBuilderOpenPremia {

    // OWNER FUNCTIONS //

    /**
     * @dev This external function `setReferrer` provides the ability to set a new referrer.
     *
     * @param newReferrer The address of the new referrer to be set as the current referrer.
     *                    Only the owner of the contract has the right to modify this parameter.
     */
    function setReferrer(address newReferrer) external;

    // PURE FUNCTIONS //

    /**
     * @dev This external function `encodeFromPremia` takes specific parameters related to a Premia Finance transaction,
     * including the `vaultAddress`, `poolKey`, `size`, `isBuy`, and `premiumLimit`, and encodes them into a byte array.
     * The resulting encoded data can be used to pass Premia Finance transaction details between contracts or external systems.
     *
     * @param vaultAddress The address of the underwriter vault involved in the Premia Finance transaction.
     * @param poolKey The structured PoolKey representing the type of option pool associated with the transaction.
     * @param size The size of the transaction, represented by the UD60x18 data type.
     * @param isBuy A boolean indicating whether the transaction is a buy (true) or sell (false).
     * @param premiumLimit The limit on the premium associated with the transaction.
     * @return paramData The encoded byte array representing the Premia Finance transaction details.
     */
    function encodeFromPremia(
        address vaultAddress,
        IPoolFactory.PoolKey calldata poolKey,
        UD60x18 size,
        bool isBuy,
        uint256 premiumLimit
    ) external pure returns (bytes memory paramData);

    /**
     * @dev This public function `decodeFromPremia` takes an encoded byte array containing Premia Finance transaction details
     * and decodes it into structured parameters. This allows contracts to interpret and use Premia Finance transaction
     * details encoded in external systems or passed as data.
     *
     * @param paramData The encoded byte array containing Premia Finance transaction details.
     * @return vaultAddress The address of the underwriter vault involved in the Premia Finance transaction.
     * @return poolKey The structured PoolKey representing the type of option pool associated with the transaction.
     * @return size The size of the transaction, represented by the UD60x18 data type.
     * @return isBuy A boolean indicating whether the transaction is a buy (true) or sell (false).
     * @return premiumLimit The limit on the premium associated with the transaction.
     */
    function decodeFromPremia(
        bytes memory paramData
    ) external pure returns (
        address vaultAddress,
        IPoolFactory.PoolKey calldata poolKey,
        UD60x18 size,
        bool isBuy,
        uint256 premiumLimit
    );

    // EVENTS //

    /**
     * @notice Emitted to signify the successful opening of a position by interacting with the Premia Finance protocol.
     * @dev This event, `OpenPositionByPremia`, provides detailed information about the opened position, including
     * the unique identifier for the transaction build (`buildID`), the underwriter vault address (`vaultAddress`),
     * the collateral token used in the position (`collateralToken`), the user who initiated the transaction (`user`),
     * the option pool key (`poolKey`), the size of the transaction (`size`), whether it is a buy or sell transaction (`isBuy`),
     * the premium limit associated with the transaction (`premiumLimit`), and the referrer address (`referrer`), if any.
     *
     * @param buildID The unique identifier for the transaction build associated with the opened position.
     * @param vaultAddress The address of the underwriter vault involved in the Premia Finance transaction.
     * @param collateralToken The address of the collateral token used in the opened position.
     * @param user The address of the user who initiated the transaction and opened the position.
     * @param poolKey The structured PoolKey representing the type of option pool associated with the opened position.
     * @param size The size of the transaction, represented by the UD60x18 data type.
     * @param isBuy A boolean indicating whether the transaction is a buy (true) or sell (false).
     * @param premiumLimit The limit on the premium associated with the opened position.
     * @param referrer The address of the referrer, if any, associated with the user who initiated the transaction.
     */
    event OpenPositionByPremia(
        uint256 indexed buildID,
        address vaultAddress,
        address collateralToken,
        address user,
        IPoolFactory.PoolKey poolKey,
        UD60x18 size,
        bool isBuy,
        uint256 premiumLimit,
        address referrer
    );
}