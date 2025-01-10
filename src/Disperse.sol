// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {ReentrancyGuard} from "solady/src/utils/ReentrancyGuard.sol";

/// @title Disperse
/// @notice Efficiently disperse ETH and ERC20 tokens to multiple recipients
/// @author Modified from original Disperse contract with Solady optimizations
contract Disperse is ReentrancyGuard {
    using SafeTransferLib for address;

    error ArrayLengthMismatch();
    error ZeroAddress();

    /// @notice Disperse ETH to multiple recipients
    /// @param recipients Array of recipient addresses
    /// @param values Array of values to send to each recipient
    function disperseMAGIC(address[] calldata recipients, uint256[] calldata values)
        external
        payable
        nonReentrant
    {
        // Input validation
        if (recipients.length != values.length) revert ArrayLengthMismatch();

        uint256 total;
        uint256 len = recipients.length;

        for (uint256 i; i < len;) {
            address recipient = recipients[i];
            if (recipient == address(0)) revert ZeroAddress();

            uint256 amount = values[i];
            total += amount;

            // Use Solady's optimized ETH transfer
            recipient.safeTransferETH(amount);

            unchecked {
                ++i;
            }
        }

        // Return excess ETH if any
        uint256 balance = address(this).balance;
        if (balance > 0) {
            msg.sender.safeTransferETH(balance);
        }
    }

    /// @notice Disperse ERC20 tokens to multiple recipients
    /// @param token The ERC20 token to disperse
    /// @param recipients Array of recipient addresses
    /// @param values Array of values to send to each recipient
    function disperseToken(address token, address[] calldata recipients, uint256[] calldata values)
        external
        nonReentrant
    {
        if (recipients.length != values.length) revert ArrayLengthMismatch();

        uint256 total;
        uint256 len = recipients.length;

        for (uint256 i; i < len;) {
            address recipient = recipients[i];
            if (recipient == address(0)) revert ZeroAddress();

            uint256 amount = values[i];
            total += amount;

            unchecked {
                ++i;
            }
        }

        // Transfer total amount from sender to this contract
        token.safeTransferFrom(msg.sender, address(this), total);

        // Transfer to each recipient
        for (uint256 i; i < len;) {
            token.safeTransfer(recipients[i], values[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Disperse ERC20 tokens directly from sender to recipients
    /// @param token The ERC20 token to disperse
    /// @param recipients Array of recipient addresses
    /// @param values Array of values to send to each recipient
    function disperseTokenSimple(
        address token,
        address[] calldata recipients,
        uint256[] calldata values
    ) external nonReentrant {
        if (recipients.length != values.length) revert ArrayLengthMismatch();

        uint256 len = recipients.length;
        for (uint256 i; i < len;) {
            address recipient = recipients[i];
            if (recipient == address(0)) revert ZeroAddress();

            token.safeTransferFrom(msg.sender, recipient, values[i]);
            unchecked {
                ++i;
            }
        }
    }
}
