// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
import "./Token.sol";


contract SupportLockToken is Ownable {

    using SafeMath for uint256;
	using Address for address;

    
    SQFToken public _mainToken;
    uint256 public _Note;
    uint256 public _totalSupply = 333.333333333*10**9*10**18;

	uint[24] public _openBlockArr;

    uint256 public _tokenForTeam;    
    uint256 public _tokenForPartner;    
    uint256 public _tokenForEcosystem;    
    uint256 public _tokenForReserve;    
    uint256 public _tokenForMarketing;
	uint256 public _tokenForLiquidity;    

    uint256 public _unlockedTokenForTeam;
    uint256 public _unlockedTokenForPartner;
    uint256 public _unlockedTokenForEcosystem;
    uint256 public _unlockedTokenForReserve;
    uint256 public _unlockedTokenForMarketing;
    uint256 public _unlockedTokenForLiquidity;


    bool _isMintedTeam = false;
    bool _isMintedPartner = false;
    bool _isMintedEcosystem = false;
    bool _isMintedReserve = false;
    bool _isMintedMarketing = false;
	bool _isMintedLiquidity = false;
 
 	mapping(string => uint256) public claimedPercent;
    
    constructor(address _token) public {
		_mainToken = SQFToken(_token);
        _tokenForTeam = _totalSupply.mul(10).div(100);
        _tokenForPartner = _totalSupply.mul(10).div(100);
        _tokenForEcosystem = _totalSupply.mul(20).div(100);
        _tokenForReserve = _totalSupply.mul(10).div(100);
        _tokenForMarketing = _totalSupply.mul(272).div(1000); 
        _tokenForLiquidity = _totalSupply.mul(80).div(1000); 
		_Note = block.timestamp;
		_openBlockArr[0] = _Note.add(60);
		_openBlockArr[1] = _Note.add(2*60);
		_openBlockArr[2] = _Note.add(3*60);
		_openBlockArr[3] = _Note.add(4*60);
		_openBlockArr[4] = _Note.add(5*60);
		_openBlockArr[5] = _Note.add(6*60);
		_openBlockArr[6] = _Note.add(7*60);
		_openBlockArr[7] = _Note.add(8*60);
		_openBlockArr[8] = _Note.add(9*60);
		_openBlockArr[9] = _Note.add(10*60); 
		_openBlockArr[10] = _Note.add(11*60);
		_openBlockArr[11] = _Note.add(12*60);
		_openBlockArr[12] = _Note.add(13*60);
		_openBlockArr[13] = _Note.add(14*60);
		_openBlockArr[14] = _Note.add(15*60);
		_openBlockArr[15] = _Note.add(16*60);
		_openBlockArr[16] = _Note.add(17*60);
		_openBlockArr[17] = _Note.add(18*60);
        _openBlockArr[18] = _Note.add(19*60);
		_openBlockArr[19] = _Note.add(20*60);
		_openBlockArr[20] = _Note.add(21*60);
		_openBlockArr[21] = _Note.add(22*60);
		_openBlockArr[22] = _Note.add(23*60);
		_openBlockArr[23] = _Note.add(24*60);

    }

    function mintTokenToTeam() public onlyOwner { 
        require(!_isMintedTeam, "Minted Token for Team");
		_mainToken.mintFrozenTokens(address(owner()), _tokenForTeam); 
		claimedPercent["Team"] = 0;
        _isMintedTeam = true;
		emit MintedToken(address(owner()), _tokenForTeam);
	}

    function mintTokenToPartner() public onlyOwner { 
        require(!_isMintedPartner, "Minted Token for Partner & Advisor");
		_mainToken.mintFrozenTokens(address(owner()), _tokenForPartner); 
		claimedPercent["Partner"] = 0;
        _isMintedPartner = true;
		emit MintedToken(address(owner()), _tokenForTeam);
	}

    function mintTokenToEcosystem() public onlyOwner { 
        require(!_isMintedEcosystem, "Minted Token for Ecosystem");
		_mainToken.mintFrozenTokens(address(owner()), _tokenForEcosystem); 
		claimedPercent["Ecosystem"] = 0;
        _isMintedEcosystem = true;
		emit MintedToken(address(owner()), _tokenForEcosystem);
	}

    function mintTokenToReserve() public onlyOwner { 
        require(!_isMintedReserve, "Minted Token for Reserve");
		_mainToken.mintFrozenTokens(address(owner()), _tokenForReserve); 
		claimedPercent["Reserve"] = 0;
        _isMintedReserve = true;
		emit MintedToken(address(owner()), _tokenForReserve);
	}

    function mintTokenToMarketing() public onlyOwner { 
        require(!_isMintedMarketing, "Minted Token for Marketing");
		_mainToken.mintFrozenTokens(address(owner()), _tokenForMarketing); 
		_mainToken.meltTokens(address(owner()), (_tokenForMarketing).mul(5).div(100));
		claimedPercent["Marketing"] = 10;
        _isMintedMarketing = true;
		emit MintedToken(address(owner()), _tokenForMarketing);


	}
	function mintTokenToLiquidity() public onlyOwner { 
        require(!_isMintedLiquidity, "Minted Token for Liquidity");
		_mainToken.mintFrozenTokens(address(owner()), _tokenForLiquidity); 
		_mainToken.meltTokens(address(owner()), (_tokenForLiquidity));
		claimedPercent["Liquidity"] = 100;
		_unlockedTokenForLiquidity = _unlockedTokenForLiquidity.add(_tokenForLiquidity);
        _isMintedLiquidity = true;
		emit MintedToken(address(owner()), _tokenForLiquidity);

	}

	function checkTimeUnlockPercent24Months() public view returns (uint256){
        
		uint256 checkNumber = block.timestamp;
		if(checkNumber < _openBlockArr[0]){
            return 0;
		}else if (_openBlockArr[0] <= checkNumber && checkNumber < _openBlockArr[1]){
			return 42;
		}else if (_openBlockArr[1] <= checkNumber && checkNumber < _openBlockArr[2]){
			return 84;
		}else if (_openBlockArr[2] <= checkNumber && checkNumber < _openBlockArr[3]){
			return 126;
		}else if (_openBlockArr[3] <= checkNumber && checkNumber < _openBlockArr[4]){
			return 168;
		}else if (_openBlockArr[4] <= checkNumber && checkNumber < _openBlockArr[5]){
			return 210;
		}else if (_openBlockArr[5] <= checkNumber && checkNumber < _openBlockArr[6]){
			return 252;
		}else if (_openBlockArr[6] <= checkNumber && checkNumber < _openBlockArr[7]){
			return 294;
		}else if (_openBlockArr[7] <= checkNumber && checkNumber < _openBlockArr[8]){
			return 336;
		}else if (_openBlockArr[8] <= checkNumber && checkNumber < _openBlockArr[9]){
			return 378;
		}else if (_openBlockArr[9] <= checkNumber && checkNumber < _openBlockArr[10]){
			return 420;
		}else if (_openBlockArr[10] <= checkNumber && checkNumber < _openBlockArr[11]){
			return 462;
		}else if (_openBlockArr[11] <= checkNumber && checkNumber < _openBlockArr[12]){
			return 504;
		}else if (_openBlockArr[12] <= checkNumber && checkNumber < _openBlockArr[13]){
			return 546;
		}else if (_openBlockArr[13] <= checkNumber && checkNumber < _openBlockArr[14]){
			return 588;
		}else if (_openBlockArr[14] <= checkNumber && checkNumber < _openBlockArr[15]){
			return 630;
		}else if (_openBlockArr[15] <= checkNumber && checkNumber < _openBlockArr[16]){
			return 672;
		}else if (_openBlockArr[16] <= checkNumber && checkNumber < _openBlockArr[17]){
			return 714;
		}else if (_openBlockArr[17] <= checkNumber && checkNumber < _openBlockArr[18]){
			return 756;
		}else if (_openBlockArr[18] <= checkNumber && checkNumber < _openBlockArr[19]){
			return 798;
		}else if (_openBlockArr[19] <= checkNumber && checkNumber < _openBlockArr[20]){
			return 840;
		}else if (_openBlockArr[20] <= checkNumber && checkNumber < _openBlockArr[21]){
			return 882;
		}else if (_openBlockArr[21] <= checkNumber && checkNumber < _openBlockArr[22]){
			return 924;
		}else if (_openBlockArr[22] <= checkNumber && checkNumber < _openBlockArr[23]){
			return 966;
		}else if (_openBlockArr[23] <= checkNumber ) {
			return 1000;
		}

	}

    function checkTimeUnlockPercentPartner() public view returns (uint256){
		uint256 checkNumber = block.timestamp;
		if(checkNumber < _openBlockArr[0]){
			return 0;
		}else if (_openBlockArr[0] <= checkNumber && checkNumber < _openBlockArr[1]){
			return 60;
		}else if (_openBlockArr[1] <= checkNumber && checkNumber < _openBlockArr[2]){
			return 154;
		}else if (_openBlockArr[2] <= checkNumber && checkNumber < _openBlockArr[3]){
			return 248;
		}else if (_openBlockArr[3] <= checkNumber && checkNumber < _openBlockArr[4]){
			return 342;
		}else if (_openBlockArr[4] <= checkNumber && checkNumber < _openBlockArr[5]){
			return 463;
		}else if (_openBlockArr[5] <= checkNumber && checkNumber < _openBlockArr[6]){
			return 530;
		}else if (_openBlockArr[6] <= checkNumber && checkNumber < _openBlockArr[7]){
			return 642;
		}else if (_openBlockArr[7] <= checkNumber && checkNumber < _openBlockArr[8]){
			return 718;
		}else if (_openBlockArr[8] <= checkNumber && checkNumber < _openBlockArr[9]){
			return 812;
		}else if (_openBlockArr[9] <= checkNumber && checkNumber < _openBlockArr[10]){
			return 906;
		}else if (_openBlockArr[10] <= checkNumber ){
			return 1000;
		}
    }

    function checkTimeUnlockPercentReserve() public view returns (uint256){
		uint256 checkNumber = block.timestamp;
		if(checkNumber < _openBlockArr[0]){
			return 0;
		}else if (_openBlockArr[0] <= checkNumber && checkNumber < _openBlockArr[1]){
			return 15;
		}else if (_openBlockArr[1] <= checkNumber && checkNumber < _openBlockArr[2]){
			return 22;
		}else if (_openBlockArr[2] <= checkNumber && checkNumber < _openBlockArr[3]){
			return 29;
		}else if (_openBlockArr[3] <= checkNumber && checkNumber < _openBlockArr[4]){
			return 36;
		}else if (_openBlockArr[4] <= checkNumber && checkNumber < _openBlockArr[5]){
			return 43;
		}else if (_openBlockArr[5] <= checkNumber && checkNumber < _openBlockArr[6]){
			return 50;
		}else if (_openBlockArr[6] <= checkNumber && checkNumber < _openBlockArr[7]){
			return 57;
		}else if (_openBlockArr[7] <= checkNumber && checkNumber < _openBlockArr[8]){
			return 64;
		}else if (_openBlockArr[8] <= checkNumber && checkNumber < _openBlockArr[9]){
			return 71;
		}else if (_openBlockArr[9] <= checkNumber && checkNumber < _openBlockArr[10]){
			return 78;
		}else if (_openBlockArr[10] <= checkNumber && checkNumber < _openBlockArr[11]){
			return 85;
		}else if (_openBlockArr[11] <= checkNumber && checkNumber < _openBlockArr[12]){
			return 92;
		}else if (_openBlockArr[12] <= checkNumber ){
			return 100;
		}
    }

    function checkTimeUnlockPercentMarketing() public view returns (uint256){
		uint256 checkNumber = block.timestamp;
		if(checkNumber < _openBlockArr[0]){
			return 10;
		}else if (_openBlockArr[0] <= checkNumber && checkNumber < _openBlockArr[1]){
			return 20;
		}else if (_openBlockArr[1] <= checkNumber && checkNumber < _openBlockArr[2]){
			return 28;
		}else if (_openBlockArr[2] <= checkNumber && checkNumber < _openBlockArr[3]){
			return 36;
		}else if (_openBlockArr[3] <= checkNumber && checkNumber < _openBlockArr[4]){
			return 44;
		}else if (_openBlockArr[4] <= checkNumber && checkNumber < _openBlockArr[5]){
			return 52;
		}else if (_openBlockArr[5] <= checkNumber && checkNumber < _openBlockArr[6]){
			return 60;
		}else if (_openBlockArr[6] <= checkNumber && checkNumber < _openBlockArr[7]){
			return 68;
		}else if (_openBlockArr[7] <= checkNumber && checkNumber < _openBlockArr[8]){
			return 76;
		}else if (_openBlockArr[8] <= checkNumber && checkNumber < _openBlockArr[9]){
			return 84;
		}else if (_openBlockArr[9] <= checkNumber && checkNumber < _openBlockArr[10]){
			return 92;
		}else if (_openBlockArr[10] <= checkNumber ) { 
            return 100;
        }
    }


	function unlockTokenTeam() public onlyOwner returns (bool) {
		uint256 checkPercent = checkTimeUnlockPercent24Months() ;
		require(claimedPercent["Team"] < 1000, "No locked token");
		require(checkPercent > claimedPercent["Team"], "unlock maximum this time");
		uint256 tokenUnlock = _tokenForTeam * (checkPercent - claimedPercent["Team"]) / 1000;
		_mainToken.meltTokens(address(owner()), tokenUnlock );
        _unlockedTokenForTeam = _unlockedTokenForTeam.add(tokenUnlock);
		claimedPercent["Team"] = claimedPercent["Team"].add((checkPercent - claimedPercent["Team"]));
		emit UnlockSeedToken(msg.sender, tokenUnlock);
		return true;
	}
    
    function unlockTokenPartner() public onlyOwner returns (bool) {
		uint256 checkPercent = checkTimeUnlockPercentPartner() ;
		require(claimedPercent["Partner"] < 1000, "No locked token");
		require(checkPercent > claimedPercent["Partner"], "unlock maximum this time");
		uint256 tokenUnlock = _tokenForPartner * (checkPercent - claimedPercent["Partner"]) / 1000;
		_mainToken.meltTokens(address(owner()), tokenUnlock );
        _unlockedTokenForPartner = _unlockedTokenForPartner.add(tokenUnlock);
		claimedPercent["Partner"] = claimedPercent["Partner"].add((checkPercent - claimedPercent["Partner"]));
		emit UnlockSeedToken(msg.sender, tokenUnlock);
		return true;
	}

    function unlockTokenEcosystem() public onlyOwner returns (bool) {
		uint256 checkPercent = checkTimeUnlockPercent24Months() ;
		require(claimedPercent["Ecosystem"] < 1000, "No locked token");
		require(checkPercent > claimedPercent["Ecosystem"], "unlock maximum this time");
		uint256 tokenUnlock = _tokenForEcosystem * (checkPercent - claimedPercent["Ecosystem"]) / 1000;
		_mainToken.meltTokens(address(owner()), tokenUnlock );
        _unlockedTokenForEcosystem = _unlockedTokenForEcosystem.add(tokenUnlock);
		claimedPercent["Ecosystem"] = claimedPercent["Ecosystem"].add((checkPercent - claimedPercent["Ecosystem"]));
		emit UnlockSeedToken(msg.sender, tokenUnlock);
		return true;
	}

    function unlockTokenReserve() public onlyOwner returns (bool) {
		uint256 checkPercent = checkTimeUnlockPercentReserve() ;
		require(claimedPercent["Reserve"] < 100, "No locked token");
		require(checkPercent > claimedPercent["Reserve"], "unlock maximum this time");
		uint256 tokenUnlock = _tokenForReserve * (checkPercent - claimedPercent["Reserve"]) / 100;
		_mainToken.meltTokens(address(owner()), tokenUnlock );
        _unlockedTokenForReserve = _unlockedTokenForReserve.add(tokenUnlock);
		claimedPercent["Reserve"] = claimedPercent["Reserve"].add((checkPercent - claimedPercent["Reserve"]));
		emit UnlockSeedToken(msg.sender, tokenUnlock);
		return true;
	}

    function unlockTokenMarketing() public onlyOwner returns (bool) {
		uint256 checkPercent = checkTimeUnlockPercentMarketing() ;
		require(claimedPercent["Marketing"] < 100, "No locked token");
		require(checkPercent > claimedPercent["Marketing"], "unlock maximum this time");
		uint256 tokenUnlock = _tokenForMarketing * (checkPercent - claimedPercent["Marketing"]) / 100;
		_mainToken.meltTokens(address(owner()), tokenUnlock );
        _unlockedTokenForMarketing = _unlockedTokenForMarketing.add(tokenUnlock);
		claimedPercent["Marketing"] = claimedPercent["Marketing"].add((checkPercent - claimedPercent["Marketing"]));
		emit UnlockSeedToken(msg.sender, tokenUnlock);
		return true;
	}

    event MintedToken(address indexed user, uint256 amount);
	event UnlockSeedToken(address indexed user, uint256 amount);
}