// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";

/**
 * FundToken代币，继承ERC20协议
 * 1. 让FundMe的参与者，基于 mapping 来领取相应数量的通证
 * 2. 让FundMe的参与者，transfer 通证
 * 3. 在使用完成以后，需要burn 通证
 * @title 
 * @author 
 * @notice 
 */
contract FundTokenERC20 is ERC20 {
    FundMe fundme;

    /**
     * 继承ERC20，需要传入ERC20构造器的参数
     * @param fundmeAddr 
     */
    constructor(address fundmeAddr) ERC20("FundTokenERC20", "FT") {
        // 使用FundMe合约地址初始化一个FundMe对象
        fundme = FundMe(fundmeAddr);
    }

    /**
     * 挖矿，发行
     * 使用FundMe的账户余额兑换代币
     * @param amtToMint 挖矿金额
     */
    function mint(uint256 amtToMint) public {
        // FundMe账户余额大于兑换代币数量
        require(
            fundme.fundersToAmount(msg.sender) >= amtToMint,
            "you  cannot mint this many tokens"
        );
        // 受益人提取后，投资人才能兑换代币
        require(fundme.getFundSuccess(), "the fundme is not completed yet.");
        _mint(msg.sender, amtToMint);
        fundme.setFunderToAmt(
            msg.sender,
            fundme.fundersToAmount(msg.sender) - amtToMint
        );
    }

    function claim(uint256 amtToClaim) public {
        require(
            balanceOf(msg.sender) >= amtToClaim,
            "you do not have enough ERC20 tokens"
        );
        require(fundme.getFundSuccess(), "the fundme is not completed yet.");
        _burn(msg.sender, amtToClaim);
    }
}
