// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// Custom error messages
error PriceMustBeGreaterThanZero();
error NotNFTOwner();
error NotApprovedForMarketplace();
error ListingNotActive();
error InsufficientFunds();
error NotSeller(address, uint256);

/**
 * @title NFTMarketplace
 * @dev This contract allows users to create listings for NFTs and buy NFTs that are listed in the marketplace.
 */
contract NFTMarketplace is Ownable, ReentrancyGuard {
    IERC20 public customToken;
    IERC721 public nftContract;

    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    Listing[] public listings;

    /**
     * @dev Emitted when a new listing is created in the marketplace.
     */
    event ListingCreated(
        uint256 indexed listingId,
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price
    );

    /**
     * @dev Emitted when a listing is cancelled by the seller.
     */
    event ListingCancelled(uint256 indexed listingId);

    /**
     * @dev Emitted when an NFT is successfully sold.
     */
    event NFTSold(
        uint256 indexed listingId,
        address indexed buyer,
        uint256 price
    );

    /**
     * @dev Constructor initializes the contract with the addresses of the ERC20 token and ERC721 NFT contract.
     * @param _tokenAddress The address of the ERC20 token that will be used to pay for NFTs.
     * @param _nftContract The address of the ERC721 contract that represents the NFTs that can be listed in the marketplace.
     */
    constructor(address _tokenAddress, address _nftContract) {
        customToken = IERC20(_tokenAddress);
        nftContract = IERC721(_nftContract);
    }

    /**
     * @dev Modifier to ensure only the seller of a listing can perform an action.
     * @param _listingId The ID of the listing.
     */
    modifier onlySeller(uint256 _listingId) {
        require(listings[_listingId].seller == msg.sender, "Not the seller");
        _;
    }

    /**
     * @dev Create a new listing for an NFT in the marketplace.
     * @param _tokenId The ID of the NFT that will be listed.
     * @param _price The price of the NFT.
     */
    function createListing(
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        // Check if the price is greater than zero
        if (_price <= 0) {
            revert PriceMustBeGreaterThanZero();
        }

        // Check if the caller is the owner of the NFT
        if (nftContract.ownerOf(_tokenId) != msg.sender) {
            revert NotNFTOwner();
        }

        // Check if the marketplace is approved for the NFT
        if (nftContract.getApproved(_tokenId) != address(this)) {
            revert NotApprovedForMarketplace();
        }

        // Create the listing
        listings.push(
            Listing({
                seller: msg.sender,
                tokenId: _tokenId,
                price: _price,
                active: true
            })
        );

        // Emit the ListingCreated event
        emit ListingCreated(listings.length - 1, msg.sender, _tokenId, _price);
    }

    /**
     * @dev Cancel a listing for an NFT in the marketplace.
     * @param _listingId The ID of the listing to cancel.
     */
    function cancelListing(
        uint256 _listingId
    ) external onlySeller(_listingId) nonReentrant {
        // Ensure the listing is active
        Listing storage listing = listings[_listingId];
        if (!listing.active) {
            revert ListingNotActive();
        }

        // Mark the listing as inactive
        listing.active = false;

        // Emit the ListingCancelled event
        emit ListingCancelled(_listingId);
    }

    /**
     * @dev Buy an NFT from the marketplace.
     * @param _listingId The ID of the listing to buy from.
     */
    function buyNFT(uint256 _listingId) external nonReentrant {
        // Ensure the listing is active
        Listing storage listing = listings[_listingId];
        if (!listing.active) {
            revert ListingNotActive();
        }

        // Ensure the buyer has enough funds
        if (customToken.balanceOf(msg.sender) < listing.price) {
            revert InsufficientFunds();
        }

        // Mark the listing as inactive
        listing.active = false;

        // Transfer funds from the buyer to the seller
        customToken.transferFrom(msg.sender, listing.seller, listing.price);

        // Transfer the NFT from the seller to the buyer
        nftContract.safeTransferFrom(
            listing.seller,
            msg.sender,
            listing.tokenId
        );

        // Emit the NFTSold event
        emit NFTSold(_listingId, msg.sender, listing.price);
    }

    /**
     * @dev Get the total number of listings in the marketplace.
     */
    function getListingsCount() external view returns (uint256) {
        return listings.length;
    }
}
