//V2
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";
import "./Pausable.sol";
import "./Counters.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract NFTGenesis is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Pausable,
    Ownable
{



    using SafeMath for uint256;
    using Counters for Counters.Counter;

    enum nftRarity {
         Common,
         Rare,
         SuperRare
    }


    struct GenesisNFTStruct {
        nftRarity rarity;
        uint8 status;
    }
    
    mapping(address=>mapping(uint=>uint)) private _ownedTokens;
    mapping(uint256 => GenesisNFTStruct) public tigerDna;
    mapping(address => bool) public PAUSER_ROLE;
    mapping(address => bool) public MINTER_ROLE;
    mapping(address => bool) public HYDRA_ROLE;
    mapping(uint8 => nftRarity) public _NFTRarity;

    modifier onlyMinter() { 
        require(MINTER_ROLE[msg.sender] == true, "Missing Role");
        _;
    }
    modifier onlyPauser() { 
        require(PAUSER_ROLE[msg.sender] == true, "Missing Role");
        _;
    }
    modifier onlyHydra() { 
        require(HYDRA_ROLE[msg.sender] == true, "Missing Role");
        _;
    }


    string private _URI;
    event ActiveTiger(uint256[] tokenId, uint8[] status);

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("TigerCyber", "TC") {
        PAUSER_ROLE[msg.sender] = true;
        MINTER_ROLE[msg.sender] = true;
        HYDRA_ROLE[msg.sender] = true;
    }

    function _baseURI() internal view override returns (string memory) {
        return _URI;
    }

    function changeBaseURI(string memory _newURI)
        public
        onlyOwner
    {
        _URI = _newURI;
    }

    function setMinterRole(address to) public onlyOwner returns (bool) { 
        MINTER_ROLE[to] = true;
        return true;
    }

    function setPauserRole(address to) public onlyOwner returns (bool) { 
        PAUSER_ROLE[to] = true;
        return true;
    }

    function setHydraRole(address to) public onlyOwner returns (bool) { 
        HYDRA_ROLE[to] = true;
        return true;
    }

    function unSetMinterRole(address to) public onlyOwner returns (bool) { 
        MINTER_ROLE[to] = false;
        return false;
    }

    function unSetPauserRole(address to) public onlyOwner returns (bool) { 
        PAUSER_ROLE[to] = false;
        return false;
    }

    function unSetHydraRole(address to) public onlyOwner returns (bool) { 
        HYDRA_ROLE[to] = false;
        return false;
    }

    function pause() public onlyPauser {
        _pause();
    }

    function unpause() public onlyPauser {
        _unpause();
    }

    function tokenOwnerByIndex(address owner,uint index) public view returns(uint){
      require(index<ERC721.balanceOf(owner), "Index out of bounds");
      return _ownedTokens[owner][index];
    }

    function tigerInfo(uint256 tokenId)
        public
        view
        returns (
            address owner,
            string memory _uri,
            string memory rarity,
            uint8 status
        )
    {
        GenesisNFTStruct memory tg = tigerDna[tokenId];
        return (
            ownerOf(tokenId),
            tokenURI(tokenId),
            getRarityKeyByValue(tg.rarity),
            tg.status
        );
    }

    function getRarityKeyByValue(nftRarity _rarity) internal pure returns (string memory Rarity) {
        
        // Error handling for input
        require(uint8(_rarity) < 3, "Undefined Rarity !");
        // Loop through possible options
        if (nftRarity.Common == _rarity) return "Common";
        if (nftRarity.Rare == _rarity) return "Rare";
        if (nftRarity.SuperRare == _rarity) return "Supper Rare";

    }


    function safeMint(
        address to,
        string memory tokenUri,
        nftRarity rarity
    ) public onlyMinter returns (uint256) {
        require(uint8(rarity) <= 3, "Undefined rarity code !");
        _safeMint(to, _tokenIdCounter.current());
        tigerDna[_tokenIdCounter.current()] = GenesisNFTStruct(
            rarity,
            1
        );
        _setTokenURI(_tokenIdCounter.current(), tokenUri);
        _tokenIdCounter.increment();
        return _tokenIdCounter.current() - 1;
    }

    function activeTiger(uint256[] memory tokenId, uint8[] memory status)
        public
        onlyHydra
    {
        for (uint256 i = 0; i < tokenId.length; i++) {
            require(status[i] != 0, "Can not set to processing");
            tigerDna[tokenId[i]].status = status[i];
        }
        emit ActiveTiger(tokenId, status);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        if (from != address(0x0)) {
            require(tigerDna[tokenId].status == 1, "Tiger must be active");
        }
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function burn(uint256 tokenId) public onlyMinter {
        _burn(tokenId);
    }

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