// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BlacklistedOperatorResponder {
    event BlacklistAlert(address operator, bool isBlacklisted);

    /// Must match drosera.toml response_function
    function respondToBlacklist(address operator, bool listed) external {
        emit BlacklistAlert(operator, listed);
    }
}
