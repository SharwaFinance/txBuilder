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
import {ITxBuilderOpenPremia, IPoolFactory, UD60x18} from "./ITxBuilderOpenPremia.sol";
import {IUnderwriterVault} from "./IUnderwriterVault.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

/**
 * @title Premia Finance Transaction Builder - Open Position
 * @author 0nika0
 * @notice A contract facilitating the opening of positions on the Premia Finance protocol. 
 *         It provides functions to calculate transaction amounts, process transactions, and manage referrers.
 */
contract TxBuilderOpenPremia is BaseTxBuilderOpen, ITxBuilderOpenPremia, ERC1155Holder {

    IPoolFactory public poolFactory;

    address public referrer;

    constructor(
        IPoolFactory _poolFactory,
        address _referrer
    ) {
        poolFactory = _poolFactory;
        referrer = _referrer;
    }

    // OWNER FUNCTIONS //

    /**
     * @dev See {ITxBuilderOpenPremia-setReferrer}.
     */
    function setReferrer(address newReferrer) external onlyOwner {
        referrer = newReferrer;
    }

    // PUBLIC FUNCTIONS //  

    /**
     * @dev This public view function `calculateAmount` decodes the provided parameters to extract information
     * necessary for calculating the amount involved in a particular transaction. It specifically focuses on
     * decoding parameters related to Premia Finance, extracting details such as the `poolKey` (representing the
     * type of option pool), and the `premiumLimit` associated with the transaction.
     *
     * @param parameters Encoded parameters containing Premia Finance operation details.
     * @return token The address of the token involved in the transaction, determined by the option pool's base or quote asset.
     * @return amount The total amount associated with the transaction, specifically the `premiumLimit` retrieved from the parameters.
     */
    function calculateAmount(
        bytes memory parameters
    ) public view override returns (
        address token,
        uint256 amount
    ) {
        (
            ,
            IPoolFactory.PoolKey memory poolKey,
            ,
            ,
            uint256 premiumLimit
        ) = decodeFromPremia(parameters);

        amount = premiumLimit;
        token = poolKey.isCallPool ? poolKey.base : poolKey.quote;
    } 

    // INTERNAL FUNCTIONS //    

    /**
     * @dev This internal function `_processTx` is responsible for processing a transaction related to Premia Finance.
     * It decodes the provided parameters to extract information such as the `vaultAddress`, `poolKey`, `size`,
     * `isBuy`, and `premiumLimit`. Additionally, it calculates the amount and token involved in the transaction
     * using the `calculateAmount` function. Subsequently, the function approves the required tokens, initiates a trade
     * on the underwriter vault, transfers tokens and pool tokens back to the user, and emits an event to signify the
     * opening of a position by Premia Finance.
     *
     * @param parameters Encoded parameters containing Premia Finance operation details.
     * @param buildID Identifier for the build associated with the transaction.
     * @param user The address of the user initiating the transaction.
     */
    function _processTx(
        bytes memory parameters, 
        uint256 buildID,
        address user
    ) internal override {
        (
            address vaultAddress,
            IPoolFactory.PoolKey memory poolKey,
            UD60x18 size,
            bool isBuy,
            uint256 premiumLimit
        ) = decodeFromPremia(parameters);
        
        (address token, uint256 premia) = calculateAmount(parameters);
        
        (address poolAddress,) = poolFactory.getPoolAddress(poolKey);

        ERC20(token).approve(vaultAddress, premia);
        
        IUnderwriterVault(vaultAddress).trade(
            poolKey,
            size,
            isBuy,
            premiumLimit,
            referrer
        );

        uint256 id = isBuy ? 1 : 0; 

        uint256 balancePoolTokens = ERC1155(poolAddress).balanceOf(user, id);
        
        ERC1155(poolAddress).safeTransferFrom(address(this), user, id, balancePoolTokens, "0x0");
        ERC20(token).transfer(user, ERC20(token).balanceOf(address(this)));
        
        emit OpenPositionByPremia(buildID, vaultAddress, token, user, poolKey, size, isBuy, premiumLimit, referrer);
    }

    // PURE FUNCTIONS //

    /**
     * @dev See {ITxBuilderOpenPremia-encodeFromPremia}.
     */
    function encodeFromPremia(
        address vaultAddress,
        IPoolFactory.PoolKey calldata poolKey,
        UD60x18 size,
        bool isBuy,
        uint256 premiumLimit
    ) external pure returns (bytes memory paramData) {
        return abi.encode(vaultAddress, poolKey, size, isBuy, premiumLimit);
    }

    /**
     * @dev See {ITxBuilderOpenPremia-decodeFromPremia}.
     */
    function decodeFromPremia(
        bytes memory paramData
    ) public pure returns (
        address vaultAddress,
        IPoolFactory.PoolKey memory poolKey,
        UD60x18 size,
        bool isBuy,
        uint256 premiumLimit
    ) {
        (
            vaultAddress,
            poolKey,
            size,
            isBuy,
            premiumLimit
        ) = abi.decode(paramData, (
            address,
            IPoolFactory.PoolKey,
            UD60x18,
            bool,
            uint256
        ));
    }
}
