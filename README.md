# Smart Contract Funding Application
This project is a funding application written in Solidity using the Foundry framework. 
It defines a smart contract named FundMe on the Ethereum blockchain, and this contract allows users to fund it with Ether (ETH), with each transaction checked to ensure it meets a minimum USD value. The contract uses the Chainlink AggregatorV3Interface for ETH to USD conversion rates. The contract owner, set at deployment, can withdraw all funds, which also resets all contributors' funded amounts to zero. This contract can serve as a basis for crowdfunding or donation-based projects on the Ethereum blockchain, or as a simple and secure store of value on-chain.

## Contents
<b>/src</b> 
<ol>
<li>FundMe.sol - the funding contract </li>
<li>PriceConverter.sol - a price converter contract that uses a Chainlink aggregator contract to get price data </li>
</ol>

<b>/script</b>
<ol>
<li>DeployFundMe.s.sol - a deployment script for deploying the FundMe contract</li>
<li>HelperConfig.s.sol - a script for configuring which network to connect to based on the chain id used, can be changed to add additional networks</li>
<li>Interactions.s.sol - a script for interacting with the deployed FundMe contract that can fund or withdraw from the contract</li>
</ol>

<b>/test</b>
<ol>
<li>/mocks - a folder containing a mock price aggregator for local testing on Anvil</li>
<li>FundMeTest.t.sol - contains tests for the FundMe contract to ensure it is working correctly</li>
<li>InteractionsTest.t.sol - contains tests for the Interactions script to ensure funding and withdrawal work correctly</li>
</ol>

<b>Imported Items</b>
<ol>
<li>chainlink-brownie-contracts - a Chainlink repo that provides an aggregator tool that gets external price data</li>
<li>foundry-devops - a DevOps tool for easier functionality access</li>
<li>forge-std - a Foundry tool for creating Scripts and Tests</li>
</ol>

## Usage
This contract can be used locally as well on any EVM based chain to create a contract, collect 
funds, and then withdraw collected funds. 

## Credits
This project was modeled after a tutorial by Patrick Collins of Cyfrin. 

## License
MIT 

