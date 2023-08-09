// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./DetermineWinner.sol";

contract Auction {
    WinnerDetermination public winnerDeterminationInstance;  // Instance of WinnerDetermination
    address public owner;
    uint256 public auctionEndTime;
    uint256 public maxParticipants;
    uint256 public participantCount;
    uint256[] public reserveAmounts; // Array to store reserve amounts

    IERC20 public coinToken;
    IERC1155 public erc1155Token; // ERC1155 token contract
    uint256 public erc1155TokenId;

    struct Participant {
        uint256 reserveAmount;
        bool active;
    }

    mapping(uint256 => address) private addressAtIndex;
    mapping(address => Participant) public participants;
    uint256 public totalReserve;

    bool public ended;

    event ParticipantJoined(address participant, uint256 reserveAmount);
    event AuctionEnded(uint256 winningBid, address winner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyBeforeEnd() {
        require(!ended, "Auction has already ended.");
        require(block.timestamp < auctionEndTime, "Auction has already ended.");
        _;
    }

    constructor(address _coinToken, uint256 _duration, uint256 _maxParticipants,address _erc1155Token, uint256 _erc1155TokenId) {
        owner = msg.sender;
        coinToken = IERC20(_coinToken); 
        erc1155Token = IERC1155(_erc1155Token); // Initialize ERC1155 token contract
        erc1155TokenId = _erc1155TokenId; // Set ERC1155 token ID
        auctionEndTime = block.timestamp + _duration;
        maxParticipants = _maxParticipants;
        // Transfer ERC1155 token to auction contract
        erc1155Token.safeTransferFrom(msg.sender, address(this), erc1155TokenId, 1, "");


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
        reserveAmounts.push(reserveAmount); // Store the reserve amount
        addressAtIndex[participantCount] = msg.sender;
        participantCount++;

        coinToken.transferFrom(msg.sender, address(this), reserveAmount);

        emit ParticipantJoined(msg.sender, reserveAmount);
    }

    function endAuction() external onlyOwner onlyBeforeEnd {
        ended = true;
        
        uint256[2] memory  winningValues = winnerDeterminationInstance.getWinner(reserveAmounts); // Call determineWinner
        uint256 winningBid = winningValues[0];
        uint256 winningBidIndex = winningValues[1];
        address winner = addressAtIndex[winningBidIndex];

        // Process the winner's coin
        coinToken.transferFrom(address(this), winner, totalReserve - winningBid);

        // Transfer ERC1155 token to the winner
        erc1155Token.safeTransferFrom(address(this), winner, erc1155TokenId, 1, "");

        // Refund other participants
        for (uint256 i = 0; i < participantCount; i++) {
            if (i != winningBidIndex) {
                address participant = addressAtIndex[i];
                uint256 refundAmount = reserveAmounts[i];
                coinToken.transfer(participant, refundAmount);
            }
        }

        emit AuctionEnded(winningBid, winner);
    }

    function getTotalReserve() external view returns (uint256) {
        return totalReserve;
    }
}
