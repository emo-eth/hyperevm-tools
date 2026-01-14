// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { L1Read } from "../src/L1Read.sol";

/// @notice Test helper contract that exposes L1Read library functions for testing
contract L1ReadCaller {

    function position(address user, uint16 perp) external view returns (L1Read.Position memory) {
        return L1Read.position(user, perp);
    }

    function spotBalance(address user, uint64 token) external view returns (L1Read.SpotBalance memory) {
        return L1Read.spotBalance(user, token);
    }

    function userVaultEquity(address user, address vault)
        external
        view
        returns (L1Read.UserVaultEquity memory)
    {
        return L1Read.userVaultEquity(user, vault);
    }

    function withdrawable(address user) external view returns (L1Read.Withdrawable memory) {
        return L1Read.withdrawable(user);
    }

    function delegations(address user) external view returns (L1Read.Delegation[] memory) {
        return L1Read.delegations(user);
    }

    function delegatorSummary(address user) external view returns (L1Read.DelegatorSummary memory) {
        return L1Read.delegatorSummary(user);
    }

    function markPx(uint32 index) external view returns (uint64) {
        return L1Read.markPx(index);
    }

    function oraclePx(uint32 index) external view returns (uint64) {
        return L1Read.oraclePx(index);
    }

    function spotPx(uint32 index) external view returns (uint64) {
        return L1Read.spotPx(index);
    }

    function l1BlockNumber() external view returns (uint64) {
        return L1Read.l1BlockNumber();
    }

    function perpAssetInfo(uint32 perp) external view returns (L1Read.PerpAssetInfo memory) {
        return L1Read.perpAssetInfo(perp);
    }

    function spotInfo(uint32 spot) external view returns (L1Read.SpotInfo memory) {
        return L1Read.spotInfo(spot);
    }

    function tokenInfo(uint32 token) external view returns (L1Read.TokenInfo memory) {
        return L1Read.tokenInfo(token);
    }

    function tokenSupply(uint32 token) external view returns (L1Read.TokenSupply memory) {
        return L1Read.tokenSupply(token);
    }

    function bbo(uint32 asset) external view returns (L1Read.Bbo memory) {
        return L1Read.bbo(asset);
    }

    function accountMarginSummary(uint32 perpDexIndex, address user)
        external
        view
        returns (L1Read.AccountMarginSummary memory)
    {
        return L1Read.accountMarginSummary(perpDexIndex, user);
    }

    function coreUserExists(address user) external view returns (L1Read.CoreUserExists memory) {
        return L1Read.coreUserExists(user);
    }

    function borrowLendUserState(address user, uint64 token)
        external
        view
        returns (L1Read.BorrowLendUserTokenState memory)
    {
        return L1Read.borrowLendUserState(user, token);
    }

    function borrowLendReserveState(uint64 token)
        external
        view
        returns (L1Read.BorrowLendReserveState memory)
    {
        return L1Read.borrowLendReserveState(token);
    }

}
