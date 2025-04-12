compile:
	npx hardhat compile

deploy:
	npx hardhat run ignition/modules/deploy.ts --network eduChain

verify:
	npx hardhat verify --network eduChain 0x518Cccfff4a08886B6ccb65B6aAE83af75Bc20c6 100000000 "0xF5E93e4eEDbb1235B0FB200fd77068Cb9938eF4f"

deploy-points:
	npx hardhat run ignition/modules/Points.ts --network eduChain

verify-points:
	npx hardhat verify --network eduChain 0x4686F60cb05d2CC722EA82057211398bF6BdCD84