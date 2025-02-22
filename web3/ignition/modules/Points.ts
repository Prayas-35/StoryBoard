import { ethers } from "hardhat";

async function main() {
    // Get the ContractFactory for the contract
    console.log("Deploying PointToken...");
    const PointToken = await ethers.deployContract("StoryTokenFactory");

    // console.log("Deploying PointToken...");

    // Wait for the deployment to complete
    await PointToken.waitForDeployment();

    // Get the deployed contract's address
    const contractAddress = await PointToken.getAddress();
    console.log("PointToken deployed to:", contractAddress);
}

// Proper error handling
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });