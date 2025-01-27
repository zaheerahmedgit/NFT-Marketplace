// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./NFT.sol";
import "./ERC20.sol";

contract NFTMarketplace {

    enum ListingStatus { Active, Sold, DeListed }

    struct Listing {
        ListingStatus status;
        address seller;
        address token;
        uint tokenId;
        uint price; // Price in USDT (18 decimals)
    }

    uint private _listingId = 0;
    mapping(uint => Listing) private listings;

    IERC721 private nftContract; // Reference to the NFT contract
    IERC20 private usdtContract; // Reference to the USDT contract

    event NFTListed(
        address seller,
        address token,
        uint listingId,
        uint tokenId,
        uint price
    );
    event Sale(
        address buyer,
        address token,
        uint listingId,
        uint tokenId,
        uint price
    );
    event DeListed(
        uint listingId,
        address seller
    );
    event sellNFTs(
        address seller,
        address token,
        uint listingId,
        uint tokenId,
        uint price
    );

    // Constructor to initialize NFT and USDT contract addresses
    constructor(address _nftAddress, address _usdtAddress) {
        nftContract = IERC721(_nftAddress);
        usdtContract = IERC20(_usdtAddress);
    }

    // Fetch listing details
    function getListing(uint listingId) public view returns (Listing memory) {
        return listings[listingId];
    }

    // List NFT for sale
    function listNFT(uint tokenId, uint price) external {
        // Ensure the caller is the owner of the token
        require(nftContract.ownerOf(tokenId) == msg.sender, "You are not the owner");
        // Transfer NFT to the marketplace
        nftContract.transferFrom(msg.sender, address(this), tokenId);

        // Create a listing
        Listing memory NFTListing = Listing(
            ListingStatus.Active,
            msg.sender,
            address(nftContract),
            tokenId,
            price
        );

        _listingId++;
        listings[_listingId] = NFTListing;

        emit NFTListed(msg.sender, address(nftContract), _listingId, tokenId, price);
    }

    // Buy an NFT with USDT
    function buyNFT(uint listingId) external {
        Listing storage NFTListing = listings[listingId];
        require(msg.sender != NFTListing.seller, "Buyer can't be seller");
        require(NFTListing.status == ListingStatus.Active, "Listing is not active");
        require(usdtContract.balanceOf(msg.sender) >= NFTListing.price, "Insufficient USDT balance");

        // Transfer USDT from buyer to seller
        require(
            usdtContract.transferFrom(msg.sender, NFTListing.seller, NFTListing.price),
            "USDT transfer failed"
        );

        // Transfer NFT ownership to buyer
        nftContract.transferFrom(address(this), msg.sender, NFTListing.tokenId);

        // Mark listing as sold
        NFTListing.status = ListingStatus.Sold;

        emit Sale(msg.sender, address(nftContract), listingId, NFTListing.tokenId, NFTListing.price);
    }

    // Delist NFT
    function deList(uint listingId) public {
        Listing storage NFTListing = listings[listingId];
        require(msg.sender == NFTListing.seller, "Only seller can delist NFT");
        require(NFTListing.status == ListingStatus.Active, "NFT not listed");

        // Mark as delisted
        NFTListing.status = ListingStatus.DeListed;

        // Transfer NFT back to seller
        nftContract.transferFrom(address(this), msg.sender, NFTListing.tokenId);

        emit DeListed(listingId, NFTListing.seller);
    }

    // Relist an NFT after purchase
    function sellNFT(uint listingId, uint newPrice) external {
        Listing storage NFTListing = listings[listingId];

        // Ensure the NFT was purchased and the sender is the current owner
        require(NFTListing.status == ListingStatus.Sold, "NFT must have been sold to be relisted");
        require(nftContract.ownerOf(NFTListing.tokenId) == msg.sender, "You are not the owner");

        // Transfer NFT back to the marketplace
        nftContract.transferFrom(msg.sender, address(this), NFTListing.tokenId);

        // Update listing details
        NFTListing.status = ListingStatus.Active;
        NFTListing.seller = msg.sender;
        NFTListing.price = newPrice;

        emit sellNFTs(msg.sender, address(nftContract), listingId, NFTListing.tokenId, newPrice);
    }
}
