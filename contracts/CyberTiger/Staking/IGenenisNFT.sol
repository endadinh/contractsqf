//V2
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IGenenisNFT {  
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function safeMint(address to, string memory tokenUri) external returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

}


contract Staking {
    IGenenisNFT public _mainNFT;

    constructor(address mainNFTAddress )  { 
        _mainNFT = IGenenisNFT(mainNFTAddress);
    } 


    function test() public view returns(address) { 
        return address(_mainNFT);

    }
    function mint(address to, string memory uri) public returns (bool) { 
        _mainNFT.safeMint(to, uri);

        return true;

    }

}