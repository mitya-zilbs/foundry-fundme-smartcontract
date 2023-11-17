// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {Test, console} from "forge-std/Test.sol"; //Test says contract is a test
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
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

    function testMinimumDollar() public {
        assertEq(fundMe.minimumUsd(), 5e18); //checks if equal to using function from FundMe
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEth() public {
        vm.expectRevert(); //expects a revert instead of starting broadcast
        fundMe.fund(); //reverts if fund < minimum
    }

    modifier funded() {
        vm.prank(USER); //sends a fake transaction address
        fundMe.fund{value: SEND_VALUE}();
        _; //continue
    }

    function testFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE); //tests if index correctly tracks address to amount funded
    }

    function testAddsFunderToArray() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER); //checks if you can get i from array of funders
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw(); //expects revert if not owner tries to withdraw
    }

    function testWithdrawSingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance; //gets owner's balance
        uint256 startingfundMeBalance = address(fundMe).balance; //gets fundMe balance

        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE); //sets fake gas cost
        vm.prank(fundMe.getOwner()); //pretends to be owner
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingfundMeBalance = address(fundMe).balance;
        assertEq(endingfundMeBalance, 0); //checks if end balance is 0
        assertEq(
            startingfundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        ); //asserts fundMe balance was deposited to owner
    }

    function testWithdrawMultipleFunders() public funded {
        uint160 numberFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberFunders; i++) {
            hoax(address(i), SEND_VALUE); //combines vm.prank and deal
            fundMe.fund{value: SEND_VALUE}(); //funds contract
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingfundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank(); //pretends to withdraw as owner

        assert(address(fundMe).balance == 0);
        assert(
            startingfundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        ); //checks if amount withdrawn added to wallet
    }
}
