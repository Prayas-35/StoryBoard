compile:
	npx hardhat compile

deploy:
	npx hardhat run ignition/modules/deploy.ts --network lineaSepolia

verify:
	npx hardhat verify --network lineaSepolia 0x60B543d0835f879F8F7D721Ba45BBb809Bba4a19 "0xF5E93e4eEDbb1235B0FB200fd77068Cb9938eF4f"

deploy-points:
	npx hardhat run ignition/modules/Points.ts --network lineaSepolia

verify-points:
	npx hardhat verify --network lineaSepolia 0x74Ce2e9ef64018a1f7b1A0F035782045d566ef4f