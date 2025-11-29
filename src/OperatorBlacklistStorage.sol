// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title BlacklistedOperatorResponder
/// @notice Simple response contract that emits an event when a blacklisted operator is detected
contract BlacklistedOperatorResponder {
    event BlacklistAlert(address operator, bool isBlacklisted);

    /// @notice This must match response_function in drosera.toml
    /// @dev Expects payload from trap's shouldRespond: (address operator, bool flagged)
    function respondToBlacklist(address operator, bool listed) external {
        emit BlacklistAlert(operator, listed);
    }
}
