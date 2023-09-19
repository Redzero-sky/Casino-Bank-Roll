require("@nomiclabs/hardhat-ethers");

const hre = require("hardhat");

async function main() {
  // Grab the contract factory 

  const CasinoBankRoll = await ethers.getContractFactory("CasinoBankRoll");
  const casinoBankRoll = await CasinoBankRoll.deploy();
  await casinoBankRoll.deployed();

  console.log("CasinoBankRoll deployed to address::", casinoBankRoll.address);
}

main()
 .then(() => process.exit(0))
 .catch(error => {
   console.error(error);
   process.exit(1);
 });