// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Auction {
    address public owner;
    uint256 public auctionEndTime;
    uint256 public maxParticipants;
    uint256 public participantCount;

    IERC20 public coinToken;

    struct Participant {
        uint256 reserveAmount;
        bool active;
    }

    mapping(address => Participant) public participants;
    uint256 public totalReserve;

    bool public ended;

    event ParticipantJoined(address participant, uint256 reserveAmount);
    event AuctionEnded();

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyBeforeEnd() {
        require(!ended, "Auction has already ended.");
        require(block.timestamp < auctionEndTime, "Auction has already ended.");
        _;
    }

    constructor(address _coinToken, uint256 _duration, uint256 _maxParticipants) {
        owner = msg.sender;
        coinToken = IERC20(_coinToken); 
        auctionEndTime = block.timestamp + _duration;
        maxParticipants = _maxParticipants;
    }

    function joinAuction(uint256 reserveAmount) external onlyBeforeEnd {
        require(!participants[msg.sender].active, "You have already joined the auction.");
        require(participantCount < maxParticipants, "Auction is full.");
        require(reserveAmount > 0, "Reserve amount must be greater than zero.");

        participants[msg.sender] = Participant({
            reserveAmount: reserveAmount,
            active: true
        });

        totalReserve += reserveAmount;
        participantCount++;

        coinToken.transferFrom(msg.sender, address(this), reserveAmount);

        emit ParticipantJoined(msg.sender, reserveAmount);
    }

    function endAuction() external onlyOwner onlyBeforeEnd {
        ended = true;
        emit AuctionEnded();
    }

    function getTotalReserve() external view returns (uint256) {
        return totalReserve;
    }
}
