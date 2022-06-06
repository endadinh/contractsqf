// SPDX-License-Identifier: MIT


// External id == 1 : Mint By Admin,
// External id == 2 : Internal Mint,
// External id == 3 : Mint by User

pragma solidity ^0.8.0;
import "./FactoryStorage.sol";
import "./IERC165.sol";
import "./Ownable.sol";
import "./NFTWSP.sol";


pragma solidity ^0.8.4;
contract WSPShoesFactory is FactoryStorage, Ownable

{

    IERC20 public _mainToken;
    WSPShoes public _mainNFT;
    
    constructor(address _tokenContract,address _nftContract) {

        require(_nftContract != address(0) && _tokenContract != address(0), "Invalid contract address");
        _mainNFT = WSPShoes(_nftContract);
        _mainToken = IERC20(_tokenContract);
    }
    function setMainToken(address _address) external onlyOwner {
        _mainToken = IERC20(_address);
    }
    function safeMintItem(string memory itemId, string memory externalId) public { 
        uint256 tokenId = _mainNFT.currentCountId();
        _mainNFT.safeMintToUser(msg.sender,itemId);
        itemInfo[tokenId] = Items(
            tokenId,
            msg.sender,
            itemId,
            externalId,
            false
        );
    }

    function setOwnerItemInfo(address from,address newOwner, uint256 tokenId) external  { 
            require(from == itemInfo[tokenId].owner, "Only owner of token can do this");
            itemInfo[tokenId].owner = newOwner;
    }

    function lockItem(uint256 tokenId) public  { 
            require(msg.sender == itemInfo[tokenId].owner, "Only owner of token can do this");
            require(itemInfo[tokenId].locked == false, "Locked item !");
            itemInfo[tokenId].locked = true;
    }

    function unlockItem(uint256 tokenId) public  { 
            require(msg.sender == itemInfo[tokenId].owner, "Only owner of token can do this");
            require(itemInfo[tokenId].locked == true, "Unlocked item !");
            itemInfo[tokenId].locked = false;
    }

    function getOwnItems(bool locked) public view returns(Items[] memory) { 
            uint totalItemCount = _mainNFT.currentCountId();
            uint itemCount = 0;
            uint currentIndex = 0;           
            for (uint i = 0; i < totalItemCount; i++) {
                if (( itemInfo[i].owner == msg.sender) && (itemInfo[i].locked == locked)) {
                itemCount += 1;
                }
            }
            Items[] memory items = new Items[](itemCount);
            for (uint i = 0; i < totalItemCount; i++) {
            if (( itemInfo[i].owner == msg.sender) && (itemInfo[i].locked == locked )) {

                uint currentId = itemInfo[i].id;
                Items storage currentItem = itemInfo[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function getLockedItem(uint itemId) public view returns (Items memory) {
        Items memory item = itemInfo[itemId];
        return item;
    }
     
}