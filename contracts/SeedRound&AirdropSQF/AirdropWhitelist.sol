// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
import "./Token.sol";


contract Airdrop is Ownable {

    using SafeMath for uint256;
	using Address for address;

    SQFToken public _mainToken;
	uint256 public _maxTokenAirdrop;
	uint256 public _droppedToken;  // token pre-sale price in BNB
    address[] public whiteList;

    mapping(address => bool) public isWhiteList;
    mapping(address => bool) public isClaimed;
    mapping(address => bool) public isTopRefferal;

    event LogWhitelisted(address _investor, uint256 _timestamp);
    event logTopRefferal(address _investor, uint256 _timestamp);
    
    constructor(address _token) public {
		_mainToken = SQFToken(_token);
		_maxTokenAirdrop = 2*10**4*10**18;
		_droppedToken = 0;
    }


    function whitelist(address[] calldata _investorAddresses) external onlyOwner {
        for (uint i = 0; i < _investorAddresses.length; i++) {
            if(!isWhiteList[_investorAddresses[i]]) { 
                isWhiteList[_investorAddresses[i]] = true;
                isClaimed[_investorAddresses[i]] = false;
            }
            emit LogWhitelisted(_investorAddresses[i], now);
        }
    }

    function claimTokens() external {
        require(isWhiteList[msg.sender], "Can't perform airdrop !");
        require(!isClaimed[msg.sender], "Claimed Token");
        isClaimed[msg.sender] = true;
        // Token.transfer(msg.sender, 1000);
    } 

    function checkWhiteList(address hehe) public view returns(bool) { 
        return isWhiteList[hehe];
    }

    function checkClaimed(address hehe ) public view returns (bool) { 
        return isClaimed[hehe];
    }


    function dropTokens(address[] memory _recipients, uint256[] memory _amount) public onlyOwner returns (bool) {
       
        for (uint i = 0; i < _recipients.length; i++) {
            require(_recipients[i] != address(0));
            require(_mainToken.transfer(_recipients[i], _amount[i]));
        }

        return true;
    }
}
// ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
