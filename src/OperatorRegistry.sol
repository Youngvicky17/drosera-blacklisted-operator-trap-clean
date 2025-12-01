// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract OperatorRegistry {
    address public owner;
    mapping(address => bool) public isBlacklisted;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        require(msg.sender == owner, "Owner only");
    }

    function addToBlacklist(address operator) external onlyOwner {
        isBlacklisted[operator] = true;
    }

    function removeFromBlacklist(address operator) external onlyOwner {
        isBlacklisted[operator] = false;
    }
}
