import { ethers } from "hardhat";

async function main() {
  // Get the ContractFactory for the contract
  const StoryTokenCont = await ethers.getContractFactory("StoryToken");

  console.log("Deploying StoryToken...");
  const Prop = await StoryTokenCont.deploy(100000000, "0xF5E93e4eEDbb1235B0FB200fd77068Cb9938eF4f");

  // Wait for the deployment to complete
  await Prop.waitForDeployment();

  // Get the deployed contract's address
  const contractAddress = await Prop.getAddress();
  console.log("StoryToken deployed to:", contractAddress);
}

// Proper error handling
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
