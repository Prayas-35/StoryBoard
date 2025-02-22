compile:
	npx hardhat compile

deploy:
	npx hardhat run ignition/modules/deploy.ts --network amoy

verify:
	npx hardhat verify --network amoy 0xCB3afF879C019b0916998FE671FEEEF4aeA49E9C 604800 "0xF5E93e4eEDbb1235B0FB200fd77068Cb9938eF4f"

deploy-points:
	npx hardhat run ignition/modules/Points.ts --network amoy

verify-points:
	npx hardhat verify --network amoy 0x4cB490beb0da5538A569526D689710b1C3A74c3C