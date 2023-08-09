// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title TRINFT
 * @dev This contract defines the TRINFT, an ERC721 NFT with minting and URI functionality.
 */
contract TRINFT is ERC721, Ownable, ReentrancyGuard {
    address private marketPlace;

    uint256 private tokenCounter;
    mapping(uint256 => string) private tokenURIs;
    mapping(uint256 => bool) private mintedTokens;

    // Custom error messages
    error NonexistentToken(uint256);
    error TokenAlreadyMinted(uint256);
    error NotTokenOwner(address, uint256);
    error NotTokenOwnerNorSelf(address, uint256);

    // Modifier to ensure only the owner or token holder can execute a function
    modifier onlyOwnerOrSelf(uint256 tokenId) {
        if (msg.sender != owner() && msg.sender != ownerOf(tokenId)) {
            revert NotTokenOwner(msg.sender, tokenId);
        }
        _;
    }

    // Constructor initializes the ERC721 token with a name and symbol
    constructor() ERC721("TRKONENFT", "TRINFT") {
        tokenCounter = 0;
    }

    /**
     * @dev Mint a new NFT with the provided token URI.
     * @param _tokenURI The URI for the minted NFT's metadata.
     */
    function mintNFT(string memory _tokenURI) external nonReentrant {
        uint256 tokenId = tokenCounter;

        // Check if the token has already been minted
        if (mintedTokens[tokenId]) {
            revert TokenAlreadyMinted(tokenId);
        }

        // Mint the NFT and assign the token URI
        _mint(msg.sender, tokenId);
        tokenURIs[tokenId] = _tokenURI;
        mintedTokens[tokenId] = true;
        tokenCounter++;
    }

    /**
     * @dev Set the token URI for a specific token ID.
     * @param tokenId The ID of the NFT.
     * @param _tokenURI The updated URI for the NFT's metadata.
     */
    function setTokenURI(
        uint256 tokenId,
        string memory _tokenURI
    ) external onlyOwnerOrSelf(tokenId) {
        // Check if the token exists
        if (!_exists(tokenId)) {
            revert NonexistentToken(tokenId);
        }
        // Update the token URI
        tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Override ERC721's tokenURI function to retrieve the token's URI.
     * @param tokenId The ID of the NFT.
     * @return The URI for the NFT's metadata.
     */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        // Check if the token exists
        if (!_exists(tokenId)) {
            revert NonexistentToken(tokenId);
        }
        // Retrieve and return the token URI
        return tokenURIs[tokenId];
    }
}
