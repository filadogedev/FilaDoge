// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title FilaDoge, the first open-source peer-to-peer digital meme-token on Filecoin Virtual Machine (FEVM)
/// @author FilaDoge Dev
contract FilaDoge is ERC20 {
    uint _airDrop2Released;
    uint _hasRewardedInviters;
    uint _hasRewardedInviteeAmount;
    uint _lotteryReleasedAmount;
    uint _lotteryStartTime;
    address _owner;
    address[] _invitees;
    address[] _inviters;
    address[] _gamblers;
    mapping(address => bool) _hasBeenInvited;
    mapping(address => bool) _hasGambled;
    mapping(address => uint) _inviterRewards;
    mapping(address => uint) _inviteeRewards;
    mapping(address => uint) _gamblerRewards;

    //Token basics
    uint constant MAX_SUPPLY = 10 ** 12;
    uint constant RATIO_BASE = 10 ** 8;

    //InitialMint, 30%
    uint constant DONATION_COOP_POOL = MAX_SUPPLY * 1 / 5;
    uint constant FUTURE_EVENT_POOL = MAX_SUPPLY * 1 / 10;

    //Token airdrop 1, 6%
    uint constant AIRDROP_1_REWARD_PART_1 = 1 * MAX_SUPPLY / 200;
    uint constant AIRDROP_1_REWARD_PART_2 = 11 * MAX_SUPPLY / 200;

    //Token airdrop 2, 4%
    uint constant AIRDROP_2_SIZE = AIRDROP_2_TIER_4;
    uint constant AIRDROP_2_TIER_0 = 1;
    uint constant AIRDROP_2_TIER_0_REWARD = 440000 * MAX_SUPPLY / RATIO_BASE;
    uint constant AIRDROP_2_TIER_1 = 11;
    uint constant AIRDROP_2_TIER_1_REWARD = 32000 * MAX_SUPPLY / RATIO_BASE;
    uint constant AIRDROP_2_TIER_2 = 101;
    uint constant AIRDROP_2_TIER_2_REWARD = 16000 * MAX_SUPPLY / RATIO_BASE;
    uint constant AIRDROP_2_TIER_3 = 251;
    uint constant AIRDROP_2_TIER_3_REWARD = 8000 * MAX_SUPPLY / RATIO_BASE;
    uint constant AIRDROP_2_TIER_4 = 401;
    uint constant AIRDROP_2_TIER_4_REWARD = 4000 * MAX_SUPPLY / RATIO_BASE;

    //Inviter, 20%
    uint constant INVITER_REWARD = 40 * MAX_SUPPLY / RATIO_BASE;
    uint constant MAX_INVITATION = 500000;

    //Invitee, 20%
    uint constant INVITEE_REWARD_FACTOR_A = 50867653407 * MAX_SUPPLY / 10 ** 12;
    uint constant INVITEE_REWARD_FACTOR_B = 10000;

    //Lottery, 20%
    uint constant MIN_LOTTERY_REWARD = 1 * MAX_SUPPLY / RATIO_BASE;
    uint constant MAX_LOTTERY_REWARD = 100 * MAX_SUPPLY / RATIO_BASE;
    uint constant LOTTERY_POOL = MAX_SUPPLY / 5;

    struct ValuePair {
        address account;
        uint amount;
    }

    /**
     * @dev Sets the variables of token upon construction.
     *
     * Among these variables, `donation_coop_pool` stores tokens reserved for charity,
     * donation and collaborations, and `future_event_pool` stores tokens reserved for
     * future games and activities. `initialLotteryStartTime` indicates the timestamp
     * when lottery will be started.
     */
    constructor(
        string memory name,
        string memory symbol,
        address donation_coop_pool,
        address future_event_pool,
        uint initialLotteryStartTime
    ) ERC20(name, symbol) {
        _owner = _msgSender();
        _lotteryStartTime = initialLotteryStartTime;
        _mint(donation_coop_pool, _withDecimal(DONATION_COOP_POOL));
        _mint(future_event_pool, _withDecimal(FUTURE_EVENT_POOL));
    }

    /**
     * @dev First airdrop, rewards top 600 FIL holders* with 6% of the total supply.
     *
     * Due to limited knowledge of top FIL holders’ 0x or f4 addresses, this part of
     * airdrop will be allocated to the Protocol Lab as a lump sum and to be
     * re-distributed to FIL holders in the future.
     */
    function airDrop1 (address receiver1, address receiver2) onlyOwner public {
        _mint(receiver1, _withDecimal(AIRDROP_1_REWARD_PART_1));
        _mint(receiver2, _withDecimal(AIRDROP_1_REWARD_PART_2));
    }

    /**
     * @dev Second airdrop is for Vitalik and top 400 Eth holders (recorded from
     * etherscan.io at Mar. 14 2023 - 2:00AM UTC), with 4% of the total supply.
     */
    function airDrop2 (address[] memory receiverList) onlyOwner public returns (uint) {
        uint initial = _airDrop2Released;
        require (initial < AIRDROP_2_SIZE, "Has already accomplished before.");
        uint len = receiverList.length;
        require (initial + len <= AIRDROP_2_SIZE, "Invalid input address list length.");
        uint p = initial;
        for (; p < AIRDROP_2_TIER_0 && p - initial < len; p++) {
            _mint(receiverList[p - initial], _withDecimal(AIRDROP_2_TIER_0_REWARD));
        }
        for (; p < AIRDROP_2_TIER_1 && p - initial < len; p++) {
            _mint(receiverList[p - initial], _withDecimal(AIRDROP_2_TIER_1_REWARD));
        }
        for (; p < AIRDROP_2_TIER_2 && p - initial < len; p++) {
            _mint(receiverList[p - initial], _withDecimal(AIRDROP_2_TIER_2_REWARD));
        }
        for (; p < AIRDROP_2_TIER_3 && p - initial < len; p++) {
            _mint(receiverList[p - initial], _withDecimal(AIRDROP_2_TIER_3_REWARD));
        }
        for (; p < AIRDROP_2_TIER_4 && p - initial < len; p++) {
            _mint(receiverList[p - initial], _withDecimal(AIRDROP_2_TIER_4_REWARD));
        }
        _airDrop2Released = p;
        return p;
    }

    /**
     * @dev Mint tokens for `inviter` and `invitee` correspondingly.
     *
     * Early invitees will be able to mint their amount of FilaDoge token (FLD) from 20%
     * of total supply by filling in their f4 address. An f4 address converter will be
     * provided on the website to convert 0x addresses. The relationship between the FLD
     * token amount and the order of claim is described by the following mathematical model,
     * with the maximum of 500,000 addresses. The actual amount of FLD token received will
     * be integer as the decimal points will be rounded down.
     */
    function mint(
        address inviter,
        address invitee
    ) public returns (
        uint inviterReward,
        uint inviteeReward
    ) {
        require(_invitees.length < MAX_INVITATION, "Invitee pool has been exhausted.");
        require(inviter != invitee, "Inviter and your address cannot be the same one.");
        require(!_hasBeenInvited[invitee], "Your address has already been invited.");

        _hasBeenInvited[invitee] = true;
        _invitees.push(invitee);
        inviterReward = _rewardInviter(inviter);
        uint inviteeGrossReward = _inviteeReward(_invitees.length);
        _hasRewardedInviteeAmount += inviteeGrossReward;
        _inviteeRewards[invitee] = inviteeGrossReward;
        inviteeReward = _withDecimal(inviteeGrossReward);
        _mint(invitee, inviteeReward);
    }

    /**
     * @dev Participate lottery to win tokens for `invitee` and reward `inviter`.
     *
     * Users may participant in a lottery game by filling in their f4 address and claim
     * any random amount from 10,000 to 1,000,000 $FLD. The lottery game is concluded
     * as soon as 20% of total supply is drained up.
     */
    function lottery(
        address inviter,
        address gambler
    ) afterLotteryStartTime public returns (
        uint inviterReward,
        uint gamblerReward
    ) {
        require(_lotteryReleasedAmount < LOTTERY_POOL, "Lottery pool has been exhausted.");
        require(inviter != gambler, "Inviter and your address cannot be the same one.");
        require(!_hasGambled[gambler], "Your address has already gambled.");

        _hasGambled[gambler] = true;
        _gamblers.push(gambler);
        inviterReward = _rewardInviter(inviter);
        uint grossReward = _getRandom(gambler) % (MAX_LOTTERY_REWARD - MIN_LOTTERY_REWARD + 1) + MIN_LOTTERY_REWARD;
        if (_lotteryReleasedAmount + grossReward > LOTTERY_POOL) {
            grossReward = LOTTERY_POOL - _lotteryReleasedAmount;
        }
        _lotteryReleasedAmount += grossReward;
        _gamblerRewards[gambler] = grossReward;
        gamblerReward = _withDecimal(grossReward);
        _mint(gambler, gamblerReward);
    }

    /**
     * @dev Returns next invitee's reward.
     */
    function nextInviteeReward() public view returns (uint) {
        if (_invitees.length == MAX_INVITATION) return 0;
        return _withDecimal(_inviteeReward(_invitees.length + 1));
    }

    /**
     * @dev Returns inviters' addresses as well as rewards received correspondingly.
     */
    function hasRewardedInviterList() public view returns (ValuePair[] memory result) {
        result = new ValuePair[](_inviters.length); 
        for (uint i = 0; i < _inviters.length; i++) {
            address inviter = _inviters[i];
            result[i].account = inviter;
            result[i].amount = _withDecimal(_inviterRewards[inviter]);
        }
    }

    /**
     * @dev Returns invitees' addresses as well as rewards received correspondingly.
     */
    function hasRewardedInviteeList() public view returns (ValuePair[] memory result) {
        result = new ValuePair[](_invitees.length); 
        for (uint i = 0; i < _invitees.length; i++) {
            address invitee = _invitees[i];
            result[i].account = invitee;
            result[i].amount = _withDecimal(_inviteeRewards[invitee]);
        }
    }

    /**
     * @dev Returns gamblers' addresses as well as rewards received correspondingly.
     */
    function hasRewardedGamblerList() public view returns (ValuePair[] memory result) {
        result = new ValuePair[](_gamblers.length); 
        for (uint i = 0; i < _gamblers.length; i++) {
            address gambler = _gamblers[i];
            result[i].account = gambler;
            result[i].amount = _withDecimal(_gamblerRewards[gambler]);
        }
    }

    /**
     * @dev Returns currently released uints of inviter reward.
     */
    function hasRewardedInviters() public view returns (uint) {
        return _hasRewardedInviters;
    }

    /**
     * @dev Returns whether `invitee` has been invited.
     */
    function hasBeenInvited(address invitee) public view returns (bool) {
        return _hasBeenInvited[invitee];
    }

    /**
     * @dev Returns whether `gambler` has taken part in lottery game.
     */
    function hasGambled(address gambler) public view returns (bool) {
        return _hasGambled[gambler];
    }

    /**
     * @dev Returns currently released inviter reward amount in total.
     */
    function hasRewardedInviterAmount() public view returns (uint) {
        return _withDecimal(_hasRewardedInviters * INVITER_REWARD);
    }

    /**
     * @dev Returns currently released invitee reward amount in total.
     */
    function hasRewardedInviteeAmount() public view returns (uint) {
        return _withDecimal(_hasRewardedInviteeAmount);
    }

    /**
     * @dev Returns current number of invitees.
     */
    function hasRewardedInvitees() public view returns (uint) {
        return _invitees.length;
    }

    /**
     * @dev Returns current address list of invitees.
     */
    function inviteeList() public view returns (address[] memory) {
        return _invitees;
    }

    /**
     * @dev Returns currently released lottery reward amount in total.
     */
    function lotteryReleasedAmount() public view returns (uint) {
        return _withDecimal(_lotteryReleasedAmount);
    }

    /**
     * @dev Returns current number of gamblers.
     */
    function gamblers() public view returns (uint) {
        return _gamblers.length;
    }

    /**
     * @dev Returns current address list of gamblers.
     */
    function gamblerList() public view returns (address[] memory) {
        return _gamblers;
    }

    /**
     * @dev Returns inviter reward granted to `inviter`.
     */
    function inviterRewardReceived(address inviter) public view returns (uint) {
        return _withDecimal(_inviterRewards[inviter]);
    }

    /**
     * @dev Returns invitee reward granted to `invitee`.
     */
    function inviteeRewardReceived(address invitee) public view returns (uint) {
        return _withDecimal(_inviteeRewards[invitee]);
    }

    /**
     * @dev Returns gambler reward granted to `gambler`.
     */
    function gamblerRewardReceived(address gambler) public view returns (uint) {
        return _withDecimal(_gamblerRewards[gambler]);
    }

    /**
     * @dev Returns contract owner address.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns lottery start time. Lottery can only be played after this timestamp.
     */
    function lotteryStartTime() public view returns (uint) {
        return _lotteryStartTime;
    }

    /**
     * @dev Returns maximum token supply.
     */
    function maxSupply() public view returns (uint) {
        return _withDecimal(MAX_SUPPLY);
    }

    /**
     * @dev Change contract owner address to `newOwner`.
     *
     * We plan to change the contract owner address to a dead one (i.e. 0xdead) in the future.
     */
    function changeOwner(address newOwner) onlyOwner public returns (address) {
        _owner = newOwner;
        return _owner;
    }

    /**
     * @dev Change lottery start time to `newLotteryStartTime`.
     */
    function changeLotteryStartTime(uint newLotteryStartTime) onlyOwner public returns (uint) {
        _lotteryStartTime = newLotteryStartTime;
        return _lotteryStartTime;
    }

    /**
     * @dev Returns whether lottery has started.
     */
    function isLotteryStarted() public view returns (bool) {
        return block.timestamp >= _lotteryStartTime;
    }

    function _rewardInviter(address inviter) private returns (uint inviterReward) {
        if(_hasRewardedInviters < MAX_INVITATION || inviter == address(0)) {
            if (_inviterRewards[inviter] == 0) {
                _inviters.push(inviter);
            }
            _inviterRewards[inviter] += INVITER_REWARD;
            if(inviter != address(0)) {
                _hasRewardedInviters ++;
                inviterReward = _withDecimal(INVITER_REWARD);
                _mint(inviter, inviterReward);
            }
        }
    }

    function _inviteeReward(uint x) private pure returns (uint) {
        return INVITEE_REWARD_FACTOR_A / (x + INVITEE_REWARD_FACTOR_B);
    }

    function _getRandom(address input) private view returns (uint) {
        return uint256(uint160(input)) ^ block.prevrandao;
    }

    function _withDecimal(uint tokens) private view returns (uint) {
        return tokens * 10 ** decimals();
    }

    function _afterTokenTransfer(address, address, uint256) internal override view {
        require(totalSupply() <= _withDecimal(MAX_SUPPLY), "Total supply cannot exceed max supply.");
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Caller is restricted to the owner.");
        _;
    }

    modifier afterLotteryStartTime() {
        require(isLotteryStarted(), "Lottery has not started.");
        _;
    }
}
