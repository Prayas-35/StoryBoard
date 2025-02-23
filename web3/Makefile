compile:
	npx hardhat compile

deploy:
	npx hardhat run ignition/modules/deploy.ts --network amoy

verify:
	npx hardhat verify --network amoy 0xf52ddC3c0b03543AE68E638aB7E0E6AC13f77d67 604800 "0xF5E93e4eEDbb1235B0FB200fd77068Cb9938eF4f"

deploy-points:
	npx hardhat run ignition/modules/Points.ts --network amoy

verify-points:
	npx hardhat verify --network amoy 0x943e875aE202A0b7F38D12ded07EA953FAA8b83c