// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ============ Structs ============

struct Position {
    int64 szi;
    uint64 entryNtl;
    int64 isolatedRawUsd;
    uint32 leverage;
    bool isIsolated;
}

struct SpotBalance {
    uint64 total;
    uint64 hold;
    uint64 entryNtl;
}

struct UserVaultEquity {
    uint64 equity;
    uint64 lockedUntilTimestamp;
}

struct Withdrawable {
    uint64 withdrawable;
}

struct Delegation {
    address validator;
    uint64 amount;
    uint64 lockedUntilTimestamp;
}

struct DelegatorSummary {
    uint64 delegated;
    uint64 undelegated;
    uint64 totalPendingWithdrawal;
    uint64 nPendingWithdrawals;
}

struct PerpAssetInfo {
    string coin;
    uint32 marginTableId;
    uint8 szDecimals;
    uint8 maxLeverage;
    bool onlyIsolated;
}

struct SpotInfo {
    string name;
    uint64[2] tokens;
}

struct TokenInfo {
    string name;
    uint64[] spots;
    uint64 deployerTradingFeeShare;
    address deployer;
    address evmContract;
    uint8 szDecimals;
    uint8 weiDecimals;
    int8 evmExtraWeiDecimals;
}

struct UserBalance {
    address user;
    uint64 balance;
}

struct TokenSupply {
    uint64 maxSupply;
    uint64 totalSupply;
    uint64 circulatingSupply;
    uint64 futureEmissions;
    UserBalance[] nonCirculatingUserBalances;
}

struct Bbo {
    uint64 bid;
    uint64 ask;
}

struct AccountMarginSummary {
    int64 accountValue;
    uint64 marginUsed;
    uint64 ntlPos;
    int64 rawUsd;
}

struct CoreUserExists {
    bool exists;
}

struct BasisAndValue {
    uint64 basis;
    uint64 value;
}

struct BorrowLendUserTokenState {
    BasisAndValue borrow;
    BasisAndValue supply;
}

struct BorrowLendReserveState {
    uint64 borrowYearlyRateBps;
    uint64 supplyYearlyRateBps;
    uint64 balance;
    uint64 utilizationBps;
    uint64 oraclePx;
    uint64 ltvBps;
    uint64 totalSupplied;
    uint64 totalBorrowed;
}

// ============ Errors ============

error PositionPrecompileCallFailed();
error SpotBalancePrecompileCallFailed();
error VaultEquityPrecompileCallFailed();
error WithdrawablePrecompileCallFailed();
error DelegationsPrecompileCallFailed();
error DelegatorSummaryPrecompileCallFailed();
error MarkPxPrecompileCallFailed();
error OraclePxPrecompileCallFailed();
error SpotPxPrecompileCallFailed();
error L1BlockNumberPrecompileCallFailed();
error PerpAssetInfoPrecompileCallFailed();
error SpotInfoPrecompileCallFailed();
error TokenInfoPrecompileCallFailed();
error TokenSupplyPrecompileCallFailed();
error BboPrecompileCallFailed();
error AccountMarginSummaryPrecompileCallFailed();
error CoreUserExistsPrecompileCallFailed();
error BorrowLendUserStatePrecompileCallFailed();
error BorrowLendReserveStatePrecompileCallFailed();

// ============ Library ============

