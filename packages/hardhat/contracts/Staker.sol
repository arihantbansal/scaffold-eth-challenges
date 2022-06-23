// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    mapping(address => uint256) public balances;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 72 hours;
    bool public openForWithdraw = false;

    event Stake(address, uint256);

    modifier claimDeadlineReached() {
        require(block.timestamp > deadline, "Deadline has not been reached");
        _;
    }

    modifier notCompleted() {
        bool completed = exampleExternalContract.completed();
        require(!completed, "Stake already completed!");
        _;
    }

    modifier withdrawAllowed() {
        require(openForWithdraw, "Withdrawal is not allowed");
        _;
    }

    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    function stake() public payable {
        require(msg.value > 0, "Please stake some ether");
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    function execute() public claimDeadlineReached notCompleted {
        if (address(this).balance > threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) return 0;
        return deadline - block.timestamp;
    }

    function withdraw() public withdrawAllowed notCompleted {
        payable(msg.sender).transfer(balances[msg.sender]);
    }

    // Add the `receive()` special function that receives eth and calls stake()

    receive() external payable {
        stake();
    }
}
