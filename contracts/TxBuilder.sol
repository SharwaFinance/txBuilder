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

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IBaseTxBuilderOpen} from "./IBaseTxBuilderOpen.sol";
import {IExchanger} from "./exchanger/IExchanger.sol";
import {ITxBuilder} from "./ITxBuilder.sol";
import {IBuildManager} from "./IBuildManager.sol";

/**
 * @title TxBuilder
 * @author 0nika0
 * @dev This contract manages the consolidation of transactions and products, allowing users to create and interact with modules.
 * It enables users to consolidate multiple transactions into one and create products through modules.
 */
contract TxBuilder is Ownable, ITxBuilder {

    IExchanger public exchanger;
    IBuildManager public buildManager;

    mapping(uint256 => Module) public module;

    constructor(
        address _exchanger,
        address _buildManager
    ) {
        exchanger = IExchanger(_exchanger);
        buildManager = IBuildManager(_buildManager);
    }

    // OWNER FUNCTIONS //

    function setExchanger(address exchangerAddress) external onlyOwner {
        exchanger = IExchanger(exchangerAddress);
    }

    function setModule(uint256 index, Module calldata modData) external onlyOwner {
        module[index] = modData;
    }

    function withdrawETH(address user, uint256 amount) external onlyOwner {
        payable(user).transfer(amount);
    }

    function withdrawERC20(address token, address user, uint256 amount) external onlyOwner {
        ERC20(token).transfer(user, amount);
    }

    // EXTERNAL FUNCTIONS //

    function consolidationOfTransactions(
        Module[] memory moduleArray, 
        bytes[] memory parametersArray,
        bytes[] memory swapDataArray,  
        uint256 productType
    ) external payable {
        require(moduleArray.length == parametersArray.length && parametersArray.length == swapDataArray.length, "arrays not equal");

        uint256 buildID = buildManager.getBuildID();
        
        exchanger.checkMsgValue(swapDataArray, msg.value);

        for (uint i = 0; i < moduleArray.length; i++) {
            uint256 msgValue = exchanger.calculateMsgValue(swapDataArray[i]);

            if (msgValue == 0) {
                exchanger.swap(swapDataArray[i], msg.sender, moduleArray[i].moduleAddress);
            } else {
                exchanger.swap{ value: msgValue }(swapDataArray[i], msg.sender, moduleArray[i].moduleAddress);
            }    

            IBaseTxBuilderOpen(moduleArray[i].moduleAddress).processTx(parametersArray[i], buildID, msg.sender);
        }

        emit CreateBuild(buildID, msg.sender, productType);
        
        buildManager.increaseBuildID();
    }
}
