import { HardhatUserConfig } from "hardhat/config";
import "dotenv/config";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-verify";

const { RPC_URL_AMOY, PRIVATE_KEY, POLYGONSCAN_API, RPC_URL_LINEA, LINEASCAN_API } = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    amoy: {
      url: RPC_URL_AMOY || "",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
    lineaSepolia: {
      url: `${RPC_URL_LINEA}`,
      accounts: [`${PRIVATE_KEY}`],
      chainId: 59141,
    },
  },
  etherscan: {
    apiKey: {
      polygonAmoy: `${POLYGONSCAN_API}`,
      lineaSepolia: `${LINEASCAN_API}`
    },
    customChains: [
      {
        network: "lineaSepolia",
        chainId: 59141,
        urls: {
          apiURL: `https://api-sepolia.lineascan.build/api`,
          browserURL: "https://sepolia.lineascan.build",
        },
      },
    ],
  },
  sourcify: {
    enabled: true,
  },
};

export default config;
