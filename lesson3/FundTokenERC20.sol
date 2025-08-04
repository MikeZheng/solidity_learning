// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./Fundme_nodatafeed.sol";

contract FundTokenERC20 is ERC20 {
    FundMe fundme;

    constructor(address fundmeAddr) ERC20("FundTokenERC20", "FT") {
        fundme = FundMe(fundmeAddr);
    }

    function mint(uint256 amtToMint) public {
        require(
            fundme.fundersToAmount(msg.sender) >= amtToMint,
            "you  cannot mint this many tokens"
        );
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
