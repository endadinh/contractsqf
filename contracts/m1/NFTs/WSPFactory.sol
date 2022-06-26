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


    event depositToken(address indexed from, uint256 amount);
    event depositNFT(address from, uint256 indexed tokenId);

    event widthdrawToken(address indexed user,uint256 amount);
    event widthdrawNFT(address indexed user, uint256 tokenId);


    mapping(address => uint256) tokenDeposit;
    mapping(address => mapping(uint256 => bool)) public isNFTDeposit;
    
    
    constructor(address _tokenContract,address _nftContract) {

        require(_nftContract != address(0) && _tokenContract != address(0), "Invalid contract address");
        _mainNFT = WSPShoes(_nftContract);
        _mainToken = IERC20(_tokenContract);
    }
    function setMainToken(address _address) external onlyOwner {
        _mainToken = IERC20(_address);
    }
    function _safeMintItem(string memory uri) private { 
        _mainNFT.safeMintToUser(msg.sender,uri);
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

    function getLockedItem(uint uri) public view returns (Items memory) {
        Items memory item = itemInfo[uri];
        return item;
    }

    function appDepositNFT(uint256 tokenId) public { 
        require(isNFTDeposit[msg.sender][tokenId] != true, "Deposited Token");
        require(_mainNFT.ownerOf(tokenId) == address(msg.sender), "Owner Error");
        _mainNFT.safeTransferFrom(msg.sender, address(this), tokenId);
        isNFTDeposit[msg.sender][tokenId] = true;
        emit depositNFT(msg.sender, tokenId);
    }

    function appDepositToken(uint256 amount) public { 
        _mainToken.transferFrom(msg.sender, address(this), amount);
        tokenDeposit[msg.sender] = tokenDeposit[msg.sender] + amount;
        emit depositToken(msg.sender, amount);

     }

    function tokenWidthdraw(uint256 amount) public { 
            _mainToken.transfer(msg.sender,amount);
            tokenDeposit[msg.sender] = 0;
            emit widthdrawToken(msg.sender, amount);
    }


    function nftWidthdraw(uint256 tokenId,uint256 status) public { 
            require(status == 0, "invalid Withdraw code");
            require(isNFTDeposit[msg.sender][tokenId] == true);
            _mainNFT.transferFrom(address(this),msg.sender,tokenId);
            isNFTDeposit[msg.sender][tokenId] = false;
            emit widthdrawNFT(msg.sender,tokenId);
            
    }

    function widthdrawNewNFT(uint256 tokenId, uint256 status,string memory uri) public { 
            require(status == 1, "invalid widthraw code" );
            require(_mainNFT.isMintedNFT(tokenId) == false, "Available NFT");
            uint256 newId = _mainNFT.currentCountId();
            _safeMintItem(uri);
            itemInfo[tokenId] = Items(
                newId,
                msg.sender,
                uri,
                "1",
                false
            );
            emit widthdrawNFT(msg.sender,newId);
    }


     
}