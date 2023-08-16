// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract MyERC1155Token is ERC1155, Ownable {
    constructor() ERC1155("") {}

    function mint(address account, uint256 id, uint256 amount, string memory metadataUrl) public onlyOwner {
        bytes memory data = abi.encodePacked(metadataUrl);
        _mint(account, id, amount, data);
    }
}
