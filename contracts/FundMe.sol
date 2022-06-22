//i_ - immutable
//const NAME_NAME
//s_ - storage

// Get funds from users
//Withdraw funds
//Set a minimum funding value in USD

// GITHUB ''' solidity...code...''' - formatting

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

//import "./AggregatorV3Interface.sol" //if in the folder

import "./PriceConverter.sol";

//	859637
//with constant

//FOR GAS!!!! constant (ALL_CAPS_WITH_UNDERSCORES), immutable - set one time but outside of the line where they were declared (i_name)
//ERROR

error FundMe__NotOwner(); //2 underscores

contract FundMe {
    using PriceConverter for uint256;

    //uint256 public number;

    uint256 public constant MINIMUM_USD = 50 * 1e18; //18 decimals

    AggregatorV3Interface public priceFeed;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;

    constructor(address priceFeedAddress) {
        //called during the same transaction of deploying
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        //Want to be able to set a minimum amount in USD
        //1. How do we send to the contract
        //number = 5; ORDER OF COMPUTATION MATTERS FOR REVERTING
        //require(msg.value >= 1e18, "Not enough"); //1 ether
        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
            "Not enough"
        ); //msg.value is 18 decimals || msg.value.getConvRate >> getConvRate(msg.value) as it is the 1st argument
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        //require(msg.sender == owner, "Sender is not owner"); // = - set == - check OR USE MODIFIER
        //for loop
        /*starting index; ending index; step amount*/
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //reset the array
        funders = new address[](0);
        //withdraw //function withdraw(){}
        //transfer (error or not)
        //msg.sender = address type
        //payable(msg.sender) = payable address type
        //payable(msg.sender).transfer(address(this).balance);
        //send (boolean) so we do not auto revert
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //requre(sendSuccess, "send failed");
        //call is RECOMMENDED
        (
            bool callSuccess, /*bytes memory dataReturned*/

        ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender is not owner");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _; // doing the rest of the code representation
    }

    //what happens if someone sends ETH straight with no fund call

    // // recieve()
    // receive() external payable {
    //     fund();
    // }

    // // fallback()
    // fallback() external payable {
    //     fund();
    // }

    // //CHEAPER withdraw
    // function cheaperWithdraw() public payable onlyOwner{
    //     address[] memory funders = s_funders;
    //     //mappings can't be in memory
    //     for(uint256 funderIndex = 0; funderIndex < funder.length; funderIndex++) {
    //         address funder = funders[funderIndex];
    //         s_address ToAmountFunded[funder] = 0;
    //     }
    //     s_funders = new address[](0);
    //     (bool success, ) = i_owner.call{value: address(this).balance}("");
    //     require(sucess);
    // }
}
