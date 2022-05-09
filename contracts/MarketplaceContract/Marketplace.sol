// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Initializable.sol";
import "./OwnableUpgradeable.sol";
import "./OwnableUpgradeable.sol";
import "./PausableUpgradeable.sol";
import "./SafeMathUpgradeable.sol";
import "./AddressUpgradeable.sol";
import "./IERC721Upgradeable.sol";

import "./MarketplaceStorage.sol";

contract Marketplace is
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable,
    MarketplaceStorage
{
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function initialize() public initializer {
        __Ownable_init();
    }

    function setBnbFeePercent(uint8 _feePercent) external onlyOwner {
        bnbFeePercent = _feePercent;
    }

    function setAntaFeePercent(uint8 _feePercent) external onlyOwner {
        antaFeePercent = _feePercent;
    }

    function setAntaToken(address _address) external onlyOwner {
        antaToken = IERC20(_address);
    }

    function claimBNB() external onlyOwner {
        (bool sent, bytes memory data) = payable(_msgSender()).call{
            value: address(this).balance
        }("");
        require(sent, "Failed to send BNB");
        emit Claim(_msgSender(), address(this).balance);
    }

    function claimAnta() external onlyOwner {
        uint256 remainAmountToken = antaToken.balanceOf(address(this));
        antaToken.transfer(_msgSender(), remainAmountToken);
        emit Claim(_msgSender(), remainAmountToken);
    }

    function buyItem(address nftAddress, uint256 assetId) public payable {
        _requireERC721(nftAddress);

        address sender = msg.sender;
        Item memory item = items[nftAddress][assetId];

        require(item.id != 0, "Asset not published");
        require(item.status == ItemStatus.LIST, "Asset is not list to buy");
        require(
            msg.value >= item.price,
            "Payable value need greater equal price"
        );

        address seller = item.seller;
        require(seller != address(0), "Invalid address");

        IERC721Upgradeable nftRegistry = IERC721Upgradeable(nftAddress);
        
        uint256 fee = (bnbFeePercent * msg.value) / 100;
        uint256 remainAmount = msg.value - fee;
        payable(seller).transfer(remainAmount);
        nftRegistry.safeTransferFrom(address(this), sender, assetId);

        items[nftAddress][assetId].seller = sender;
        items[nftAddress][assetId].status = ItemStatus.BOUGHT;

        emit BuyItemSuccessful(
            item.id,
            assetId,
            seller,
            nftAddress,
            item.price,
            bnbFeePercent,
            fee,
            sender,
            "BNB",
            block.timestamp
        );
    }

    function buyItemByAnta(
        address nftAddress,
        uint256 assetId,
        uint256 priceAnta
    ) public {
        _requireERC721(nftAddress);

        address sender = msg.sender;
        IERC721Upgradeable nftRegistry = IERC721Upgradeable(nftAddress);
        Item memory item = items[nftAddress][assetId];

        require(item.id != 0, "Asset not published");
        require(item.status == ItemStatus.LIST, "Asset is not list to buy");

        address seller = item.seller;

        require(seller != address(0), "Invalid address");
        require(priceAnta >= item.priceAnta, "price need equal listing price");

        uint256 fee = (antaFeePercent * priceAnta) / 100;
        uint256 remainAmount = priceAnta - fee;
        antaToken.transferFrom(sender, address(this), fee);
        antaToken.transferFrom(sender, seller, remainAmount);
        nftRegistry.safeTransferFrom(address(this), sender, assetId);

        items[nftAddress][assetId].seller = sender;
        items[nftAddress][assetId].status = ItemStatus.BOUGHT;

        emit BuyItemSuccessful(
            item.id,
            assetId,
            seller,
            nftAddress,
            item.priceAnta,
            antaFeePercent,
            fee,
            sender,
            "ANTA",
            block.timestamp
        );
    }

    function _createItem(
        address seller,
        uint256 assetId,
        address nftAddress,
        uint256 price,
        uint256 priceAnta
    ) internal {
        bytes32 itemId = keccak256(
            abi.encodePacked(
                block.timestamp,
                seller,
                assetId,
                nftAddress,
                price
            )
        );

        items[nftAddress][assetId] = Item({
            id: itemId,
            seller: seller,
            nftAddress: nftAddress,
            price: price,
            priceAnta: priceAnta,
            status: ItemStatus.LIST
        });
    }

    function sellItem(
        address nftAddress,
        uint256 assetId,
        uint256 price
    ) public {
        require(price > 0, "Price should be bigger than 0");
        _requireERC721(nftAddress);

        address seller = msg.sender;
        IERC721Upgradeable nftRegistry = IERC721Upgradeable(nftAddress);

        require(
            nftRegistry.ownerOf(assetId) == seller,
            "The seller is no longer the owner"
        );
        nftRegistry.transferFrom(seller, address(this), assetId);
        Item memory item = items[nftAddress][assetId];
        if (item.id == 0) {
            _createItem(seller, assetId, nftAddress, price, 0);
        } else {
            require(item.status != ItemStatus.LIST, "Asset is listing");
            items[nftAddress][assetId].status = ItemStatus.LIST;
            items[nftAddress][assetId].price = price;
            items[nftAddress][assetId].seller = seller;
        }
        emit SellItemSuccessful(
            nftAddress,
            item.id,
            assetId,
            price,
            seller,
            "BNB",
            block.timestamp
        );
    }

    function sellItemByAnta(
        address nftAddress,
        uint256 assetId,
        uint256 priceAnta
    ) public {
        require(priceAnta > 0, "Price should be bigger than 0");
        _requireERC721(nftAddress);

        address seller = msg.sender;

        IERC721Upgradeable nftRegistry = IERC721Upgradeable(nftAddress);
        require(
            nftRegistry.ownerOf(assetId) == seller,
            "The seller is no longer the owner"
        );
        nftRegistry.transferFrom(seller, address(this), assetId);
        Item memory item = items[nftAddress][assetId];
        if (item.id == 0) {
            _createItem(seller, assetId, nftAddress, 0, priceAnta);
        } else {
            require(item.status != ItemStatus.LIST, "Asset is listing");
            items[nftAddress][assetId].status = ItemStatus.LIST;
            items[nftAddress][assetId].priceAnta = priceAnta;
            items[nftAddress][assetId].seller = seller;
        }
        emit SellItemSuccessful(
            nftAddress,
            item.id,
            assetId,
            priceAnta,
            seller,
            "ANTA",
            block.timestamp
        );
    }
    
    function delistItem(address nftAddress, uint256 assetId) public {
        _requireERC721(nftAddress);

        address deleteBy = msg.sender;
        Item memory item = items[nftAddress][assetId];

        require(item.id != 0, "Asset not published");
        require(item.status != ItemStatus.DELIST, "Asset delisted");

        address seller = item.seller;
        require(seller != address(0), "Invalid address");
        require(
            seller == msg.sender,
            "Only seller can delist"
        );
        items[nftAddress][assetId].status = ItemStatus.DELIST;

        IERC721Upgradeable nftRegistry = IERC721Upgradeable(nftAddress);
        nftRegistry.safeTransferFrom(address(this), seller, assetId);

        emit DelistItemSuccessful(
            nftAddress,
            item.id,
            assetId,
            deleteBy,
            block.timestamp
        );
    }

    function _requireERC721(address nftAddress) internal view {
        require(
            nftAddress.isContract(),
            "The NFT Address should be a contract"
        );

        IERC721Upgradeable nftRegistry = IERC721Upgradeable(nftAddress);
        require(
            nftRegistry.supportsInterface(ERC721_Interface),
            "The NFT contract has an invalid ERC721 implementation"
        );
    }
}