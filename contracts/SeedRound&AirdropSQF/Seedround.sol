pragma solidity ^0.6.12;
import "./Token.sol";

contract SupportSaleSeedRound is Ownable {
    using SafeMath for uint256;
	using Address for address;

    SQFToken public _tokenSale;
	uint public _maxTokenSale;
	uint256 public _saledToken;
	uint256 public _tokenPrice;  // token pre-sale price in BUSD
	uint256 public _endSaleBlock ;
	uint[10] public _openBlockArr;
	uint public totalWhiteList = 0;


    mapping(address => uint256) public buyedToken;
	mapping(address => uint256) public buyedBUSD;
	mapping(address => uint256) public claimedPercent;
	mapping(uint256 => address) public _whiteList;
    
    constructor(address _token) public {
		_tokenSale = SQFToken(_token) ;
		_maxTokenSale = 3.33333333333 * 10 ** 9 *10 ** 18;
		_saledToken = 0;
		_tokenPrice = 3 * 10 ** 13;
		_endSaleBlock = block.timestamp.add(18*24*3600);
		_openBlockArr[0] = _endSaleBlock.add(30*24*3600);
		_openBlockArr[1] = _endSaleBlock.add(60*24*3600);
		_openBlockArr[2] = _endSaleBlock.add(90*24*3600);
		_openBlockArr[3] = _endSaleBlock.add(120*24*3600);
		_openBlockArr[4] = _endSaleBlock.add(150*24*3600);
		_openBlockArr[5] = _endSaleBlock.add(180*24*3600);
		_openBlockArr[6] = _endSaleBlock.add(210*24*3600);
		_openBlockArr[7] = _endSaleBlock.add(240*24*3600);
		_openBlockArr[8] = _endSaleBlock.add(270*24*3600);
	}

	function adminMintWhitelist(address recipient, uint256 _amount) public onlyOwner { 
		uint256 totalToken = _amount.div(_tokenPrice);
		require(totalToken*10**18 < _maxTokenSale, "Maximum Token Saled for Seedround");
		_tokenSale.mintFrozenTokens(recipient, totalToken * 10 ** 18); 
		_tokenSale.meltTokens(recipient, (totalToken * 10 ** 18).mul(3).div(100));
		_saledToken = _saledToken.add(totalToken * 10 ** 18);
		buyedToken[recipient] = buyedToken[recipient].add(totalToken * 10 ** 18);
		buyedBUSD[recipient] = buyedBUSD[recipient].add(_amount);
		bool isAvail = checkAvail(recipient);
		if(	isAvail == false ) {
		_whiteList[totalWhiteList] = recipient;
		totalWhiteList++;
		}
		claimedPercent[recipient] = 3;
		emit BuySeedRound(address(msg.sender),totalToken);

	}

	function checkAvail(address inputAddress) public view returns (bool) { 
		bool isAvail = false;
		for (uint i = 0; i < totalWhiteList; i++ ) { 
			if(inputAddress == _whiteList[i]) { 
				isAvail = true;
				break;
				// return true;
			}
		}
		return isAvail;
 	}

	function checkTimeUnlockPercent () public view returns (uint256){
		uint256 checkNumber = block.timestamp;
		if(checkNumber < _openBlockArr[0]){
			return 3;
		}else if (_openBlockArr[0] <= checkNumber && checkNumber < _openBlockArr[1]){
			return 18;
		}else if (_openBlockArr[1] <= checkNumber && checkNumber < _openBlockArr[2]){
			return 30;
		}else if (_openBlockArr[2] <= checkNumber && checkNumber < _openBlockArr[3]){
			return 42;
		}else if (_openBlockArr[3] <= checkNumber && checkNumber < _openBlockArr[4]){
			return 54;
		}else if (_openBlockArr[4] <= checkNumber && checkNumber < _openBlockArr[5]){
			return 66;
		}else if (_openBlockArr[5] <= checkNumber && checkNumber < _openBlockArr[6]){
			return 78;
		}else if (_openBlockArr[6] <= checkNumber && checkNumber < _openBlockArr[7]){
			return 90;
		}else if (_openBlockArr[6] <= checkNumber) {
			return 100;
		}
	}

	function adminUnlockWhiteList() public onlyOwner {
		uint256 checkPercent = checkTimeUnlockPercent();
		require( claimedPercent[_whiteList[0]] < checkPercent , "Claimed All token !!! ");
		for (uint256 i = 0; i < totalWhiteList; i++) {
				if(claimedPercent[_whiteList[i]] < 100 && checkPercent > claimedPercent[_whiteList[i]]) { 
					uint256 tokenUnlock = (buyedToken[_whiteList[i]] * (checkPercent - claimedPercent[_whiteList[i]]) / 100);
					_tokenSale.meltTokens(_whiteList[i], tokenUnlock);
					claimedPercent[_whiteList[i]] = claimedPercent[_whiteList[i]].add((checkPercent - claimedPercent[_whiteList[i]]));
					emit UnlockSeedToken(_whiteList[i], tokenUnlock);
				}
        }
	}

	function set_Price(uint256 tokenPrice) public onlyOwner {
		_tokenPrice = tokenPrice;
	}
 
    event BuySeedRound(address indexed user, uint256 amount);
	event UnlockSeedToken(address indexed user, uint256 amount);

}
