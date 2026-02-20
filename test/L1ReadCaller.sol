// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    AccountMarginSummary,
    Bbo,
    BorrowLendReserveState,
    BorrowLendUserTokenState,
    CoreUserExists,
    Delegation,
    DelegatorSummary,
    L1Read,
    PerpAssetInfo,
    Position,
    SpotBalance,
    SpotInfo,
    TokenInfo,
    TokenSupply,
    UserVaultEquity,
    Withdrawable
} from "../src/L1Read.sol";

/// @notice Test helper contract that exposes L1Read library functions for testing
contract L1ReadCaller {

    function position(address user, uint16 perp) external view returns (Position memory) {
        return L1Read.position(user, perp);
    }

    function tryPosition(address user, uint16 perp) external view returns (Position memory, bool) {
        return L1Read.tryPosition(user, perp);
    }

    function position2(address user, uint32 perp) external view returns (Position memory) {
        return L1Read.position2(user, perp);
    }

    function tryPosition2(address user, uint32 perp) external view returns (Position memory, bool) {
        return L1Read.tryPosition2(user, perp);
    }

    function spotBalance(address user, uint64 token) external view returns (SpotBalance memory) {
        return L1Read.spotBalance(user, token);
    }

    function trySpotBalance(
        address user,
        uint64 token
    )
        external
        view
        returns (SpotBalance memory, bool)
    {
        return L1Read.trySpotBalance(user, token);
    }

    function userVaultEquity(
        address user,
        address vault
    )
        external
        view
        returns (UserVaultEquity memory)
    {
        return L1Read.userVaultEquity(user, vault);
    }

    function tryUserVaultEquity(
        address user,
        address vault
    )
        external
        view
        returns (UserVaultEquity memory, bool)
    {
        return L1Read.tryUserVaultEquity(user, vault);
    }

    function withdrawable(address user) external view returns (Withdrawable memory) {
        return L1Read.withdrawable(user);
    }

    function tryWithdrawable(address user) external view returns (Withdrawable memory, bool) {
        return L1Read.tryWithdrawable(user);
    }

    function delegations(address user) external view returns (Delegation[] memory) {
        return L1Read.delegations(user);
    }

    function tryDelegations(address user) external view returns (Delegation[] memory, bool) {
        return L1Read.tryDelegations(user);
    }

    function delegatorSummary(address user) external view returns (DelegatorSummary memory) {
        return L1Read.delegatorSummary(user);
    }

    function tryDelegatorSummary(address user)
        external
        view
        returns (DelegatorSummary memory, bool)
    {
        return L1Read.tryDelegatorSummary(user);
    }

    function markPx(uint32 index) external view returns (uint64) {
        return L1Read.markPx(index);
    }

    function tryMarkPx(uint32 index) external view returns (uint64, bool) {
        return L1Read.tryMarkPx(index);
    }

    function oraclePx(uint32 index) external view returns (uint64) {
        return L1Read.oraclePx(index);
    }

    function tryOraclePx(uint32 index) external view returns (uint64, bool) {
        return L1Read.tryOraclePx(index);
    }

    function spotPx(uint32 index) external view returns (uint64) {
        return L1Read.spotPx(index);
    }

    function trySpotPx(uint32 index) external view returns (uint64, bool) {
        return L1Read.trySpotPx(index);
    }

    function l1BlockNumber() external view returns (uint64) {
        return L1Read.l1BlockNumber();
    }

    function tryL1BlockNumber() external view returns (uint64, bool) {
        return L1Read.tryL1BlockNumber();
    }

    function perpAssetInfo(uint32 perp) external view returns (PerpAssetInfo memory) {
        return L1Read.perpAssetInfo(perp);
    }

    function tryPerpAssetInfo(uint32 perp) external view returns (PerpAssetInfo memory, bool) {
        return L1Read.tryPerpAssetInfo(perp);
    }

    function spotInfo(uint32 spot) external view returns (SpotInfo memory) {
        return L1Read.spotInfo(spot);
    }

    function trySpotInfo(uint32 spot) external view returns (SpotInfo memory, bool) {
        return L1Read.trySpotInfo(spot);
    }

    function tokenInfo(uint32 token) external view returns (TokenInfo memory) {
        return L1Read.tokenInfo(token);
    }

    function tryTokenInfo(uint32 token) external view returns (TokenInfo memory, bool) {
        return L1Read.tryTokenInfo(token);
    }

    function tokenSupply(uint32 token) external view returns (TokenSupply memory) {
        return L1Read.tokenSupply(token);
    }

    function tryTokenSupply(uint32 token) external view returns (TokenSupply memory, bool) {
        return L1Read.tryTokenSupply(token);
    }

    function bbo(uint32 asset) external view returns (Bbo memory) {
        return L1Read.bbo(asset);
    }

    function tryBbo(uint32 asset) external view returns (Bbo memory, bool) {
        return L1Read.tryBbo(asset);
    }

    function accountMarginSummary(
        uint32 perpDexIndex,
        address user
    )
        external
        view
        returns (AccountMarginSummary memory)
    {
        return L1Read.accountMarginSummary(perpDexIndex, user);
    }

    function tryAccountMarginSummary(
        uint32 perpDexIndex,
        address user
    )
        external
        view
        returns (AccountMarginSummary memory, bool)
    {
        return L1Read.tryAccountMarginSummary(perpDexIndex, user);
    }

    function coreUserExists(address user) external view returns (CoreUserExists memory) {
        return L1Read.coreUserExists(user);
    }

    function tryCoreUserExists(address user) external view returns (CoreUserExists memory, bool) {
        return L1Read.tryCoreUserExists(user);
    }

    function borrowLendUserState(
        address user,
        uint64 token
    )
        external
        view
        returns (BorrowLendUserTokenState memory)
    {
        return L1Read.borrowLendUserState(user, token);
    }

    function tryBorrowLendUserState(
        address user,
        uint64 token
    )
        external
        view
        returns (BorrowLendUserTokenState memory, bool)
    {
        return L1Read.tryBorrowLendUserState(user, token);
    }

    function borrowLendReserveState(uint64 token)
        external
        view
        returns (BorrowLendReserveState memory)
    {
        return L1Read.borrowLendReserveState(token);
    }

    function tryBorrowLendReserveState(uint64 token)
        external
        view
        returns (BorrowLendReserveState memory, bool)
    {
        return L1Read.tryBorrowLendReserveState(token);
    }

}
