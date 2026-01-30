// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { L1Write, TimeInForce, FinalizeVariant, BorrowLendOperation } from "../src/L1Write.sol";

/// @notice Test helper contract that exposes L1Write library functions for testing
contract L1WriteCaller {

    function sendLimitOrder(
        uint32 asset,
        bool isBuy,
        uint64 limitPx,
        uint64 sz,
        bool reduceOnly,
        TimeInForce tif,
        uint128 cloid
    ) external {
        L1Write.sendLimitOrder(asset, isBuy, limitPx, sz, reduceOnly, tif, cloid);
    }

    function sendVaultTransfer(address vault, bool isDeposit, uint64 usd) external {
        L1Write.sendVaultTransfer(vault, isDeposit, usd);
    }

    function sendTokenDelegate(address validator, uint64 amount, bool isUndelegate) external {
        L1Write.sendTokenDelegate(validator, amount, isUndelegate);
    }

    function sendStakingDeposit(uint64 amount) external {
        L1Write.sendStakingDeposit(amount);
    }

    function sendStakingWithdraw(uint64 amount) external {
        L1Write.sendStakingWithdraw(amount);
    }

    function sendSpotSend(address destination, uint64 token, uint64 amount) external {
        L1Write.sendSpotSend(destination, token, amount);
    }

    function sendUsdClassTransfer(uint64 ntl, bool toPerp) external {
        L1Write.sendUsdClassTransfer(ntl, toPerp);
    }

    function sendFinalizeEvmContract(uint64 token, FinalizeVariant variant, uint64 createNonce)
        external
    {
        L1Write.sendFinalizeEvmContract(token, variant, createNonce);
    }

    function sendAddApiWallet(address apiWallet, string memory apiWalletName) external {
        L1Write.sendAddApiWallet(apiWallet, apiWalletName);
    }

    function sendCancelOrderByOid(uint32 asset, uint64 oid) external {
        L1Write.sendCancelOrderByOid(asset, oid);
    }

    function sendCancelOrderByCloid(uint32 asset, uint128 cloid) external {
        L1Write.sendCancelOrderByCloid(asset, cloid);
    }

    function sendApproveBuilderFee(uint64 maxFeeRate, address builder) external {
        L1Write.sendApproveBuilderFee(maxFeeRate, builder);
    }

    function sendAsset(
        address destination,
        address subAccount,
        uint32 sourceDex,
        uint32 destinationDex,
        uint64 token,
        uint64 amount
    ) external {
        L1Write.sendAsset(destination, subAccount, sourceDex, destinationDex, token, amount);
    }

    function sendReflectEvmSupplyChange(uint64 token, uint64 amount, bool isMint) external {
        L1Write.sendReflectEvmSupplyChange(token, amount, isMint);
    }

    function sendBorrowLendOperation(BorrowLendOperation operation, uint64 token, uint64 amount)
        external
    {
        L1Write.sendBorrowLendOperation(operation, token, amount);
    }

}
