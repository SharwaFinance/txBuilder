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

interface ITxBuilder {
    // STRUCTS //

    /**
     * @title Module
     * @dev A structure representing a modular component.
     * 
     * This structure is used to store information about a modular component, including its address and a human-readable name.
     */
    struct Module {
        address moduleAddress; // The address of the module component.
        string name;           // A human-readable name for the module.
    }

    // OWNER FUNCTIONS //

    /**
     * @notice Set the address of the Exchanger contract.
     * @dev This external function allows the contract owner to set the address of the Exchanger contract.
     * @param exchangerAddress The address of the Exchanger contract.
     */
    function setExchanger(address exchangerAddress) external;

    /**
     * @notice Set a module at a specific index.
     * @dev This external function allows the contract owner to set a module's data at a specific index.
     * @param index The index at which to set the module.
     * @param modData The module data to set.
     */
    function setModule(uint256 index, Module calldata modData) external;

    /**
     * @notice Approve the spending of a specified amount of tokens by a given address.
     * @dev This external function allows the contract owner to approve the spending of a specified amount of tokens by a specific address.
     * @param token The address of the token contract.
     * @param to The address that will be approved to spend the tokens.
     * @param amount The amount of tokens to approve for spending.
     */
    function allApprove(address token, address to, uint256 amount) external;

    /**
     * @notice Withdraw Ether (ETH) to a specified user address.
     * @dev This external function allows the contract owner to withdraw Ether (ETH) to a specified user address.
     * @param user The address of the user to receive the ETH.
     * @param amount The amount of ETH to withdraw.
     */
    function withdrawETH(address user, uint256 amount) external;

    /**
     * @notice Withdraw ERC20 tokens to a specified user address.
     * @dev This external function allows the contract owner to withdraw ERC20 tokens to a specified user address.
     * @param token The address of the ERC20 token contract.
     * @param user The address of the user to receive the tokens.
     * @param amount The amount of tokens to withdraw.
     */
    function withdrawERC20(address token, address user, uint256 amount) external;

    // EXTERNAL FUNCTIONS //

    /**
     * @notice Consolidate and execute multiple transactions in a single call.
     * @dev This external function allows users to consolidate and execute multiple transactions across different modules in a single call. 
     * It takes an array of modules, parameters, and swap data, and executes the transactions sequentially. 
     * The function ensures that the lengths of the arrays are equal and validates the required message value for each swap.
     * @param moduleArray An array of Module structs representing the modules to interact with.
     * @param parametersArray An array of encoded parameters for each module's transaction.
     * @param swapDataArray An array of encoded swap data for each module's transaction.
     * @param productType The type of product or operation being performed.
     */
    function consolidationOfTransactions(
        Module[] memory moduleArray, 
        bytes[] memory parametersArray,
        bytes[] memory swapDataArray,  
        uint256 productType
    ) external payable;

    // EVENTS //

    /**
     * @dev An event emitted when a build or product is created.
     * 
     * This event is triggered when a user creates a new build or product, and it provides information about the build ID,
     * the user who created it, and the product type associated with the build.
     * 
     * @param buildID The unique identifier for the created build.
     * @param user The address of the user who created the build.
     * @param productType The type of product associated with the build.
     */
    event CreateBuild(
        uint256 buildID,
        address indexed user,
        uint256 productType
    );

}