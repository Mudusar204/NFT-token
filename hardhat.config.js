require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */

const GANACHE_URL = "HTTP://127.0.0.1:7545"; 

const account_Private_Key = "0x7f17bd3339a1d9ec14a97dcce7740e73d0715f4116d7b17186c3ff68c8fc2c7a";
const sepolia_Private_key ="0xb83b48612666c0770f512657df92efa1d62b7690b990236303c6e82ba685f327"
module.exports = {
  solidity: "0.8.19",
  networks: {
    ganache: {
      url: GANACHE_URL,
      accounts: [account_Private_Key],
    },
    sepolia: {
      url: "https://sepolia.infura.io/v3/26865b57594148a68791dfbc1dacde47",
// url:"https://eth-sepolia.g.alchemy.com/v2/k9vlQuyaNHemyeWdVeEXDNFeEdheFW9Z",
      accounts: [sepolia_Private_key]
    }
  },
};
