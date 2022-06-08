// SPDX-License-Identifier: GPLv2

pragma solidity ^0.8.2;


import "./IGenenisNFT.sol";
import "./SafeMath.sol";
import "./IERC20.sol";
import "./Ownable.sol";

contract GenesisStaking is Ownable {
    using SafeMath for uint256;
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    IERC20 public rewardsToken;
    IGenenisNFT public genesisNFT;

    /// @notice total ethereum staked currently in the gensesis staking contract
    uint256 public lastUpdateTime;


    uint256 public tokenPrice;

    /**
    @notice Struct to track what user is staking which tokens
    @dev tokenIds are all the tokens staked by the staker
    @dev balance is the current ether balance of the staker
    @dev rewardsEarned is the total reward for the staker till now
    @dev rewardsReleased is how much reward has been paid to the staker
    */

    struct nftsStaked { 
        uint256 tokenId;
        uint256 stakeTime;
        uint256 startStake;
        uint256 rewards;
        address owner;
    }

    struct Staker {
        uint256[] tokenIds;
        mapping (uint256 => uint256) tokenIndex;
        uint256 totalRewardsRelease;
    }

    /// Mapping from rarity to rewards

    mapping (uint256 => uint256 ) public percentRewards;
    mapping (uint256 => uint256 ) public priceByRarity;

    /// Mapping token stake one times;
    
    mapping (uint256 => bool) public isStaked;

    /// @notice mapping of a staker to its current properties
    mapping (address => Staker) public stakers;
    mapping (uint256 => nftsStaked) public nftStaked;
    mapping (address => mapping(uint256 => nftsStaked ) ) public stakedNftByOwner;

    // Mapping from token ID to owner address
    mapping (uint256 => address) public tokenOwner;

    /// @notice tokenId => amount contributed
    mapping (uint256 => uint256) public contribution;

    /// @notice sets the token to be claimable or not, cannot claim if it set to false
    bool public tokensClaimable;
    bool initialised;

    /// @notice event emitted when a user has staked a token
    event Staked(address owner, uint256 amount);

    /// @notice event emitted when a user has unstaked a token
    event Unstaked(address owner, uint256 amount);

    /// @notice event emitted when a user claims reward
    event RewardPaid(address indexed user, uint256 reward);
    
    /// @notice Allows reward tokens to be claimed
    event ClaimableStatusUpdated(bool status);

    /// @notice Emergency unstake tokens without rewards
    event EmergencyUnstake(address indexed user, uint256 tokenId);

    // @notice event emitted when a contributors amount is increased
    event ContributionIncreased(
        uint256 indexed tokenId,
        uint256 contribution
    );

    constructor(address _mainToken, address _mainNFT) public {
        rewardsToken = IERC20(_mainToken);
        genesisNFT = IGenenisNFT(_mainNFT);
        
    }

    function setTokenPrice(uint256 price) public onlyOwner { 
        require(price > 0, "Price isn't valid ");

        tokenPrice = price;

    }

     /**`
     * @dev Single gateway to intialize the staking contract after deploying
     * @dev Sets the contract with the MONA genesis NFT and MONA reward token 
     */
    function initGenesisStaking(
        address payable _fundsMultisig,
        IERC20 _rewardsToken,
        IGenenisNFT _genesisNFT
    )
        public
    {
        require(!initialised, "Already initialised");
        rewardsToken = _rewardsToken;
        genesisNFT = _genesisNFT;
        lastUpdateTime = block.timestamp;
        initialised = true;
    }


    function setTokensClaimable(
        bool _enabled
    )
        external
    {
        tokensClaimable = _enabled;
        emit ClaimableStatusUpdated(_enabled);
    }

    /// @dev Getter functions for Staking contract
    /// @dev Get the tokens staked by a user
    function getStakedTokens(
        address _user
    )
        external
        view
        returns (uint256[] memory tokenIds)
    {
        return stakers[_user].tokenIds;
    }


    /// @dev Get the amount a staked nft is valued at ie bought at

    function getTigerRarity(uint256 tokenId) public view returns (IGenenisNFT.nftRarity) { 
        IGenenisNFT.GenesisNFTStruct memory _tigerDna = genesisNFT.tigerDna(tokenId);
        return _tigerDna.rarity;
    }


    function setPercentEarnByRarity(uint256 rarity,uint256 percent) public onlyOwner{
        require(rarity <= 2, "Undefined Rarity");
        require(percent > 0, "inValid Percent" );
        percentRewards[rarity] = percent;
    }

    ///@dev calculator amount can get when stake nfts by Rarity ( price ) 
    function setPriceByRarity(
        uint256 rarity,
        uint256 price 
    ) public onlyOwner { 
        require(rarity <= 2, "Undefined Rarity");
        require(price > 0, "inValid price" );
        priceByRarity[rarity] = price * 10 ** 18;
    }

    function getRewardsByRarity( 
        uint256 rarity
    )
        public 
        view
        returns (uint256 amount) { 

        require(rarity <= 2, "Undefined Rarity");

        uint256 rewardsByRarity = (priceByRarity[rarity].mul(percentRewards[rarity]).div(100)).div(tokenPrice);

        return rewardsByRarity;
        
    }

    function getStakedNFTInfo(address _user, uint256 _tokenId) public view returns (uint256 stakeMonth,uint256 blockStake ,uint256 rewards) { 
        nftsStaked storage x = stakedNftByOwner[_user][_tokenId];
        return (
            x.stakeTime,
            x.startStake,
            x.rewards
        );
    }


    /// @notice Stake Genesis MONA NFT and earn reward tokens. 

    function stake(
        uint256 tokenId,
        uint256 time
    )
        external
    {
        require(isStaked[tokenId] == false, "staked NFTs");
        require(genesisNFT.ownerOf(tokenId) == msg.sender, "Only NFT's owner can stake !");
        _stake(msg.sender, tokenId,time);
    }

    /// @notice Stake all your MONA NFTs and earn reward tokens. 
    function stakeAll(uint256 time)
        external
    {
        uint256 balance = genesisNFT.balanceOf(msg.sender);
        for (uint i = 0; i < balance; i++) {
            _stake(msg.sender, genesisNFT.tokenOwnerByIndex(msg.sender,i),time);
        }
    }

    /**
     * @dev All the staking goes through this function
     * @dev Rewards to be given out is calculated
     * @dev Balance of stakers are updated as they stake the nfts based on ether price
    */
    function _stake(
        address _user,
        uint256 _tokenId,
        uint256 time
    )
        internal
    {
        Staker storage staker = stakers[_user];
        nftsStaked storage nftStake = nftStaked[_tokenId];

    // Get NFTs stake info.

    uint8 _tigerRarity = uint8(getTigerRarity(_tokenId));

    uint256 rewards = getRewardsByRarity(_tigerRarity);


    /// update stake nft info

        nftStake.tokenId = _tokenId;
        nftStake.stakeTime = time;
        nftStake.startStake = block.timestamp;
        nftStake.rewards = rewards;
        nftStake.owner = _user;

    // Update staker info

        staker.tokenIds.push(_tokenId);
        staker.tokenIndex[staker.tokenIds.length - 1];
        tokenOwner[_tokenId] = _user;
        stakedNftByOwner[_user][_tokenId] = nftStake;
        isStaked[_tokenId] = true;

        genesisNFT.safeTransferFrom(
            _user,
            address(this),
            _tokenId
        );


        emit Staked(_user, _tokenId);
    }

    /// @notice Unstake Genesis MONA NFTs. 
    function unstake(
        uint256 _tokenId
    ) 
        external 
    {
        require(
            tokenOwner[_tokenId] == msg.sender,
            "GenesisStaking._unstake: Sender must have staked tokenID"
        );
        _unstake(msg.sender, _tokenId);
    }

    /// @notice Stake multiple Genesis NFTs and claim reward tokens. 

     /**
     * @dev All the unstaking goes through this function
     * @dev Rewards to be given out is calculated
     * @dev Balance of stakers are updated as they unstake the nfts based on ether price
    */

    function _unstake(
        address _user,
        uint256 _tokenId
    ) 
        internal 
    {

        Staker storage staker = stakers[_user];
        uint256 lastIndex = staker.tokenIds.length - 1;
        uint256 lastIndexKey = staker.tokenIds[lastIndex];
        staker.tokenIds[staker.tokenIndex[_tokenId]] = lastIndexKey;
        staker.tokenIndex[lastIndexKey] = staker.tokenIndex[_tokenId];
        if (staker.tokenIds.length > 0) {
            staker.tokenIds.pop();
            delete staker.tokenIndex[_tokenId];
        }

        if (staker.tokenIds.length == 0) {
            delete stakers[_user];
        }

        delete nftStaked[_tokenId];
        delete tokenOwner[_tokenId];
        delete stakedNftByOwner[_user][_tokenId];

        genesisNFT.safeTransferFrom(
            address(this),
            _user,
            _tokenId
        );

        emit Unstaked(_user, _tokenId);

    }


    // Unstake without caring about rewards. EMERGENCY ONLY.
    
    function emergencyUnstake(uint256 _tokenId) external {
        require(
            tokenOwner[_tokenId] == msg.sender,
            "GenesisStaking._unstake: Sender must have staked tokenID"
        );
        _unstake(msg.sender, _tokenId);
        emit EmergencyUnstake(msg.sender, _tokenId);

    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata data
    )
        public pure returns(bytes4)
    {
        return _ERC721_RECEIVED;
    }



}