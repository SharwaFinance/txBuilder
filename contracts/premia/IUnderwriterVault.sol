// SPDX-License-Identifier: LGPL-3.0-or-later
// For terms and conditions regarding commercial use please see https://license.premia.blue
pragma solidity 0.8.19;

import {IPoolFactory, UD60x18} from "./ITxBuilderOpenPremia.sol";

interface IUnderwriterVault {
    function trade(
        IPoolFactory.PoolKey calldata poolKey,
        UD60x18 size,
        bool isBuy,
        uint256 premiumLimit,
        address referrer
    ) external;
}
