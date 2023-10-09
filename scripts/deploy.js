async function main() {
  // const [deployer] = await ethers.getSigners();

  // console.log(deployer,"Deploying contracts with the account:", deployer.address);

  const token = await ethers.deployContract("ERC721URIStorage");

  console.log(token,"Token address:", await token.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
  /////////////////////token address/////////////////////
// sepolia 0x6Eff936197ad397aE37Fc229B1877c60D0937cd0
// ////////////////////NFT new address 
  // 0x38840074B54f17cEA5B9f90B4e6fc78510c9BEaA
// /////////////////// custom ERC721 token with auction////////////////
  // 0xADeFd083Bd1F404d20Ba12bED9fA48eA7738D5D4
  /////////////////////after uri added//////////////
  // 0x35e43AFd1131a9c61aa5a3F8adc6a1d51aF4e6Fa
  /////////////////////after buy NFT add//////////
  //0xA674032649940ac8a3A4941738fbdDddB3a57B43
  