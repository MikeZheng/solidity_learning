
// const { ethers } = require("hardhat")
/**
 * npx hardhat run scripts/deployFundMe.js --network sepolia
 */
async function main() {
    // create factory
    const fundMeFactory = await ethers.getContractFactory("FundMe")
    console.log(`contract is deploying`);

    // deploy contract from factory
    const fundMe = await fundMeFactory.deploy(300)
    await fundMe.waitForDeployment()
    console.log(`contract has been deployed successfully, contract address is ${fundMe.target}`);

    // verify fundme
    if (hre.network.config.chainId == 11155111 && process.env.ETHERSCAN_API_KEY) {
        console.log("Waiting for 5 confirmations")
        await fundMe.deploymentTransaction().wait(5)
        await verifyFundMe(fundMe.target, [300])
    } else {
        console.log("verification skipped..")
    }

    // // init two accouts
    // const [firstAcct, secondAcct] = await ethers.getSigners()
    // console.log(`two accounts are ${firstAcct.address} and ${secondAcct.address}`)

    // // fund contract with first account
    // const fundTx = await fundMe.fund({ value: ethers.parseEther("0.5") })
    // await fundTx.wait()

    // // check balance of the contract
    // const balanceOfContract = await ethers.provider.getBalance(fundMe.target)
    // console.log(`Balance of the contract is ${balanceOfContract}`);

    // // fund contract with second account
    // const fundTxWith2ndAcct = await fundMe.connect(secondAcct).fund({ value: ethers.parseEther("0.5") })
    // await fundTxWith2ndAcct.wait()

    // // check balance of the contract
    // const balanceOfContractAfter2ndFund = await ethers.provider.getBalance(fundMe.target)
    // console.log(`Balance of the contract is ${balanceOfContractAfter2ndFund}`);

    // // check mapping 
    // const firstAcctBalanceInFundMe = await fundMe.fundersToAmount(firstAcct.address)
    // const secondAcctBalanceInFundMe = await fundMe.fundersToAmount(secondAcct.address)
    // console.log(`Balance of first account ${firstAcct.address} is ${firstAcctBalanceInFundMe}`);
    // console.log(`Balance of second account ${secondAcct.address} is ${secondAcctBalanceInFundMe}`);
    
    interactWithFundMe(fundMe);
    
}

async function interactWithFundMe(fundMe) {
    // init two accouts
    const [firstAcct, secondAcct] = await ethers.getSigners()
    console.log(`two accounts are ${firstAcct.address} and ${secondAcct.address}`)

    // fund contract with first account
    const fundTx = await fundMe.fund({ value: ethers.parseEther("0.3") })
    await fundTx.wait()

    // check balance of the contract
    const balanceOfContract = await ethers.provider.getBalance(fundMe.target)
    console.log(`Balance of the contract is ${balanceOfContract}`);

    // fund contract with second account
    const fundTxWith2ndAcct = await fundMe.connect(secondAcct).fund({ value: ethers.parseEther("0.3") })
    await fundTxWith2ndAcct.wait()

    // check balance of the contract
    const balanceOfContractAfter2ndFund = await ethers.provider.getBalance(fundMe.target)
    console.log(`Balance of the contract is ${balanceOfContractAfter2ndFund}`);

    // check mapping 
    const firstAcctBalanceInFundMe = await fundMe.fundersToAmount(firstAcct.address)
    const secondAcctBalanceInFundMe = await fundMe.fundersToAmount(secondAcct.address)
    console.log(`Balance of first account ${firstAcct.address} is ${firstAcctBalanceInFundMe}`);
    console.log(`Balance of second account ${secondAcct.address} is ${secondAcctBalanceInFundMe}`);
}

async function verifyFundMe(fundMeAddr, args) {
    await hre.run("verify:verify", {
        address: fundMeAddr,
        constructorArguments: args,
    });
}

main().then().catch((error) => {
    console.error(error);
    process.exit(1)
})