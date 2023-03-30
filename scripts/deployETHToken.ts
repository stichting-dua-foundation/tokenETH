import { ethers } from "hardhat";
import hre from "hardhat";

async function main() {
  // We get the token contract to deploy
  const DUAToken = await ethers.getContractFactory(
    "contracts/ETH_DUAToken.sol:DUAToken"
  );
  
  const [superAdmin] = await ethers.getSigners();

  const name = "DUA";
  const symbol = "DUA";
  
  // input these addresses
  const admin = "0x0"
  const minter = "0x0"
  const burner = "0x0"
  const cap = 1000000000;
  const capWei = ethers.utils.parseEther(cap.toString());

  // const deployArgs = [name, symbol, admin, minter, burner, capWei]; PROD DEPLOY
  const deployArgs = [
    name,
    symbol,
    capWei, superAdmin.address,
    superAdmin.address,
    superAdmin.address
  ];

  const DToken = await DUAToken.deploy(...deployArgs);

  await DToken.deployed();
  const DTokenAddr = DToken.address;
  console.log("DUAToken deployed to:", DToken.address);
  if (hre.network.name !== "hardhat") {
    await timeout(10000);
    await hre.run("verify:verify", {
      address: DTokenAddr,
      contract: "contracts/ETH_DUAToken.sol:DUAToken",
      constructorArguments: deployArgs,
    });
  }

  function timeout(ms: number) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
