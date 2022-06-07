// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";
import "./Pausable.sol";
import "./Ownable.sol";
import "./ERC721Burnable.sol";
import "./Counters.sol";
import "./Roleable.sol";

contract WSPShoes is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Pausable,
    Ownable,
    ERC721Burnable,
    Roleable
{
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIdCounter;
    mapping(string => bool) public mintedItemIds;
    address public holder;

    event NFTMinted(
        uint256 tokenId,
        address indexed to,
        string itemId
    );

    constructor(address _holder) ERC721("WSPShoes", "WSPS") {
        require(_holder != address(0), "Invalid holder address");
        holder = _holder;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function currentCountId() public view returns(uint256)  { 
        return _tokenIdCounter.current();
    }

    function setHolder(address _newHolder) public onlyOwner {
        require(_newHolder != address(0), "Invalid holder address");
        holder = _newHolder;
    }

    function safeMint(string memory itemId)
        public
        onlyMinter
    {
        require(
            !mintedItemIds[itemId],
            "WSPShoes: item already was minted"
        );
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(holder, tokenId);
        _setTokenURI(tokenId, itemId);
        mintedItemIds[itemId] = true;

        emit NFTMinted(tokenId, holder, itemId);
    }

    function safeMintToUser(address to,string memory itemId)
        public
        onlyMinter
    {
        require(
            !mintedItemIds[itemId],
            "SQFShoes: item already was minted"
        );
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, itemId);
        mintedItemIds[itemId] = true;

        emit NFTMinted(tokenId, to, itemId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}