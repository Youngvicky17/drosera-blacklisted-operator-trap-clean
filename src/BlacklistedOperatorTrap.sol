// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

/// @title BlacklistedOperatorTrap
/// @notice Simple Drosera trap that flags calls from blacklisted operators
/// @dev Follows the common ITrap pattern used in Drosera tutorials:
///      - collect() -> returns bytes
///      - shouldRespond(bytes[] calldata) -> returns (bool, bytes)
contract BlacklistedOperatorTrap is ITrap {
    // Anyone can add/remove in this PoC (no constructor, no access control to keep it simple)
    mapping(address => bool) public isBlacklisted;

    /// @notice Add an operator to the blacklist
    function addToBlacklist(address operator) external {
        isBlacklisted[operator] = true;
    }

    /// @notice Remove an operator from the blacklist
    function removeFromBlacklist(address operator) external {
        isBlacklisted[operator] = false;
    }

    /// @notice Collect data for the current caller
    /// @dev Encodes (operator, isBlacklisted) into bytes
    ///      This is cheap and only reads storage once.
    function collect() external view override returns (bytes memory) {
        bool flagged = isBlacklisted[msg.sender];
        // Payload: (operator, flagged)
        return abi.encode(msg.sender, flagged);
    }

    /// @notice Decide if Drosera should respond based on collected data
    /// @param data Array of bytes payloads; we use data[0] from collect()
    /// @return shouldRespond_ True if response should trigger
    /// @return responsePayload Bytes that will be forwarded to the response contract
    function shouldRespond(
        bytes[] calldata data
    )
        external
        pure
        override
        returns (bool shouldRespond_, bytes memory responsePayload)
    {
        if (data.length == 0) {
            return (false, bytes(""));
        }

        (address operator, bool flagged) = abi.decode(data[0], (address, bool));

        if (!flagged) {
            return (false, bytes(""));
        }

        // If blacklisted, respond and forward (operator, flagged) as payload
        return (true, abi.encode(operator, flagged));
    }
}
