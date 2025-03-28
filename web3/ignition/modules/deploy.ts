import { ethers } from "hardhat";

async function main() {
    // Get the signer
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    // Deploy the contract
    const StoryToken = await ethers.getContractFactory("StoryToken");
    const storyToken = await StoryToken.deploy(deployer.address);

    // Wait for the deployment to complete
    await storyToken.waitForDeployment();

    // Get the deployed contract's address
    const contractAddress = await storyToken.getAddress();
    console.log("storyToken deployed to:", contractAddress);
}

// Proper error handling
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });