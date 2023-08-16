// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./createErc1155Token.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./DetermineWinner.sol";

contract AuctionEth is ERC1155Receiver, Ownable {
    WinnerDetermination public winnerDeterminationInstance; // Instance of WinnerDetermination
    uint256 public maxParticipants;
    uint256 public participantCount;
    uint256[] public reserveAmounts; // Array to store reserve amounts

    MyERC1155Token public erc1155Token; // ERC1155 token contract
    uint256 public erc1155TokenId;
    struct Participant {
        uint256 reserveAmount;
        bool active;
    }

    mapping(uint256 => address) private addressAtIndex;
    mapping(address => Participant) public participants;
    uint256 public totalReserve;

    bool public ended;


    // modifier onlyOwner() {
    //     require(msg.sender == owner, "Only the owner can call this function.");
    //     _;
    // }

    modifier onlyBeforeEnd(){
        require(!ended);
        _;
    }

    event ParticipantJoined(address participant);
    event AuctionEnded(uint256 winningBid, address winner);

    constructor(address _erc1155Token, uint256 _erc1155TokenId, uint256 _maxParticipants) {
        erc1155Token = MyERC1155Token(_erc1155Token); // Initialize your ERC1155 token contract
        erc1155TokenId = _erc1155TokenId; // Set ERC1155 token ID
        maxParticipants = _maxParticipants;
        // Transfer ERC1155 token to auction contract
        erc1155Token.safeTransferFrom(msg.sender, address(this), erc1155TokenId, 1, "");

    }

    function joinAuction() external payable onlyBeforeEnd {
        require(
            !participants[msg.sender].active,
            "You have already joined the auction."
        );
        require(participantCount < maxParticipants, "Auction is full.");
        require(msg.value > 0, "Reserve amount must be greater than zero.");

        participants[msg.sender] = Participant({
            reserveAmount: msg.value,
            active: true
        });

        totalReserve += msg.value;
        reserveAmounts.push(msg.value); // Store the reserve amount
        addressAtIndex[participantCount] = msg.sender;
        participantCount++;

        emit ParticipantJoined(msg.sender);
    }

    function endAuction() external onlyOwner onlyBeforeEnd {
        ended = true;

        uint256[2] memory winningValues = winnerDeterminationInstance.getWinner(
            reserveAmounts
        ); // Call determineWinner
        uint256 winningBid = winningValues[0];
        uint256 winningBidIndex = winningValues[1];
        address winner = addressAtIndex[winningBidIndex];

        // Process the winner's coin
        payable(owner()).transfer(winningBid);

        // Transfer ERC1155 token to the winner
        erc1155Token.safeTransferFrom(
            address(this),
            winner,
            erc1155TokenId,
            1,
            ""
        );

        // Refund other participants
        for (uint256 i = 0; i < participantCount; i++) {
            if (i != winningBidIndex) {
                address participant = addressAtIndex[i];
                uint256 refundAmount = reserveAmounts[i];
                payable(participant).transfer(refundAmount);
            }
        }

        emit AuctionEnded(winningBid, winner);
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure override returns (bytes4) {
        // Implementation of onERC1155Received
        // Make sure to return the correct magic value
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure override returns (bytes4) {
        // Implementation of onERC1155BatchReceived
        // Make sure to return the correct magic value
        return this.onERC1155BatchReceived.selector;
    }
}
