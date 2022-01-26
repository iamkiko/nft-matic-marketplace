// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds; // to increment with a unique identifier for tokens
  address contractAddress; // address for marketplace we want NFT to be able to interact with e.g. to change ownership of contract/transact

  constructor(address marketplaceAddress) ERC721("Metaverse Tokens", "METT") {
    contractAddress = marketplaceAddress;
  }

  function createToken(string memory tokenURI) public returns (uint256) {
    // marketplace is stored and we know the person sending from msg.sender so only need to pass in tokenURI
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();

    _mint(msg.sender, newItemId);
    _setTokenURI(newItemId, tokenURI); //_setTokenURI made available by ERC721URIStorage package
    setApprovalForAll(contractAddress, true); // gives it the approval to transact tokens with users from outside contracts
    return newItemId; // need the id for the UI
  }
}
