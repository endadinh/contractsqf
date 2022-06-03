// SPDX-License-Identifier: MIT

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
    
    constructor(address _nftContract, address _tokenContract) {

        require(_nftContract != address(0) && _tokenContract != address(0), "Invalid contract address");
        _mainNFT = WSPShoes(_nftContract);
        _mainToken = IERC20(_tokenContract);
    }
    function setSQFToken(address _address) external onlyOwner {
        _mainToken = IERC20(_address);
    }
    function safeMintItem(string memory itemId, string memory externalId) public { 
        require(
            userStatus[msg.sender].status != activeStatus.HUMAN,
            "You must active account before mint NFTs!"
        );
        uint256 tokenId = _mainNFT.currentCountId();
        _mainNFT.safeMintToUser(msg.sender,itemId,externalId);
        ingameItem[tokenId] = ingameItems(
            tokenId,
            msg.sender,
            itemId,
            externalId,
            false
        );
    }

    function setOwnerIngameItem(address from,address newOwner, uint256 tokenId) external  { 
            require(from == ingameItem[tokenId].owner, "Only owner of token can do this");
            ingameItem[tokenId].owner = newOwner;
    }

    function lockIngameItem(uint256 tokenId) public  { 
            require(msg.sender == ingameItem[tokenId].owner, "Only owner of token can do this");
            require(ingameItem[tokenId].ingame == false, "Locked item !");
            ingameItem[tokenId].ingame = true;
    }

    function unlockIngameItem(uint256 tokenId) public  { 
            require(msg.sender == ingameItem[tokenId].owner, "Only owner of token can do this");
            require(ingameItem[tokenId].ingame == true, "Unlocked item !");
            ingameItem[tokenId].ingame = false;
    }

    function getOwnItems(bool ingame) public view returns(ingameItems[] memory) { 
            uint totalItemCount = _mainNFT.currentCountId();
            uint itemCount = 0;
            uint currentIndex = 0;           
            for (uint i = 0; i < totalItemCount; i++) {
                if (( ingameItem[i].owner == msg.sender) && (ingameItem[i].ingame == ingame)) {
                itemCount += 1;
                }
            }
            ingameItems[] memory items = new ingameItems[](itemCount);
            for (uint i = 0; i < totalItemCount; i++) {
            if (( ingameItem[i].owner == msg.sender) && (ingameItem[i].ingame == ingame )) {

                uint currentId = ingameItem[i].id;
                ingameItems storage currentItem = ingameItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function getIngameItem(uint itemId) public view returns (ingameItems memory) {
        ingameItems memory item = ingameItem[itemId];
        return item;
    }
     
}