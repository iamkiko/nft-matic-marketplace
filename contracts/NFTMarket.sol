// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

// NFT Market will inherit from ReentrancyGuard to prevent someone from hitting the contract with multiple requests/transactions (reentrancy attacks)
contract NFTMarket is ReentrancyGuard {
  using Counters for Counters.Counter;
  // Solidity cannot have dynamic length arrays -> need to know the length of []
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

  address payable owner;
  uint256 listingPrice = 0.1 ether;

  constructor() {
    owner = payable(msg.sender);
  }

  struct MarketItem {
    // like an object/map
    uint256 itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
  }

  mapping(uint256 => MarketItem) private idToMarketItem; // fetch items by id - uint256 is the item id

  // Event for when a market item is created i.e. listen to these events
  event MarketItemCreated(
    uint256 indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    bool sold
  );

  // Returns the listing price of the contract
  function getListingPrice() public view returns (uint256) {
    return listingPrice;
  }

  // Places an item for sale on the marketplace
  function createMarketItem(
    address nftContract,
    uint256 tokenId,
    uint256 price
  ) public payable nonReentrant {
    // nonReentrant is a modifier
    require(price > 0, "Price must be at least 1 wei");
    require(msg.value == listingPrice, "Price must equal to lisiting price");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();

    idToMarketItem[itemId] = MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender), // person selling the NFT
      payable(address(0)), // owner set to empty address as not sold yet
      price,
      false
    );

    // This transfers ownership of NFT
    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    // Emit the event to be read by the client in the Dapp. Events are logged on the blockchain
    emit MarketItemCreated(
      itemId,
      nftContract,
      tokenId,
      msg.sender, // address seller
      address(0), // address owner
      price, // uint price
      false // bool sold
    );
  }

  // Creates the sale of a marketplace item
  // Transfers ownership of the item, as well as funds between parties
  function createMarketSale(address nftContract, uint256 itemId)
    public
    payable
    nonReentrant
  {
    uint256 price = idToMarketItem[itemId].price;
    uint256 tokenId = idToMarketItem[itemId].tokenId;
    require(
      msg.value == price,
      "Please submit the asking price in order to complete the purchase"
    );

    idToMarketItem[itemId].seller.transfer(msg.value); // sends the money for transfer
    IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId); // transfers ownership of the NFT to buyer
    idToMarketItem[itemId].owner = payable(msg.sender); // updating mapping to pay OP
    idToMarketItem[itemId].sold = true;
    _itemsSold.increment();
    payable(owner).transfer(listingPrice);
  }

  // Returns all unsold market items
  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint256 itemCount = _itemIds.current();
    uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
    uint256 currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](unsoldItemCount); // creates the array based off the 'type' declared earlier as MarketItem[]
    for (uint256 i = 0; i < itemCount; i++) {
      if (idToMarketItem[i + 1].owner == address(0)) {
        // checks if owner is empty address (it's only populated if item is sold)
        uint256 currentId = i + 1; // set to id that's currently being looped
        MarketItem storage currentItem = idToMarketItem[currentId]; // reference to market item we want to insert into arrayxs
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  // Returns only items that a user has purchased
  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    // loop over total array and check which ones correspond to user
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        uint256 currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  // Returns only items a user has created
  function fetchItemsCreated() public view returns (MarketItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        uint256 currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }
}
