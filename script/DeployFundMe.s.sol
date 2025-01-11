// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {console} from "forge-std/console.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();

        address uthUsdPriceFeed = helperConfig.activeNetworkConfig();

        // after start broadcasting, It's a real txn!
        vm.startBroadcast();
        FundMe fundMe = new FundMe(uthUsdPriceFeed);
        vm.stopBroadcast();

        return fundMe;
    }

    /* Also: 
    $ forge inspect FundMe storageLayout 

    También:
    $ cast storage <address> <slot:number>
    Where <address> is the address of the deployed contract


    function printStorageData(address _contractAddress) public view {
         for (uint256 i = 0; i < 10; i++) {
             bytes32 value = vm.load(address(_contractAddress), bytes32(i));
             console.log("slot", i, ":");
             console.logBytes32(value);
         }
     }


    function printFirstArrayElement(address _contractAddress) public view {
        bytes32 arrayStorageSlotLength = bytes32(uint256(2));
        bytes32 firstElementStorageSlot = keccak256(
            abi.encode(arrayStorageSlotLength)
        );
        bytes32 value = vm.load(
            address(_contractAddress),
            firstElementStorageSlot
        );
        console.log("first element:");
        console.logBytes32(value);
    }
    */
}
