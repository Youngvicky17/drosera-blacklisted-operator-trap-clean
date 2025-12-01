// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IOperatorRegistry {
    function isBlacklisted(address operator) external view returns (bool);
}

interface IBlacklistedResponder {
    function respondToBlacklist(address operator, bool listed) external;
}

contract BlacklistedOperatorTrap is ITrap {
    IOperatorRegistry public immutable REGISTRY;
    address public immutable TARGET_OPERATOR;
    address public immutable RESPONDER;

    constructor(
        address _registry,
        address _targetOperator,
        address _responder
    ) {
        require(_registry != address(0), "zero registry");
        require(_targetOperator != address(0), "zero target");
        require(_responder != address(0), "zero responder");

        REGISTRY = IOperatorRegistry(_registry);
        TARGET_OPERATOR = _targetOperator;
        RESPONDER = _responder;
    }

    function collect() external view override returns (bytes memory) {
        bool flagged = REGISTRY.isBlacklisted(TARGET_OPERATOR);
        uint256 blockNumber = block.number;
        return abi.encode(TARGET_OPERATOR, flagged, blockNumber);
    }

    function shouldRespond(
        bytes[] calldata data
    ) external pure override returns (bool, bytes memory) {
        if (data.length == 0 || data[0].length == 0) {
            return (false, bytes(""));
        }

        (address operator, bool flagged, ) = abi.decode(
            data[0],
            (address, bool, uint256)
        );

        if (!flagged) return (false, bytes(""));

        return (true, abi.encode(operator, flagged));
    }

    function respond(bytes calldata payload) external {
        (address operator, bool flagged) = abi.decode(payload, (address, bool));
        IBlacklistedResponder(RESPONDER).respondToBlacklist(operator, flagged);
    }
}
