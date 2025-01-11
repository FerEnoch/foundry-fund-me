// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FundMe} from "@/src/FundMe.sol";
import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundfundMe(address mostRecentDeployedAddress) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedAddress)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();

        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentFundMeDeploy = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundfundMe(mostRecentFundMeDeploy);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentDeployedAddress) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedAddress)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentFundMeDeploy = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostRecentFundMeDeploy);
        vm.stopBroadcast();
    }
}
