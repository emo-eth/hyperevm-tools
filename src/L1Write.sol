// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { CoreWriter } from "./CoreWriter.sol";

// ============ Enums ============

enum TimeInForce {
    Alo, // 0 -> encoded as 1
    Gtc, // 1 -> encoded as 2
    Ioc // 2 -> encoded as 3
}

enum FinalizeVariant {
    Create, // 0 -> encoded as 1
    FirstStorageSlot, // 1 -> encoded as 2
    CustomStorageSlot // 2 -> encoded as 3
}

enum BorrowLendOperation {
    Supply, // 0
    Withdraw // 1
}

// ============ Constants ============

uint32 constant SPOT_DEX = type(uint32).max;
uint64 constant BORROW_LEND_MAX_AMOUNT = 0;
uint128 constant NO_CLOID = 0;

// ============ Library ============

library L1Write {

    address constant CORE_WRITER_ADDRESS = 0x3333333333333333333333333333333333333333;

    // Action IDs (internal implementation detail)
    uint8 constant ACTION_ID_LIMIT_ORDER = 1;
    uint8 constant ACTION_ID_VAULT_TRANSFER = 2;
    uint8 constant ACTION_ID_TOKEN_DELEGATE = 3;
    uint8 constant ACTION_ID_STAKING_DEPOSIT = 4;
    uint8 constant ACTION_ID_STAKING_WITHDRAW = 5;
    uint8 constant ACTION_ID_SPOT_SEND = 6;
    uint8 constant ACTION_ID_USD_CLASS_TRANSFER = 7;
    uint8 constant ACTION_ID_FINALIZE_EVM_CONTRACT = 8;
    uint8 constant ACTION_ID_ADD_API_WALLET = 9;
    uint8 constant ACTION_ID_CANCEL_ORDER_BY_OID = 10;
    uint8 constant ACTION_ID_CANCEL_ORDER_BY_CLOID = 11;
    uint8 constant ACTION_ID_APPROVE_BUILDER_FEE = 12;
    uint8 constant ACTION_ID_SEND_ASSET = 13;
    uint8 constant ACTION_ID_REFLECT_EVM_SUPPLY_CHANGE = 14;
    uint8 constant ACTION_ID_BORROW_LEND_OPERATION = 15;

    /// @notice Sends a limit order action
    /// @param asset The perp asset index
    /// @param isBuy Whether this is a buy order
    /// @param limitPx Limit price (10^8 * human readable value)
    /// @param sz Size (10^8 * human readable value)
    /// @param reduceOnly Whether this is a reduce-only order
    /// @param tif Time in force
    /// @param cloid Client order ID (NO_CLOID means no cloid)
    function sendLimitOrder(
        uint32 asset,
        bool isBuy,
        uint64 limitPx,
        uint64 sz,
        bool reduceOnly,
        TimeInForce tif,
        uint128 cloid
    ) internal {
        bytes memory encodedAction = abi.encode(
            asset, isBuy, limitPx, sz, reduceOnly, uint8(tif) + 1, cloid
        );
        _sendAction(ACTION_ID_LIMIT_ORDER, encodedAction);
    }

    /// @notice Sends a vault transfer action
    /// @param vault The vault address
    /// @param isDeposit Whether this is a deposit (true) or withdrawal (false)
    /// @param usd Amount in USD (10^8 * human readable value)
    function sendVaultTransfer(address vault, bool isDeposit, uint64 usd) internal {
        bytes memory encodedAction = abi.encode(vault, isDeposit, usd);
        _sendAction(ACTION_ID_VAULT_TRANSFER, encodedAction);
    }

    /// @notice Sends a token delegate action
    /// @param validator The validator address
    /// @param amount Amount to delegate/undelegate
    /// @param isUndelegate Whether this is an undelegate operation
    function sendTokenDelegate(address validator, uint64 amount, bool isUndelegate) internal {
        bytes memory encodedAction = abi.encode(validator, amount, isUndelegate);
        _sendAction(ACTION_ID_TOKEN_DELEGATE, encodedAction);
    }

    /// @notice Sends a staking deposit action
    /// @param amount Amount to deposit
    function sendStakingDeposit(uint64 amount) internal {
        bytes memory encodedAction = abi.encode(amount);
        _sendAction(ACTION_ID_STAKING_DEPOSIT, encodedAction);
    }

    /// @notice Sends a staking withdraw action
    /// @param amount Amount to withdraw
    function sendStakingWithdraw(uint64 amount) internal {
        bytes memory encodedAction = abi.encode(amount);
        _sendAction(ACTION_ID_STAKING_WITHDRAW, encodedAction);
    }

    /// @notice Sends a spot send action
    /// @param destination Destination address
    /// @param token Token index
    /// @param amount Amount to send
    function sendSpotSend(address destination, uint64 token, uint64 amount) internal {
        bytes memory encodedAction = abi.encode(destination, token, amount);
        _sendAction(ACTION_ID_SPOT_SEND, encodedAction);
    }

    /// @notice Sends a USD class transfer action
    /// @param ntl Amount in NTL (10^8 * human readable value)
    /// @param toPerp Whether to transfer to perp (true) or from perp (false)
    function sendUsdClassTransfer(uint64 ntl, bool toPerp) internal {
        bytes memory encodedAction = abi.encode(ntl, toPerp);
        _sendAction(ACTION_ID_USD_CLASS_TRANSFER, encodedAction);
    }

    /// @notice Sends a finalize EVM contract action
    /// @param token Token index
    /// @param variant Finalize variant
    /// @param createNonce Create nonce (used if variant is Create)
    function sendFinalizeEvmContract(uint64 token, FinalizeVariant variant, uint64 createNonce)
        internal
    {
        bytes memory encodedAction = abi.encode(token, uint8(variant) + 1, createNonce);
        _sendAction(ACTION_ID_FINALIZE_EVM_CONTRACT, encodedAction);
    }

    /// @notice Sends an add API wallet action
    /// @param apiWallet The API wallet address
    /// @param apiWalletName The API wallet name (empty string makes this the main API wallet/agent)
    function sendAddApiWallet(address apiWallet, string memory apiWalletName) internal {
        bytes memory encodedAction = abi.encode(apiWallet, apiWalletName);
        _sendAction(ACTION_ID_ADD_API_WALLET, encodedAction);
    }

    /// @notice Sends a cancel order by oid action
    /// @param asset The perp asset index
    /// @param oid The order ID to cancel
    function sendCancelOrderByOid(uint32 asset, uint64 oid) internal {
        bytes memory encodedAction = abi.encode(asset, oid);
        _sendAction(ACTION_ID_CANCEL_ORDER_BY_OID, encodedAction);
    }

    /// @notice Sends a cancel order by cloid action
    /// @param asset The perp asset index
    /// @param cloid The client order ID to cancel
    function sendCancelOrderByCloid(uint32 asset, uint128 cloid) internal {
        bytes memory encodedAction = abi.encode(asset, cloid);
        _sendAction(ACTION_ID_CANCEL_ORDER_BY_CLOID, encodedAction);
    }

    /// @notice Sends an approve builder fee action
    /// @param maxFeeRate Maximum fee rate in decibps (e.g., 10 for 0.01%)
    /// @param builder The builder address
    function sendApproveBuilderFee(uint64 maxFeeRate, address builder) internal {
        bytes memory encodedAction = abi.encode(maxFeeRate, builder);
        _sendAction(ACTION_ID_APPROVE_BUILDER_FEE, encodedAction);
    }

    /// @notice Sends a send asset action
    /// @param destination Destination address
    /// @param subAccount Sub-account address (zero address if not using sub-account)
    /// @param sourceDex Source DEX index (SPOT_DEX for spot)
    /// @param destinationDex Destination DEX index (SPOT_DEX for spot)
    /// @param token Token index
    /// @param amount Amount to send
    function sendAsset(
        address destination,
        address subAccount,
        uint32 sourceDex,
        uint32 destinationDex,
        uint64 token,
        uint64 amount
    ) internal {
        bytes memory encodedAction = abi.encode(
            destination, subAccount, sourceDex, destinationDex, token, amount
        );
        _sendAction(ACTION_ID_SEND_ASSET, encodedAction);
    }

    /// @notice Sends a reflect EVM supply change for aligned quote token action
    /// @param token Token index
    /// @param amount Amount to mint/burn
    /// @param isMint Whether this is a mint (true) or burn (false)
    function sendReflectEvmSupplyChange(uint64 token, uint64 amount, bool isMint) internal {
        bytes memory encodedAction = abi.encode(token, amount, isMint);
        _sendAction(ACTION_ID_REFLECT_EVM_SUPPLY_CHANGE, encodedAction);
    }

    /// @notice Sends a borrow lend operation action (Testnet-only)
    /// @param operation Operation type
    /// @param token Token index
    /// @param amount Amount (BORROW_LEND_MAX_AMOUNT means maximally apply the operation)
    function sendBorrowLendOperation(BorrowLendOperation operation, uint64 token, uint64 amount)
        internal
    {
        bytes memory encodedAction = abi.encode(uint8(operation), token, amount);
        _sendAction(ACTION_ID_BORROW_LEND_OPERATION, encodedAction);
    }

    /// @notice Internal helper to encode and send an action to CoreWriter
    /// @param actionId The action ID constant
    /// @param encodedAction The ABI-encoded action data
    function _sendAction(uint8 actionId, bytes memory encodedAction) private {
        bytes4 action = bytes4(uint32(0x01000000 | actionId));
        bytes memory data = abi.encodePacked(action, encodedAction);
        CoreWriter(CORE_WRITER_ADDRESS).sendRawAction(data);
    }

}
