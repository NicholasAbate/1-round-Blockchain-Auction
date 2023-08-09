// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the original Auction contract
import "./Auction.sol";

contract WinnerDetermination {
    // Reference to the original Auction contract
    Auction public auction;

    constructor(address _auctionAddress) {
        auction = Auction(_auctionAddress);
    }

    function getWinner(uint256[] calldata encryptedValues) external view returns (uint256[2] memory) {
        require(
            encryptedValues.length == auction.maxParticipants(),
            "Invalid number of encrypted values"
        );

        uint256 highestBid = encryptedValues[0];

        uint256 highestBidIndex = 0;

        for (uint256 i = 1; i < encryptedValues.length; i++) {
            uint256 encryptedValue = encryptedValues[i];
            uint256 encryptedDifference = encryptedValue - highestBid;

            if (decrypt(encryptedDifference) > 0) {
                highestBid = encryptedValue;
                highestBidIndex = i;
            }
        }

        return [highestBid, highestBidIndex];
    }

    function decrypt(uint256 encryptedValue) internal pure returns (uint256) {
        return encryptedValue;
    }
}
