//V2
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";
import "./Pausable.sol";
import "./AccessControl.sol";
import "./Counters.sol";
import "./SafeMath.sol";

contract CyberTiger is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Pausable,
    AccessControl
{

    using SafeMath for uint256;
    using Counters for Counters.Counter;

    struct CyberTigerStruct {
        string originalData;
        uint8 status;
    }

    mapping(uint256 => CyberTigerStruct) public tigerDna;
    mapping(address => bool) public PAUSER_ROLE;
    mapping(address => bool) public MINTER_ROLE;
    mapping(address => bool) public HYDRA_ROLE;

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
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _URI = _newURI;
    }

    function pause() public onlyPauser {
        _pause();
    }

    function unpause() public onlyPauser {
        _unpause();
    }

    function tigerInfo(uint256 tokenId)
        public
        view
        returns (
            address owner,
            string memory _uri,
            uint8 status
        )
    {
        CyberTigerStruct memory tg = tigerDna[tokenId];
        return (
            ownerOf(tokenId),
            tokenURI(tokenId),
            tg.status
        );
    }

    function safeMint(
        address to,
        string memory tokenUri
    ) public onlyMinter returns (uint256) {
        _safeMint(to, _tokenIdCounter.current());
        tigerDna[_tokenIdCounter.current()] = CyberTigerStruct(
            tokenUri,
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
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}