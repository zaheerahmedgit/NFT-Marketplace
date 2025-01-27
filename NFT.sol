// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// NFT Contract
contract NFT is ERC721URIStorage{
    
    uint256 private _tokenId; // Counter for the next token ID

    // Approval event for marketplace
    event ApprovalForMarketplace(address indexed owner, address indexed marketplace, uint256 tokenId);

    // Constructor to initialize the NFT contract with a name and symbol
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    // Mint function to create new NFTs
    function mint(address to, string memory tokenURI) public {
        uint256 tokenId = _tokenId;
        tokenId++; 
        _mint(to, tokenId); 
        _setTokenURI(tokenId, tokenURI);
    }

    // Function to approve the marketplace for a specific NFT
    function approveNFT(address _NFT, uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner");
        approve(_NFT, tokenId); 
        emit ApprovalForMarketplace(msg.sender, _NFT, tokenId); 
    }
}
