const { network } = require("hardhat")
const { developmentChains, CONFIRMATIONS, networkConfig, LOCK_TIME } = require("../helper-hardhat-config")

// function deployFunction() {
//     console.log("this is a deploy function")
// }
// module.exports.default=deployFunction
// module.exports= async(hre) => {
//     const getNamdeAccounts = hre.getNamdeAccounts
//     const deployments = hre.deployments
//     console.log("this is a deploy function")
// }

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { firstAccount } = await getNamedAccounts()
    const { deploy } = deployments

    let confirmations
    if (developmentChains.includes(network.name)) {
        const mockV3Aggregator = await deployments.get("MockV3Aggregator")
        dataFeedAddr = mockV3Aggregator.address
        confirmations = 0
    } else {
        dataFeedAddr = networkConfig[network.config.chainId].ethUsdDataFeed
        confirmations = CONFIRMATIONS
    }


    const fundMe = await deploy("FundMe", {
        from: firstAccount,
        args: [LOCK_TIME, dataFeedAddr],
        log: true,
        waitConfirmations: confirmations
    })

    // verify fundMe
    // remove deployments directory or add --reset flag if you redeploy contract
    if (hre.network.config.chainId == 11155111 && process.env.ETHERSCAN_API_KEY) {
        await hre.run("verify:verify", {
            address: fundMe.address,
            constructorArguments: [LOCK_TIME, dataFeedAddr],
        })
    } else {
        console.log("Network is not sepolia, verification skipped...")
    }

}

module.exports.tags = ["all", "fundme"]
