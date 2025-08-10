// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    address public owner;

    uint256 deploymentTimestamp;
    uint256 lockTime;

    uint256 constant MINIMUM_VALUE = 1 * 10**18; //  1USD
    uint256 constant TARGET = 10 * 10**18; //  10 USD

    AggregatorV3Interface internal dataFeed;

    mapping(address => uint256) public fundersToAmount;

    bool getFundSuccess = false;

    constructor(uint256 _lockTime) {
        // 判断众筹金额是否超过最小值
        lockTime = _lockTime;

        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        deploymentTimestamp = block.timestamp;

        owner = msg.sender;
    }

    /**
     * 收款
     * 判断投资金额是否超过最小值
     * 判断当前时间是否超过众筹时间
     * 记录投资人和投资时间，只能投资一次。第二次投资会覆盖第一次投资
     */
    function fund() external payable {
        // 判断投资金额是否超过最小值
        require(convertETHtoUSD(msg.value) >= MINIMUM_VALUE, "Send more ETH");
        // 判断当前时间是否超过众筹时间
        require(
            block.timestamp < deploymentTimestamp + lockTime,
            "window is closed"
        );
        // 记录投资人和投资时间
        fundersToAmount[msg.sender] = msg.value;
    }

    /**
     * 获取投资人的投资金额
     */
    function getFundedAmtByInvestor() public view returns (uint256) {
        return fundersToAmount[msg.sender];
    }

    /**
    * ethAmount的单位是wei
    * 数据接口返回的单位是美元*(10^8)
    * usd = ethAmount * 价格 / (10^8) 
    */
    function convertETHtoUSD(uint256 ethAmount)
        internal
        view
        returns (uint256)
    {
        // getChainlinkDataFeedLatestAnswer 返回的是int类型，需要转成uint
        uint256 price = uint256(getChainlinkDataFeedLatestAnswer());
        return (ethAmount * price) / (10**8);
    }

    /**
     * 资金提取
     * 要求：已超过锁定期，只能受益人提取，余额要超过目标金额
     * 
     */
    function getFund() external windowClosed onlyOwner {
        // 余额要超过目标金额
        require(
            convertETHtoUSD(address(this).balance) >= TARGET,
            "Target is not reached."
        );

        // transfer: transfer ETH and revert if tx failed
        // payable(msg.sender).transfer(address(this).balance);

        // send: transfer ETH and return false if failed
        // bool success = payable(msg.sender).send(address(this).balance);
        // require(success, "tx failed");

        // call: transfer ETH with data return value of function and bool
        bool success;
        (success, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        // 要求提取成功
        require(success, "transaction tx is failed");
        // 取款人金额清零
        fundersToAmount[msg.sender] = 0;
        // 修改提取成功标志
        getFundSuccess = true;
    }

    /**
     * 退款
     * 要求：锁定期已结束，合同余额未超过目标金额，退款人账户要有钱
     */
    function refund() external windowClosed {
        require(
            convertETHtoUSD(address(this).balance) < TARGET,
            "Target is reached."
        );
        // 退款人账户要有钱
        require(fundersToAmount[msg.sender] != 0, "there is no fund for you");
        bool success;
        (success, ) = payable(msg.sender).call{
            value: fundersToAmount[msg.sender]
        }("");
        require(success, "transaction tx is failed");
        // 退款成功后，清空退款人余额
        fundersToAmount[msg.sender] = 0;
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    // 
    /**
     * 修改受益人
     * @param newOwner 新受益人
     * 要求：只能是当前受益人执行该交易
     */
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    /**
     * 只能是owner发起
     */
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "this function can only be called by owner"
        );
        _;
    }

    /**
     * 锁定期已结束
     */
    modifier windowClosed() {
        require(
            block.timestamp >= deploymentTimestamp + lockTime,
            "window is not closed"
        );
        _;
    }

    function setFunderToAmt(address funder, uint256 amtToUpdate) external {
        require(msg.sender == erc20Addr, "you do not have permission to call this function");
        fundersToAmount[funder] = amtToUpdate;
    }

    function setErc20Addr(address _erc20Addr) public onlyOwner {
        erc20Addr = _erc20Addr;
    }
}
