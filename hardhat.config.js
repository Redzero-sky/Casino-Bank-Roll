require("@nomicfoundation/hardhat-toolbox");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html

require('dotenv').config();

const { PRIVATE_KEY, INFURA_ID } = process.env;
let hardhatConfig = {}

module.exports = {
   defaultNetwork: "bsctestnet",
   networks: {
      hardhat: hardhatConfig,
      goerli: {
         url: "https://goerli.infura.io/v3/" + INFURA_ID,
         accounts: [`0x${PRIVATE_KEY}`]
      },
      bsctestnet: {
         url: "https://data-seed-prebsc-1-s1.binance.org:8545",
         accounts: [`0x${PRIVATE_KEY}`]
      }
   },
   solidity: {
      version: "0.8.9",
      settings: {
         optimizer: {
            enabled: true,
            runs: 200,
         }
      }
   },
   etherscan: {
      apiKey: "S1VH5HN4RW22314GI9APVKVFIJ36IH5SXV"
      // apiKey: "EFJ9UHMVW1FG7M99ENEHYH2QJ6AH489JMI" // BSCSCAN API KEY
      // "S1VH5HN4RW22314GI9APVKVFIJ36IH5SXV" // ETHERSCAN API KEY
   },
   paths: {
     sources: "./contracts",
     tests: "./test",
     cache: "./cache",
     artifacts: "./artifacts"
   },
   mocha: {
     timeout: 20000
   }
}