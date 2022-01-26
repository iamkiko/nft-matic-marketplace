/** @format */

const { expect } = require("chai");
const { ethers } = require("hardhat");

// TODO: Refactor this as TDD/BDD with unit tests
describe("NFT Market", function () {
  it("Should create and execute market sales", async function () {
    // deploy the marketplace
    const Market = await ethers.getContractFactory("NFTMarket"); // we target NFTMarket.sol and assign it to Market
    const market = await Market.deploy();
    await market.deployed();
    const marketAddress = market.address; // get reference from address where it was deployed -> this marketAddress exists in the constructor inside solidity file

    // deploy the NFT contract
    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    const nftContractAddress = nft.address;

    let listingPrice = await market.getListingPrice(); // from NFTMarket.sol
    listingPrice = listingPrice.toString();

    const auctionPrice = ethers.utils.parseUnits("1", "ether"); // allows us to handle larger units instead of gwei

    // create two tokens
    await nft.createToken("https://www.mytokenlocation.com");
    await nft.createToken("https://www.mytokenlocation2.com");

    // put both tokens for sale
    await market.createMarketItem(nftContractAddress, 1, auctionPrice, {
      value: listingPrice,
    });
    await market.createMarketItem(nftContractAddress, 2, auctionPrice, {
      value: listingPrice,
    });

    // get addresses of different users - below we get the reference to the testing accounts with ethers.getSigners();
    const [_, buyerAddress] = await ethers.getSigners(); // _ === seller

    // execute sale of token to another user
    await market
      .connect(buyerAddress)
      .createMarketSale(nftContractAddress, 1, { value: auctionPrice });

    // query for and return the unsold items
    items = await market.fetchMarketItems();
    items = await Promise.all(
      items.map(async (i) => {
        const tokenUri = await nft.tokenURI(i.tokenId);
        let item = {
          price: `${i.price.toString()} gwei`,
          tokenId: i.tokenId.toString(),
          seller: i.seller,
          owner: i.owner,
          tokenUri,
        };
        return item;
      })
    );
    console.log("items: ", items);
  });
});
