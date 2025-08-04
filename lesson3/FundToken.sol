// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundToken {
    string public tokenName;
    string public tokenSymbol;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) public balances;

    constructor(string memory _tokenName, string memory _tokenSymbol) {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        owner = msg.sender;
    }

    function mint(uint256 ammountToMint) public {
        balances[msg.sender] += ammountToMint;
        totalSupply += ammountToMint;
    }

    function transfer(address addr, uint256 amt) public {
        require(
            balances[msg.sender] >= amt,
            "you do not have enought balance to transfer."
        );
        balances[msg.sender] -= amt;
        balances[addr] += amt;
    }

    function balanceOf(address addr) public view returns (uint256) {
        return balances[addr];
    }
}