library L1Read {

    address constant POSITION_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000000800;
    address constant SPOT_BALANCE_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000000801;
    address constant VAULT_EQUITY_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000000802;
    address constant WITHDRAWABLE_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000000803;
    address constant DELEGATIONS_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000000804;
    address constant DELEGATOR_SUMMARY_PRECOMPILE_ADDRESS =
        0x0000000000000000000000000000000000000805;
    address constant MARK_PX_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000000806;
    address constant ORACLE_PX_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000000807;
    address constant SPOT_PX_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000000808;
    address constant L1_BLOCK_NUMBER_PRECOMPILE_ADDRESS =
        0x0000000000000000000000000000000000000809;
    address constant PERP_ASSET_INFO_PRECOMPILE_ADDRESS =
        0x000000000000000000000000000000000000080a;
    address constant SPOT_INFO_PRECOMPILE_ADDRESS = 0x000000000000000000000000000000000000080b;
    address constant TOKEN_INFO_PRECOMPILE_ADDRESS = 0x000000000000000000000000000000000000080C;
    address constant TOKEN_SUPPLY_PRECOMPILE_ADDRESS = 0x000000000000000000000000000000000000080D;
    address constant BBO_PRECOMPILE_ADDRESS = 0x000000000000000000000000000000000000080e;
    address constant ACCOUNT_MARGIN_SUMMARY_PRECOMPILE_ADDRESS =
        0x000000000000000000000000000000000000080F;
    address constant CORE_USER_EXISTS_PRECOMPILE_ADDRESS =
        0x0000000000000000000000000000000000000810;
    address constant BORROW_LEND_USER_STATE_PRECOMPILE_ADDRESS =
        0x0000000000000000000000000000000000000811;
    address constant BORROW_LEND_RESERVE_STATE_PRECOMPILE_ADDRESS =
        0x0000000000000000000000000000000000000812;

    function position(address user, uint16 perp) internal view returns (Position memory) {
        (bool success, bytes memory result) =
            POSITION_PRECOMPILE_ADDRESS.staticcall(abi.encode(user, perp));
        if (!success) {
            revert PositionPrecompileCallFailed();
        }
        return abi.decode(result, (Position));
    }

    function spotBalance(address user, uint64 token) internal view returns (SpotBalance memory) {
        (bool success, bytes memory result) =
            SPOT_BALANCE_PRECOMPILE_ADDRESS.staticcall(abi.encode(user, token));
        if (!success) {
            revert SpotBalancePrecompileCallFailed();
        }
        return abi.decode(result, (SpotBalance));
    }

    function userVaultEquity(address user, address vault)
        internal
        view
        returns (UserVaultEquity memory)
    {
        (bool success, bytes memory result) =
            VAULT_EQUITY_PRECOMPILE_ADDRESS.staticcall(abi.encode(user, vault));
        if (!success) {
            revert VaultEquityPrecompileCallFailed();
        }
        return abi.decode(result, (UserVaultEquity));
    }

    function withdrawable(address user) internal view returns (Withdrawable memory) {
        (bool success, bytes memory result) =
            WITHDRAWABLE_PRECOMPILE_ADDRESS.staticcall(abi.encode(user));
        if (!success) {
            revert WithdrawablePrecompileCallFailed();
        }
        return abi.decode(result, (Withdrawable));
    }

    function delegations(address user) internal view returns (Delegation[] memory) {
        (bool success, bytes memory result) =
            DELEGATIONS_PRECOMPILE_ADDRESS.staticcall(abi.encode(user));
        if (!success) {
            revert DelegationsPrecompileCallFailed();
        }
        return abi.decode(result, (Delegation[]));
    }

    function delegatorSummary(address user) internal view returns (DelegatorSummary memory) {
        (bool success, bytes memory result) =
            DELEGATOR_SUMMARY_PRECOMPILE_ADDRESS.staticcall(abi.encode(user));
        if (!success) {
            revert DelegatorSummaryPrecompileCallFailed();
        }
        return abi.decode(result, (DelegatorSummary));
    }

    function markPx(uint32 index) internal view returns (uint64) {
        (bool success, bytes memory result) =
            MARK_PX_PRECOMPILE_ADDRESS.staticcall(abi.encode(index));
        if (!success) {
            revert MarkPxPrecompileCallFailed();
        }
        return abi.decode(result, (uint64));
    }

    function oraclePx(uint32 index) internal view returns (uint64) {
        (bool success, bytes memory result) =
            ORACLE_PX_PRECOMPILE_ADDRESS.staticcall(abi.encode(index));
        if (!success) {
            revert OraclePxPrecompileCallFailed();
        }
        return abi.decode(result, (uint64));
    }

    function spotPx(uint32 index) internal view returns (uint64) {
        (bool success, bytes memory result) =
            SPOT_PX_PRECOMPILE_ADDRESS.staticcall(abi.encode(index));
        if (!success) {
            revert SpotPxPrecompileCallFailed();
        }
        return abi.decode(result, (uint64));
    }

    function l1BlockNumber() internal view returns (uint64) {
        (bool success, bytes memory result) = L1_BLOCK_NUMBER_PRECOMPILE_ADDRESS.staticcall("");
        if (!success) {
            revert L1BlockNumberPrecompileCallFailed();
        }
        return abi.decode(result, (uint64));
    }

    function perpAssetInfo(uint32 perp) internal view returns (PerpAssetInfo memory) {
        (bool success, bytes memory result) =
            PERP_ASSET_INFO_PRECOMPILE_ADDRESS.staticcall(abi.encode(perp));
        if (!success) {
            revert PerpAssetInfoPrecompileCallFailed();
        }
        return abi.decode(result, (PerpAssetInfo));
    }

    function spotInfo(uint32 spot) internal view returns (SpotInfo memory) {
        (bool success, bytes memory result) =
            SPOT_INFO_PRECOMPILE_ADDRESS.staticcall(abi.encode(spot));
        if (!success) {
            revert SpotInfoPrecompileCallFailed();
        }
        return abi.decode(result, (SpotInfo));
    }

    function tokenInfo(uint32 token) internal view returns (TokenInfo memory) {
        (bool success, bytes memory result) =
            TOKEN_INFO_PRECOMPILE_ADDRESS.staticcall(abi.encode(token));
        if (!success) {
            revert TokenInfoPrecompileCallFailed();
        }
        return abi.decode(result, (TokenInfo));
    }

    function tokenSupply(uint32 token) internal view returns (TokenSupply memory) {
        (bool success, bytes memory result) =
            TOKEN_SUPPLY_PRECOMPILE_ADDRESS.staticcall(abi.encode(token));
        if (!success) {
            revert TokenSupplyPrecompileCallFailed();
        }
        return abi.decode(result, (TokenSupply));
    }

    function bbo(uint32 asset) internal view returns (Bbo memory) {
        (bool success, bytes memory result) = BBO_PRECOMPILE_ADDRESS.staticcall(abi.encode(asset));
        if (!success) {
            revert BboPrecompileCallFailed();
        }
        return abi.decode(result, (Bbo));
    }

    function accountMarginSummary(uint32 perpDexIndex, address user)
        internal
        view
        returns (AccountMarginSummary memory)
    {
        (bool success, bytes memory result) =
            ACCOUNT_MARGIN_SUMMARY_PRECOMPILE_ADDRESS.staticcall(abi.encode(perpDexIndex, user));
        if (!success) {
            revert AccountMarginSummaryPrecompileCallFailed();
        }
        return abi.decode(result, (AccountMarginSummary));
    }

    function coreUserExists(address user) internal view returns (CoreUserExists memory) {
        (bool success, bytes memory result) =
            CORE_USER_EXISTS_PRECOMPILE_ADDRESS.staticcall(abi.encode(user));
        if (!success) {
            revert CoreUserExistsPrecompileCallFailed();
        }
        return abi.decode(result, (CoreUserExists));
    }

    function borrowLendUserState(address user, uint64 token)
        internal
        view
        returns (BorrowLendUserTokenState memory)
    {
        (bool success, bytes memory result) =
            BORROW_LEND_USER_STATE_PRECOMPILE_ADDRESS.staticcall(abi.encode(user, token));
        if (!success) {
            revert BorrowLendUserStatePrecompileCallFailed();
        }
        return abi.decode(result, (BorrowLendUserTokenState));
    }

    function borrowLendReserveState(uint64 token)
        internal
        view
        returns (BorrowLendReserveState memory)
    {
        (bool success, bytes memory result) =
            BORROW_LEND_RESERVE_STATE_PRECOMPILE_ADDRESS.staticcall(abi.encode(token));
        if (!success) {
            revert BorrowLendReserveStatePrecompileCallFailed();
        }
        return abi.decode(result, (BorrowLendReserveState));
    }

}
