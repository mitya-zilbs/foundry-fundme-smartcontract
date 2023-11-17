// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {Script} from "forge-std/Script.sol"; //says this is a deployment script
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        //doesn't deploy since its before vm
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed); //imports price feed address
        vm.stopBroadcast();
        return fundMe;
    }
}
