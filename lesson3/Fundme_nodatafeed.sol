// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract FundMe {
    address public owner;

    uint256 deploymentTimestamp;
    uint256 lockTime;

    uint256 constant MINIMUM_VALUE = 1 * 10**18; //  1USD
    uint256 constant TARGET = 10 * 10**18; //  10 USD

    mapping(address => uint256) public fundersToAmount;

    address erc20Addr;

    bool public getFundSuccess = false;

    constructor(uint256 _lockTime) {
        // 判断众筹金额是否超过最小值
        lockTime = _lockTime;

        deploymentTimestamp = block.timestamp;

        owner = msg.sender;
    }

    function invest() external payable {
        // 判断投资金额是否超过最小值
        require(convertETHtoUSD(msg.value) >= MINIMUM_VALUE, "Send more ETH");
        // 判断当前时间是否超过众筹时间
        require(
            block.timestamp < deploymentTimestamp + lockTime,
            "window is closed"
        );

        fundersToAmount[msg.sender] = msg.value;
    }

    function getFundedAmtByInvestor() public view returns (uint256) {
        return convertETHtoUSD(fundersToAmount[msg.sender]) / (10**18);
    }

    /**
        * ethAmount的单位是wei
        usd = ethAmount / (10^18) * 
                数据接口返回的单位是10^8

        */
    function convertETHtoUSD(uint256 ethAmount)
        internal
        pure
        returns (uint256)
    {
        // getChainlinkDataFeedLatestAnswer 返回的是int类型，需要转成uint
        uint256 price = uint256(getChainlinkDataFeedLatestAnswer());
        return (ethAmount * price) / (10**8);
    }

    function getFund() external windowClosed onlyOwner {
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
        require(success, "transaction tx is failed");
        fundersToAmount[msg.sender] = 0;
        getFundSuccess = true;
    }

    function refund() external windowClosed {
        require(
            convertETHtoUSD(address(this).balance) < TARGET,
            "Target is reached."
        );
        require(fundersToAmount[msg.sender] != 0, "there is no fund for you");
        bool success;
        (success, ) = payable(msg.sender).call{
            value: fundersToAmount[msg.sender]
        }("");
        require(success, "transaction tx is failed");
        fundersToAmount[msg.sender] = 0;
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public pure returns (int256) {
        return 100000000000;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function getUSDBalance() external view returns (uint256) {
        return convertETHtoUSD(address(this).balance) / (10**18);
    }

    function setFunderToAmt(address funder, uint256 amtToUpdate) external {
        require(
            msg.sender == erc20Addr,
            "you do not have permission to call this function"
        );
        fundersToAmount[funder] = amtToUpdate;
    }

    function setErc20Addr(address _erc20Addr) public onlyOwner {
        erc20Addr = _erc20Addr;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "this function can only be called by owner"
        );
        _;
    }

    modifier windowClosed() {
        require(
            block.timestamp >= deploymentTimestamp + lockTime,
            "window is not closed"
        );
        _;
    }
}
