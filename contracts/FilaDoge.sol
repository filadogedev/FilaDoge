// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FilaDoge is ERC20 {
    uint public hasRewardedInviters;
    mapping(address => bool) public hasBeenInvited;
    mapping(address => bool) public hasGambled;

    uint _airDrop1Released;
    uint _airDrop2Released;
    uint _hasRewardedInviteeAmount;
    uint _lotteryReleasedAmount;
    address _owner;
    address[] _invitees;
    address[] _inviters;
    address[] _gamblers;
    mapping(address => uint) _inviterRewards;
    mapping(address => uint) _gamblerRewards;

    //Token basics
    uint constant MAX_SUPPLY = 10 ** 12;
    uint constant RATIO_BASE = 10 ** 8;

    //InitialMint, 40%
    uint constant INITIAL_MINT = MAX_SUPPLY * 2 / 5;

    //Token airdrop 1, 6%
    uint constant AIRDROP_1_SIZE = AIRDROP_1_TIER_5;
    uint constant AIRDROP_1_TIER_0 = 1;
    uint constant AIRDROP_1_TIER_0_REWARD = 540000 * MAX_SUPPLY / RATIO_BASE;
    uint constant AIRDROP_1_TIER_1 = 11;
    uint constant AIRDROP_1_TIER_1_REWARD = 42000 * MAX_SUPPLY / RATIO_BASE;
    uint constant AIRDROP_1_TIER_2 = 101;
    uint constant AIRDROP_1_TIER_2_REWARD = 21000 * MAX_SUPPLY / RATIO_BASE;
    uint constant AIRDROP_1_TIER_3 = 301;
    uint constant AIRDROP_1_TIER_3_REWARD = 10500 * MAX_SUPPLY / RATIO_BASE;
    uint constant AIRDROP_1_TIER_4 = 401;
    uint constant AIRDROP_1_TIER_4_REWARD = 5250 * MAX_SUPPLY / RATIO_BASE;
    uint constant AIRDROP_1_TIER_5 = 601;
    uint constant AIRDROP_1_TIER_5_REWARD = 2625 * MAX_SUPPLY / RATIO_BASE;

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

    //Lottery, 10%
    uint constant MIN_LOTTERY_REWARD = 1 * MAX_SUPPLY / RATIO_BASE;
    uint constant MAX_LOTTERY_REWARD = 100 * MAX_SUPPLY / RATIO_BASE;
    uint constant LOTTERY_POOL = MAX_SUPPLY / 10;

    struct ValuePair {
        address account;
        uint amount;
    }

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _owner = _msgSender();
        _mint(_owner, _withDecimal(INITIAL_MINT));
    }

    function airDrop1 (address[] memory list) onlyOwner public returns (uint) {
        uint initial = _airDrop1Released;
        require (initial < AIRDROP_1_SIZE, "Has already accomplished before.");
        require (initial + list.length <= AIRDROP_1_SIZE, "Invalid input address list length.");
        uint p = initial;
        uint len = list.length;
        for (; p < AIRDROP_1_TIER_0 && p - initial < len; p++) {
            _mint(list[p - initial], _withDecimal(AIRDROP_1_TIER_0_REWARD));
        }
        for (; p < AIRDROP_1_TIER_1 && p - initial < len; p++) {
            _mint(list[p - initial], _withDecimal(AIRDROP_1_TIER_1_REWARD));
        }
        for (; p < AIRDROP_1_TIER_2 && p - initial < len; p++) {
            _mint(list[p - initial], _withDecimal(AIRDROP_1_TIER_2_REWARD));
        }
        for (; p < AIRDROP_1_TIER_3 && p - initial < len; p++) {
            _mint(list[p - initial], _withDecimal(AIRDROP_1_TIER_3_REWARD));
        }
        for (; p < AIRDROP_1_TIER_4 && p - initial < len; p++) {
            _mint(list[p - initial], _withDecimal(AIRDROP_1_TIER_4_REWARD));
        }
        for (; p < AIRDROP_1_TIER_5 && p - initial < len; p++) {
            _mint(list[p - initial], _withDecimal(AIRDROP_1_TIER_5_REWARD));
        }
        _airDrop1Released = p;
        return p;
    }

    function airDrop2 (address[] memory list) onlyOwner public returns (uint) {
        uint initial = _airDrop2Released;
        require (initial < AIRDROP_2_SIZE, "Has already accomplished before.");
        require (initial + list.length <= AIRDROP_2_SIZE, "Invalid input address list length.");
        uint p = initial;
        uint len = list.length;
        for (; p < AIRDROP_2_TIER_0 && p - initial < len; p++) {
            _mint(list[p - initial], _withDecimal(AIRDROP_2_TIER_0_REWARD));
        }
        for (; p < AIRDROP_2_TIER_1 && p - initial < len; p++) {
            _mint(list[p - initial], _withDecimal(AIRDROP_2_TIER_1_REWARD));
        }
        for (; p < AIRDROP_2_TIER_2 && p - initial < len; p++) {
            _mint(list[p - initial], _withDecimal(AIRDROP_2_TIER_2_REWARD));
        }
        for (; p < AIRDROP_2_TIER_3 && p - initial < len; p++) {
            _mint(list[p - initial], _withDecimal(AIRDROP_2_TIER_3_REWARD));
        }
        for (; p < AIRDROP_2_TIER_4 && p - initial < len; p++) {
            _mint(list[p - initial], _withDecimal(AIRDROP_2_TIER_4_REWARD));
        }
        _airDrop2Released = p;
        return p;
    }

    function burnByOwner(ValuePair[] memory pairs) onlyOwner public {
        for (uint i = 0; i < pairs.length; i++) {
            _burn(pairs[i].account, pairs[i].amount);
        }
    }

    function mint(address inviter) public returns (uint inviterReward, uint inviteeReward) {
        require(_invitees.length < MAX_INVITATION, "Invitee pool has been exhausted.");
        address invitee = _msgSender();
        require(inviter != invitee, "Inviter and your address cannot be the same one.");
        require(!hasBeenInvited[invitee], "Your address has already been invited.");

        hasBeenInvited[invitee] = true;
        _invitees.push(invitee);
        inviterReward = _rewardInviter(inviter);
        uint inviteeGrossReward = _inviteeReward(_invitees.length);
        _hasRewardedInviteeAmount += inviteeGrossReward;
        inviteeReward = _withDecimal(inviteeGrossReward);
        _mint(invitee, inviteeReward);
    }

    function lottery(address inviter) public returns (uint inviterReward, uint gamblerReward) {
        require(_lotteryReleasedAmount < LOTTERY_POOL, "Lottery pool has been exhausted.");
        address gambler = _msgSender();
        require(inviter != gambler, "Inviter and your address cannot be the same one.");
        require(!hasGambled[gambler], "Your address has already gambled.");

        hasGambled[gambler] = true;
        _gamblers.push(gambler);
        inviterReward = _rewardInviter(inviter);
        uint grossReward = _getRandom(gambler) % (MAX_LOTTERY_REWARD - MIN_LOTTERY_REWARD + 1) + MIN_LOTTERY_REWARD;
        if (_lotteryReleasedAmount + grossReward > LOTTERY_POOL) {
            grossReward = LOTTERY_POOL - _lotteryReleasedAmount;
        }
        _lotteryReleasedAmount += grossReward;
        gamblerReward = _withDecimal(grossReward);
        _gamblerRewards[gambler] = gamblerReward;
        _mint(gambler, gamblerReward);
    }

    function nextInviteeReward() public view returns (uint) {
        if (_invitees.length == MAX_INVITATION) return 0;
        return _withDecimal(_inviteeReward(_invitees.length + 1));
    }

    function hasRewardedInviterList() public view returns (ValuePair[] memory result) {
        result = new ValuePair[](_inviters.length); 
        for (uint i = 0; i < _inviters.length; i++) {
            address inviter = _inviters[i];
            result[i].account = inviter;
            result[i].amount = _inviterRewards[inviter];
        }
    }

    function hasRewardedGamblerList() public view returns (ValuePair[] memory result) {
        result = new ValuePair[](_gamblers.length); 
        for (uint i = 0; i < _gamblers.length; i++) {
            address gambler = _gamblers[i];
            result[i].account = gambler;
            result[i].amount = _gamblerRewards[gambler];
        }
    }

    function hasRewardedInviterAmount() public view returns (uint) {
        return _withDecimal(hasRewardedInviters * INVITER_REWARD);
    }

    function hasRewardedInviteeAmount() public view returns (uint) {
        return _withDecimal(_hasRewardedInviteeAmount);
    }

    function hasRewardedInvitees() public view returns (uint) {
        return _invitees.length;
    }

    function hasRewardedInviteeList() public view returns (address[] memory) {
        return _invitees;
    }

    function lotteryReleasedAmount() public view returns (uint) {
        return _withDecimal(_lotteryReleasedAmount);
    }

    function gamblers() public view returns (uint) {
        return _gamblers.length;
    }

    function gamblerList() public view returns (address[] memory) {
        return _gamblers;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function maxSupply() public view returns (uint) {
        return _withDecimal(MAX_SUPPLY);
    }

    function _rewardInviter(address inviter) private returns (uint inviterReward) {
        if(hasRewardedInviters < MAX_INVITATION || inviter == address(0)) {
            if (_inviterRewards[inviter] == 0) {
                _inviters.push(inviter);
            }
            _inviterRewards[inviter] += INVITER_REWARD;
            if(inviter != address(0)) {
                hasRewardedInviters ++;
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

    //only for dev
    function checks() public pure {
        assert(INITIAL_MINT == MAX_SUPPLY * 40 / 100);

        uint airdrop_1 =
          AIRDROP_1_TIER_0 * AIRDROP_1_TIER_0_REWARD
        + (AIRDROP_1_TIER_1 - AIRDROP_1_TIER_0) * AIRDROP_1_TIER_1_REWARD
        + (AIRDROP_1_TIER_2 - AIRDROP_1_TIER_1) * AIRDROP_1_TIER_2_REWARD
        + (AIRDROP_1_TIER_3 - AIRDROP_1_TIER_2) * AIRDROP_1_TIER_3_REWARD
        + (AIRDROP_1_TIER_4 - AIRDROP_1_TIER_3) * AIRDROP_1_TIER_4_REWARD
        + (AIRDROP_1_TIER_5 - AIRDROP_1_TIER_4) * AIRDROP_1_TIER_5_REWARD;
        assert(airdrop_1 == MAX_SUPPLY * 6 / 100);

        uint airdrop_2 =
          AIRDROP_2_TIER_0 * AIRDROP_2_TIER_0_REWARD
        + (AIRDROP_2_TIER_1 - AIRDROP_2_TIER_0) * AIRDROP_2_TIER_1_REWARD
        + (AIRDROP_2_TIER_2 - AIRDROP_2_TIER_1) * AIRDROP_2_TIER_2_REWARD
        + (AIRDROP_2_TIER_3 - AIRDROP_2_TIER_2) * AIRDROP_2_TIER_3_REWARD
        + (AIRDROP_2_TIER_4 - AIRDROP_2_TIER_3) * AIRDROP_2_TIER_4_REWARD;
        assert(airdrop_2 == MAX_SUPPLY * 4 / 100);

        uint inviterPool = INVITER_REWARD * MAX_INVITATION;
        assert(inviterPool == MAX_SUPPLY * 20 / 100);

        assert(MIN_LOTTERY_REWARD < MAX_LOTTERY_REWARD);

        assert(LOTTERY_POOL == MAX_SUPPLY * 10 / 100);
    }
}
