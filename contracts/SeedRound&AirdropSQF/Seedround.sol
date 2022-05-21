pragma solidity ^0.6.12;
import "./Token.sol";

contract SupportSaleSeedRound is Ownable {
    using SafeMath for uint256;
	using Address for address;

	IERC20 public _BUSD;
    SQFToken public _tokenSale;
	uint public _maxTokenSale;
	uint256 public _saledToken;
	bool public _saleStatus;
	uint256 public _tokenPrice;  // token pre-sale price in BUSD
	uint256 public _endSaleBlock ;
	uint256 public _openSaleBlock;
	uint256 public _minimum;
	address[] public _whiteList;
	uint[10] public _openBlockArr;
    mapping(address => uint256) public buyedToken;
	mapping(address => uint256) public buyedBUSD;
	mapping(address => uint256) public claimedPercent;
    
    constructor(address _token) public {
		_BUSD = IERC20(address(0x1482717Eb2eA8Ecd81d2d8C403CaCF87AcF04927));
		_tokenSale = SQFToken(_token) ;
		_maxTokenSale = 3.33333333333 * 10 ** 9 *10 ** 18;
		_saledToken = 0;
		_saleStatus = true;
		_tokenPrice = 3 * 10 ** 13;
		_minimum = 500 * 10 ** 18;
		_openSaleBlock = block.timestamp.add(35*60);
		_endSaleBlock = block.timestamp.add(30*24*60*60);
		_openBlockArr[0] = _endSaleBlock.add(6*60);
		_openBlockArr[1] = _endSaleBlock.add(7*60);
		_openBlockArr[2] = _endSaleBlock.add(8*60);
		_openBlockArr[3] = _endSaleBlock.add(9*60);
		_openBlockArr[4] = _endSaleBlock.add(10*60);
		_openBlockArr[5] = _endSaleBlock.add(11*60);
		_openBlockArr[6] = _endSaleBlock.add(12*60);
		_openBlockArr[7] = _endSaleBlock.add(13*60);
		_openBlockArr[8] = _endSaleBlock.add(14*60);
	}

	function buyByBUSD(uint256 _amount) public payable { 
		uint256 totalToken = _amount.div(_tokenPrice);
		require(_openSaleBlock < block.timestamp, "Seed round not availble now ");
		require(_endSaleBlock > block.timestamp , "Pre-sale ended .");
		require( _saledToken.add(totalToken * 10 ** 18) < _maxTokenSale , "Token soled out .");
		require(_amount > _minimum, "require minimum BUSD .");
		address payable owner = payable(this.owner());
		_BUSD.transferFrom(msg.sender, owner, _amount);
		_tokenSale.mintFrozenTokens(address(msg.sender), totalToken * 10 ** 18); 
		_tokenSale.meltTokens(address(msg.sender), (totalToken * 10 ** 18).mul(3).div(100));
		_saledToken = _saledToken.add(totalToken * 10 ** 18);
		buyedToken[msg.sender] = buyedToken[msg.sender].add(totalToken * 10 ** 18);
		buyedBUSD[msg.sender] = buyedBUSD[msg.sender].add(_amount);
		claimedPercent[msg.sender] = 3;
		emit BuySeedRound(address(msg.sender), totalToken);
	}

	function adminMintWhitelist(address recipient, uint256 _amount) public onlyOwner { 
		uint256 totalToken = _amount.div(_tokenPrice);
		_tokenSale.mintFrozenTokens(recipient, totalToken * 10 ** 18); 
		_tokenSale.meltTokens(recipient, (totalToken * 10 ** 18).mul(3).div(100));
		_saledToken = _saledToken.add(totalToken * 10 ** 18);
		buyedToken[recipient] = buyedToken[recipient].add(totalToken * 10 ** 18);
		buyedBUSD[recipient] = buyedBUSD[recipient].add(_amount);
		_whiteList.push(recipient);
		claimedPercent[recipient] = 3;
		emit BuySeedRound(address(msg.sender),totalToken);

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

	function adminUnlockWhiteList() public onlyOwner returns (bool)  {

		for (uint i = 0; i < _whiteList.length; i++) {
				uint256 checkPercent = checkTimeUnlockPercent();
				if(claimedPercent[_whiteList[i]] < 100 && checkPercent > claimedPercent[_whiteList[i]]) { 
					uint256 tokenUnlock = buyedToken[_whiteList[i]] * (checkPercent - claimedPercent[_whiteList[i]]) / 100;
					_tokenSale.meltTokens(address(_whiteList[i]), tokenUnlock );
					claimedPercent[_whiteList[i]] = claimedPercent[_whiteList[i]].add( (checkPercent - claimedPercent[_whiteList[i]]));
					emit UnlockSeedToken(_whiteList[i], tokenUnlock);
				}
        }
		
        return true;
	}

	function unlockToken() public returns (bool) {
		uint256 checkPercent = checkTimeUnlockPercent() ;
		require(claimedPercent[msg.sender] < 100, "No locked token");
		require(checkPercent > claimedPercent[msg.sender], "unlock maximum this time");

		uint256 tokenUnlock = buyedToken[msg.sender] * (checkPercent - claimedPercent[msg.sender]) / 100;
		_tokenSale.meltTokens(address(msg.sender), tokenUnlock );
		claimedPercent[msg.sender] = claimedPercent[msg.sender].add( (checkPercent - claimedPercent[msg.sender]) );
		emit UnlockSeedToken(msg.sender, tokenUnlock);
		return true;
	}

	function set_Price(uint256 tokenPrice) public onlyOwner {
		_tokenPrice = tokenPrice;
	}

	function set_SaleStatus(bool saleStatus) public onlyOwner {
		_saleStatus = saleStatus;
	}
 
    
    event BuySeedRound(address indexed user, uint256 amount);
	event UnlockSeedToken(address indexed user, uint256 amount);

}
