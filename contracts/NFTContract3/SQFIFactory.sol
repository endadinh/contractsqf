// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;
import "./FactoryStorage.sol";
import "./IERC165.sol";
import "./Ownable.sol";
import "./SQFNFT.sol";


pragma solidity ^0.8.4;

contract SQFItemFactory is FactoryStorage, Ownable

{
    address public nftContract;
    uint256 public bronzeActivePrice;
    uint256 public silverActivePrice;
    uint256 public goldActivePrice;

    SQFItem public _mainToken;

    event NFTMinted(
        uint256 tokenId,
        address indexed to,
        string itemId,
        string externalId
    );
    event buyActive(
        uint256 tokenId,
        address indexed to,
        string typeActive
    );

    constructor(address _nftContract) {
        require(_nftContract != address(0), "Invalid contract address");
        _mainToken = SQFItem(_nftContract);
        nftContract = _nftContract;
        bronzeActivePrice = 500*10**18;
        silverActivePrice = 1000*10**18;
        goldActivePrice = 1500*10**18;
    }

    function setSQFToken(address _address) external onlyOwner {
        sqfToken = IERC20(_address);
    }

    function mintActiveItem(string memory typeItem) public { 
        uint256 itemId;
        require(
        keccak256(abi.encodePacked(typeItem)) == keccak256(abi.encodePacked("BRONZE"))
        || keccak256(abi.encodePacked(typeItem)) == keccak256(abi.encodePacked("SILVER"))
        || keccak256(abi.encodePacked(typeItem)) == keccak256(abi.encodePacked("GOLD")),
        "Item's type is not valid"
        );
        if (keccak256(abi.encodePacked(typeItem)) == keccak256(abi.encodePacked("BRONZE"))) {
            sqfToken.transferFrom(msg.sender, address(owner()),bronzeActivePrice);
            _mainToken.safeBuyActive(msg.sender);
            itemId = _mainToken.currentCountId();
            activeItem[itemId] = activeItems(
            itemId,
            msg.sender,
            activeStatus.BRONZE
            );
        }
        else if(keccak256(abi.encodePacked(typeItem)) == keccak256(abi.encodePacked("SILVER"))) { 
            sqfToken.transferFrom(msg.sender, address(owner()),silverActivePrice);
            _mainToken.safeBuyActive(msg.sender);
            itemId = _mainToken.currentCountId();
            activeItem[itemId] = activeItems(
            itemId,
            msg.sender,
            activeStatus.SILVER
        );
        }
        else if(keccak256(abi.encodePacked(typeItem)) == keccak256(abi.encodePacked("GOLD"))) { 
            sqfToken.transferFrom(msg.sender, address(owner()),goldActivePrice);
            _mainToken.safeBuyActive(msg.sender);
            itemId = _mainToken.currentCountId();
            activeItem[itemId] = activeItems(
            itemId,
            msg.sender,
            activeStatus.GOLD
        );
        }
        emit buyActive(itemId,msg.sender,typeItem);
    }

    function fetchMyActiveItem() public view returns(activeItems[] memory) { 
        uint totalItemCount = _mainToken.currentCountId();
        uint itemCount = 0;
        uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (activeItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    activeItems[] memory items = new activeItems[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (activeItem[i + 1].owner == msg.sender) {
        uint currentId = activeItem[i + 1].id;
        activeItems storage currentItem = activeItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
   
    return items;
    }

}