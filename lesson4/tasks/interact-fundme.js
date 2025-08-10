// const { ethers } = require("hardhat")
// const { task } = require("hardhat/config")

task("interact-fundme", "interact with fundme contract")
    .addParam("addr", "fundme contract address")
    .setAction(async (taskArgs, hre) => {
        const fundMeFactory = await ethers.getContractFactory("FundMe")
        const fundMe = fundMeFactory.attach(taskArgs.addr)

        const [firstAcct, secondAcct] = await ethers.getSigners();

        const fundMeTx = await fundMe.fund({ value: ethers.parseEther("0.5") })
        await fundMeTx.wait()

        const balanceOfContract = await ethers.provider.getBalance(fundMe.target)
        console.log(`Balance of the contract is ${balanceOfContract}`);

        const fundMeTxWithSecondAcct = await fundMe.connect(secondAcct).fund({ value: ethers.parseEther("0.5") })
        await fundMeTxWithSecondAcct.wait()

        const balanceOfContractAfter2ndFund = await ethers.provider.getBalance(fundMe.target)
        console.log(`Balance of the contract is ${balanceOfContractAfter2ndFund}`);

        // check mapping 
        const firstAccountbalanceInFundMe = await fundMe.fundersToAmount(firstAcct.address)
        const secondAccountbalanceInFundMe = await fundMe.fundersToAmount(secondAcct.address)
        console.log(`Balance of first account ${firstAcct.address} is ${firstAccountbalanceInFundMe}`)
        console.log(`Balance of second account ${secondAcct.address} is ${secondAccountbalanceInFundMe}`)
    })

module.exports = {}