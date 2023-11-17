// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256; //all uint256 have access to PriceConverter

    uint256 public constant minimumUsd = 5e18; //constant = var doesn't change
    address[] private s_funders;

    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;

    address private immutable owner; //immutable = var not set yet but will only be set once
    AggregatorV3Interface private s_priceFeed; //gets price of eth

    constructor(address priceFeed) {
        owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert FundMe__NotOwner();
        }
        _; //continue with rest of code if require is met
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= minimumUsd,
            "Not enough Eth"
        ); //references function from library
        s_funders.push(msg.sender); //pushes address to s_funders array
        s_addressToAmountFunded[msg.sender] += msg.value; //sender => old amt + new amt
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version(); //returns version of price feed
    }

    function withdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length; //optimizes gas by only calling from storage once instead of multiple times in loop
        for (uint256 i = 0; i < fundersLength; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0; //resets amount s_funders sent to 0
        }
        s_funders = new address[](0); //new s_funders array starting at 0
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); //makes call to msg.sender with value of contract balance
        require(callSuccess, "Call failed");
    }

    receive() external payable {
        //someone sends money to contract without calling fund function
        fund();
    }

    fallback() external payable {
        //someone sends data to contract not associated with any specific function
        fund();
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress]; //maps a funding address to its amount
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index]; //gets index of funders
    }

    function getOwner() external view returns (address) {
        return owner; //gets contract owner
    }
}
