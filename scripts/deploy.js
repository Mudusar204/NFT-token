async function main() {
  // const [deployer] = await ethers.getSigners();

  // console.log(deployer,"Deploying contracts with the account:", deployer.address);

  const token = await ethers.deployContract("NFT");

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
  
  