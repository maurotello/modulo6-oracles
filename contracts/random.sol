// Solidity program to demonstrate on how to generate a random number

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// Creating a contract
contract GeeksForGeeksRandom {
  
    // Initializing the state variable
    uint256 randNonce = 0;

    mapping(address => uint256) balance;

    // Defining a function to generate
    // a random number
    function randMod(uint256 _modulus) public returns (uint256) {
        // increase nonce
        randNonce++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % _modulus;
    }
}
