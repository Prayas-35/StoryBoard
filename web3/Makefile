compile:
	npx hardhat compile

deploy:
	npx hardhat run ignition/modules/deploy.ts --network amoy

verify:
	npx hardhat verify --network amoy 0x4bED669357dB1e44c4C1b81Db0f040FD7301cb28 60 "0xF5E93e4eEDbb1235B0FB200fd77068Cb9938eF4f"

deploy-points:
	npx hardhat run ignition/modules/Points.ts --network amoy

verify-points:
	npx hardhat verify --network amoy 0x943e875aE202A0b7F38D12ded07EA953FAA8b83c