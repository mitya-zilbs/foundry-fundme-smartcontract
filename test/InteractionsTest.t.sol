// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {Test, console} from "forge-std/Test.sol"; //need to import console
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol"; //installed devops tools from Cyfrin/foundry-devops
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); //makes fake address
    uint256 constant SEND_VALUE = 0.1 ether; //amount to send in test
    uint256 constant STARTING_BALANCE = 10 ether; //gives fake wallet 10 eth
    uint256 constant GAS_PRICE = 1; //give fake gas cost

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); //gives fake wallet starting balance
    }

    function testUserFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe)); //funds FundFundMe with address of FundMe

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe)); //withdraws from FundMe using FundMe address

        assert(address(fundMe).balance == 0); //checks if FundMe balance = 0
    }
}
