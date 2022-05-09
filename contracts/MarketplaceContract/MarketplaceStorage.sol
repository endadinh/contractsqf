// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";

contract MarketplaceStorage {
    enum ItemStatus {
        MINTED,
        LIST,
        BOUGHT,
        OFFER,
        DELIST
    }

    struct Item {
        // Item ID
        bytes32 id;
        // Owner of the NFT
        address seller;
        // NFT registry address
        address nftAddress;
        // Price (in wei) for the listing item
        uint256 price;
        // Price (in Anta) for the listing item
        uint256 priceAnta;
        // status of the item
        ItemStatus status;
    }

    struct ItemOffer {
        // Item ID
        bytes32 id;
        // Price (in wei) for the published item
        uint256 offerPrice;
    }
    bytes4 public constant ERC721_Interface = bytes4(0x80ac58cd);

    // From ERC721 registry assetId to Item (to avoid asset collision)
    mapping(address => mapping(uint256 => Item)) public items;

    // From ERC721 registry assetId to Offer (to avoid asset collision)
    mapping(address => mapping(uint256 => mapping(address => ItemOffer)))
        public itemOffers;
    IERC20 public antaToken;

    uint8 public bnbFeePercent;
    uint8 public antaFeePercent;

    event Claim(address indexed receiver, uint256 value);

    event DelistItemSuccessful(
        address nftAddress,
        bytes32 id,
        uint256 indexed assetId,
        address indexed delistBy,
        uint256 createdAt
    );
    event BuyItemSuccessful(
        bytes32 id,
        uint256 indexed assetId,
        address indexed seller,
        address nftAddress,
        uint256 price,
        uint8 feePercent,
        uint256 fee,
        address indexed buyer,
        string currency,
        uint256 createdAt
    );
    event SellItemSuccessful(
        address nftAddress,
        bytes32 id,
        uint256 indexed assetId,
        uint256 price,
        address indexed seller,
        string currency,
        uint256 createdAt
    );
}