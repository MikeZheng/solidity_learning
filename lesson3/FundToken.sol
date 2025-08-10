// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title 代币
 * @author 
 * @notice 
 */
contract FundToken {
    // 代币名称
    string public tokenName;
    // 代币符号
    string public tokenSymbol;
    // 代币供应量
    uint256 public totalSupply;
    // 合约的拥有者
    address public owner;

    // 账本，每个账户的余额
    mapping(address => uint256) public balances;

    /**
     * 构造函数
     * @param _tokenName 代币名称
     * @param _tokenSymbol 代币符号
     */
    constructor(string memory _tokenName, string memory _tokenSymbol) {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        owner = msg.sender;
    }

    /**
     * 挖矿，发行代币
     * @param amountToMint 要发行的数量
     */
    function mint(uint256 amountToMint) public {
        balances[msg.sender] += amountToMint;
        totalSupply += amountToMint;
    }

    /**
     * 转账
     * @param addr 转账目标地址
     * @param amt 金额
     */
    function transfer(address addr, uint256 amt) public {
        require(
            balances[msg.sender] >= amt,
            "you do not have enought balance to transfer."
        );
        balances[msg.sender] -= amt;
        balances[addr] += amt;
    }

    /**
     * 查看账户余额
     * @param addr 账户
     */
    function balanceOf(address addr) public view returns (uint256) {
        return balances[addr];
    }
}
