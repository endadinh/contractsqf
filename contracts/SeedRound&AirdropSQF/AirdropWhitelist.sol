// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
import "./Token.sol";


contract Airdrop is Ownable {

    using SafeMath for uint256;
	using Address for address;

	IERC20 public _BUSD;
    SQFToken public _mainToken;
	uint256 public _maxTokenSale;
	uint256 public _saledToken;
	bool public _saleStatus;
	uint256 public _tokenPrice;  // token pre-sale price in BNB
	uint256 public _endSaleBlock ;
	uint[10] public _openBlockArr;
    address[] public whiteList;

    mapping(address => bool) public isWhiteList;
    mapping(address => uint256) public buyedToken;
	mapping(address => uint256) public buyedBUSD;
	mapping(address => uint256) public claimedPercent;
    
    constructor(address _token) public {
		_mainToken = SQFToken(_token);
		_maxTokenSale = 2*10**4*10**18;
		_saledToken = 0;
		_saleStatus = true;
		_tokenPrice = 38 * 10 ** 12;
		// _endSaleBlock = block.timestamp.add(2*60*60);
		// _openBlockArr[0] = _endSaleBlock.add(15*60);
		// _openBlockArr[1] = _endSaleBlock.add(30*60);
		// _openBlockArr[2] = _endSaleBlock.add(45*60);
		// _openBlockArr[3] = _endSaleBlock.add(60*60);
		// _openBlockArr[4] = _endSaleBlock.add(75*60);
		// _openBlockArr[5] = _endSaleBlock.add(90*60);
		// _openBlockArr[6] = _endSaleBlock.add(105*60);
		// _openBlockArr[7] = _endSaleBlock.add(120*60);
		// _openBlockArr[8] = _endSaleBlock.add(135*60);
	
    }

    // constructor(address _tokenAddr) public {
    //     tokenAddr = _tokenAddr;
    // }

    function dropTokens(address[] memory _recipients, uint256[] memory _amount) public onlyOwner returns (bool) {
       
        for (uint i = 0; i < _recipients.length; i++) {
            require(_recipients[i] != address(0));
            require(_mainToken.transfer(_recipients[i], _amount[i]));
        }

        return true;
    }

    // function dropEther(address[] memory _recipients, uint256[] memory _amount) public payable onlyOwner returns (bool) {
    //     uint total = 0;

    //     for(uint j = 0; j < _amount.length; j++) {
    //         total = total.add(_amount[j]);
    //     }

    //     require(total <= msg.value);
    //     require(_recipients.length == _amount.length);


    //     for (uint i = 0; i < _recipients.length; i++) {
    //         require(_recipients[i] != address(0));

    //         payable(_recipients[i]).transfer(_amount[i]);

    //         emit EtherTransfer(_recipients[i], _amount[i]);
    //     }

    //     return true;
    // }

    // function updateTokenAddress(address newTokenAddr) public onlyOwner {
    //     tokenAddr = newTokenAddr;
    // }

    // function withdrawTokens(address beneficiary) public onlyOwner {
    //     require(Token(tokenAddr).transfer(beneficiary, Token(tokenAddr).balanceOf(address(this))));
    // }

    // function withdrawEther(address payable beneficiary) public onlyOwner {
    //     beneficiary.transfer(address(this).balance);
    // }
}