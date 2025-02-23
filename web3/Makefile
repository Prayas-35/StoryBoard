compile:
	npx hardhat compile

deploy:
	npx hardhat run ignition/modules/deploy.ts --network amoy

verify:
	npx hardhat verify --network amoy 0x6B3c6278fE6DE550F2be9e69C71D0B15F019156D 60 "0xF5E93e4eEDbb1235B0FB200fd77068Cb9938eF4f"

deploy-points:
	npx hardhat run ignition/modules/Points.ts --network amoy

verify-points:
	npx hardhat verify --network amoy 0x943e875aE202A0b7F38D12ded07EA953FAA8b83c