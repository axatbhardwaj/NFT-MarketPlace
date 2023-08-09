## NFT Marketplace

This repository contains the smart contracts for a decentralized marketplace for buying and selling NFTs. The marketplace uses a custom ERC20 token, called TRIToken, to facilitate payments.

The three smart contracts in this repository are:

1. **NFTMarketplace.sol:** This is the main contract for the marketplace. It allows users to create listings for NFTs, buy NFTs from listings, and cancel listings.

2. **TRINFT.sol:** This contract defines the TRINFT, an ERC721 NFT with minting and URI functionality.

3. **TRIToken.sol:** This contract defines the TRIToken, an ERC20 token used in the marketplace.

### Functionalities

The marketplace supports the following functionalities:

1. **Buying NFTs:** Users can buy NFTs from listings by transferring the required amount of TRITokens to the marketplace contract. The marketplace contract will then transfer the NFT to the buyer.

2. **Selling NFTs:** Users can create listings for their NFTs by specifying the price of the NFT and the duration of the listing. If a buyer purchases the NFT during the listing period, the marketplace contract will transfer the NFT to the buyer and the TRITokens to the seller.

3. **Minting NFTs:** The owner of the TRINFT contract can mint new NFTs by specifying a token URI. The token URI is a string that contains the metadata for the NFT, such as the name, description, and image of the NFT.
