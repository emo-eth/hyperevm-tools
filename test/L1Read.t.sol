// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { L1Read } from "../src/L1Read.sol";
import { L1ReadCaller } from "./L1ReadCaller.sol";
import { Test } from "forge-std/Test.sol";

contract L1ReadTest is Test {

    L1ReadCaller caller;

    function setUp() public {
        caller = new L1ReadCaller();
    }

    function _setupMockPrecompile(address precompileAddr, bytes memory expectedCalldata, bytes memory returnData) internal {
        // Verify the correct call is made and mock the return
        vm.expectCall(precompileAddr, expectedCalldata);
        vm.mockCall(precompileAddr, expectedCalldata, returnData);
    }

    function _setupFailingPrecompile(address precompileAddr, bytes memory expectedCalldata) internal {
        // Verify the correct call is made and mock a revert
        vm.expectCall(precompileAddr, expectedCalldata);
        vm.mockCallRevert(precompileAddr, expectedCalldata, abi.encode("Precompile call failed"));
    }

    function test_position() public {
        address user = makeAddr("user");
        uint16 perp = 1;
        L1Read.Position memory expectedPos = L1Read.Position({
            szi: 1000, entryNtl: 50_000, isolatedRawUsd: 2000, leverage: 10, isIsolated: true
        });

        bytes memory expectedCalldata = abi.encode(user, perp);
        _setupMockPrecompile(L1Read.POSITION_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedPos));

        L1Read.Position memory result = caller.position(user, perp);
        assertEq(result.szi, expectedPos.szi);
        assertEq(result.entryNtl, expectedPos.entryNtl);
        assertEq(result.isolatedRawUsd, expectedPos.isolatedRawUsd);
        assertEq(result.leverage, expectedPos.leverage);
        assertEq(result.isIsolated, expectedPos.isIsolated);
    }

    function test_position_Fail() public {
        address user = makeAddr("user");
        uint16 perp = 1;

        bytes memory expectedCalldata = abi.encode(user, perp);
        _setupFailingPrecompile(L1Read.POSITION_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("Position precompile call failed"))
        );
        this.position(user, perp);
    }

    function position(address user, uint16 perp) external view returns (L1Read.Position memory) {
        return caller.position(user, perp);
    }

    function test_spotBalance() public {
        address user = makeAddr("user");
        uint64 token = 42;
        L1Read.SpotBalance memory expectedBalance =
            L1Read.SpotBalance({ total: 10_000, hold: 5000, entryNtl: 25_000 });

        bytes memory expectedCalldata = abi.encode(user, token);
        _setupMockPrecompile(L1Read.SPOT_BALANCE_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedBalance));

        L1Read.SpotBalance memory result = caller.spotBalance(user, token);
        assertEq(result.total, expectedBalance.total);
        assertEq(result.hold, expectedBalance.hold);
        assertEq(result.entryNtl, expectedBalance.entryNtl);
    }

    function test_spotBalance_Fail() public {
        address user = makeAddr("user");
        uint64 token = 42;

        bytes memory expectedCalldata = abi.encode(user, token);
        _setupFailingPrecompile(L1Read.SPOT_BALANCE_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("SpotBalance precompile call failed"))
        );
        this.spotBalance(user, token);
    }

    function spotBalance(address user, uint64 token)
        external
        view
        returns (L1Read.SpotBalance memory)
    {
        return caller.spotBalance(user, token);
    }

    function test_userVaultEquity() public {
        address user = makeAddr("user");
        address vault = makeAddr("vault");
        L1Read.UserVaultEquity memory expectedEquity =
            L1Read.UserVaultEquity({ equity: 1_000_000, lockedUntilTimestamp: 1_234_567_890 });

        bytes memory expectedCalldata = abi.encode(user, vault);
        _setupMockPrecompile(L1Read.VAULT_EQUITY_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedEquity));

        L1Read.UserVaultEquity memory result = caller.userVaultEquity(user, vault);
        assertEq(result.equity, expectedEquity.equity);
        assertEq(result.lockedUntilTimestamp, expectedEquity.lockedUntilTimestamp);
    }

    function test_userVaultEquity_Fail() public {
        address user = makeAddr("user");
        address vault = makeAddr("vault");

        bytes memory expectedCalldata = abi.encode(user, vault);
        _setupFailingPrecompile(L1Read.VAULT_EQUITY_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("VaultEquity precompile call failed"))
        );
        this.userVaultEquity(user, vault);
    }

    function userVaultEquity(address user, address vault)
        external
        view
        returns (L1Read.UserVaultEquity memory)
    {
        return caller.userVaultEquity(user, vault);
    }

    function test_withdrawable() public {
        address user = makeAddr("user");
        L1Read.Withdrawable memory expectedWithdrawable =
            L1Read.Withdrawable({ withdrawable: 500_000 });

        bytes memory expectedCalldata = abi.encode(user);
        _setupMockPrecompile(L1Read.WITHDRAWABLE_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedWithdrawable));

        L1Read.Withdrawable memory result = caller.withdrawable(user);
        assertEq(result.withdrawable, expectedWithdrawable.withdrawable);
    }

    function test_withdrawable_Fail() public {
        address user = makeAddr("user");

        bytes memory expectedCalldata = abi.encode(user);
        _setupFailingPrecompile(L1Read.WITHDRAWABLE_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("Withdrawable precompile call failed"))
        );
        this.withdrawable(user);
    }

    function withdrawable(address user) external view returns (L1Read.Withdrawable memory) {
        return caller.withdrawable(user);
    }

    function test_delegations() public {
        address user = makeAddr("user");
        L1Read.Delegation[] memory expectedDelegations = new L1Read.Delegation[](2);
        expectedDelegations[0] = L1Read.Delegation({
            validator: makeAddr("validator1"), amount: 1000, lockedUntilTimestamp: 1_234_567_890
        });
        expectedDelegations[1] = L1Read.Delegation({
            validator: makeAddr("validator2"), amount: 2000, lockedUntilTimestamp: 1_234_567_900
        });

        bytes memory expectedCalldata = abi.encode(user);
        _setupMockPrecompile(L1Read.DELEGATIONS_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedDelegations));

        L1Read.Delegation[] memory result = caller.delegations(user);
        assertEq(result.length, 2);
        assertEq(result[0].validator, expectedDelegations[0].validator);
        assertEq(result[0].amount, expectedDelegations[0].amount);
        assertEq(result[1].validator, expectedDelegations[1].validator);
        assertEq(result[1].amount, expectedDelegations[1].amount);
    }

    function test_delegations_Empty() public {
        address user = makeAddr("user");
        L1Read.Delegation[] memory expectedDelegations = new L1Read.Delegation[](0);

        bytes memory expectedCalldata = abi.encode(user);
        _setupMockPrecompile(L1Read.DELEGATIONS_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedDelegations));

        L1Read.Delegation[] memory result = caller.delegations(user);
        assertEq(result.length, 0);
    }

    function test_delegations_Fail() public {
        address user = makeAddr("user");

        bytes memory expectedCalldata = abi.encode(user);
        _setupFailingPrecompile(L1Read.DELEGATIONS_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("Delegations precompile call failed"))
        );
        this.delegations(user);
    }

    function delegations(address user) external view returns (L1Read.Delegation[] memory) {
        return caller.delegations(user);
    }

    function test_delegatorSummary() public {
        address user = makeAddr("user");
        L1Read.DelegatorSummary memory expectedSummary = L1Read.DelegatorSummary({
            delegated: 10_000,
            undelegated: 5000,
            totalPendingWithdrawal: 2000,
            nPendingWithdrawals: 3
        });

        bytes memory expectedCalldata = abi.encode(user);
        _setupMockPrecompile(L1Read.DELEGATOR_SUMMARY_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedSummary));

        L1Read.DelegatorSummary memory result = caller.delegatorSummary(user);
        assertEq(result.delegated, expectedSummary.delegated);
        assertEq(result.undelegated, expectedSummary.undelegated);
        assertEq(result.totalPendingWithdrawal, expectedSummary.totalPendingWithdrawal);
        assertEq(result.nPendingWithdrawals, expectedSummary.nPendingWithdrawals);
    }

    function test_delegatorSummary_Fail() public {
        address user = makeAddr("user");

        bytes memory expectedCalldata = abi.encode(user);
        _setupFailingPrecompile(L1Read.DELEGATOR_SUMMARY_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("DelegatorySummary precompile call failed"))
        );
        this.delegatorSummary(user);
    }

    function delegatorSummary(address user) external view returns (L1Read.DelegatorSummary memory) {
        return caller.delegatorSummary(user);
    }

    function test_markPx() public {
        uint32 index = 1;
        uint64 expectedPrice = 100_000_000; // 1.0 * 10^8

        bytes memory expectedCalldata = abi.encode(index);
        _setupMockPrecompile(L1Read.MARK_PX_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedPrice));

        uint64 result = caller.markPx(index);
        assertEq(result, expectedPrice);
    }

    function test_markPx_Fail() public {
        uint32 index = 1;

        bytes memory expectedCalldata = abi.encode(index);
        _setupFailingPrecompile(L1Read.MARK_PX_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("MarkPx precompile call failed"))
        );
        this.markPx(index);
    }

    function markPx(uint32 index) external view returns (uint64) {
        return caller.markPx(index);
    }

    function test_oraclePx() public {
        uint32 index = 1;
        uint64 expectedPrice = 99_500_000; // 0.995 * 10^8

        bytes memory expectedCalldata = abi.encode(index);
        _setupMockPrecompile(L1Read.ORACLE_PX_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedPrice));

        uint64 result = caller.oraclePx(index);
        assertEq(result, expectedPrice);
    }

    function test_oraclePx_Fail() public {
        uint32 index = 1;

        bytes memory expectedCalldata = abi.encode(index);
        _setupFailingPrecompile(L1Read.ORACLE_PX_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("OraclePx precompile call failed"))
        );
        this.oraclePx(index);
    }

    function oraclePx(uint32 index) external view returns (uint64) {
        return caller.oraclePx(index);
    }

    function test_spotPx() public {
        uint32 index = 1;
        uint64 expectedPrice = 98_000_000; // 0.98 * 10^8

        bytes memory expectedCalldata = abi.encode(index);
        _setupMockPrecompile(L1Read.SPOT_PX_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedPrice));

        uint64 result = caller.spotPx(index);
        assertEq(result, expectedPrice);
    }

    function test_spotPx_Fail() public {
        uint32 index = 1;

        bytes memory expectedCalldata = abi.encode(index);
        _setupFailingPrecompile(L1Read.SPOT_PX_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("SpotPx precompile call failed"))
        );
        this.spotPx(index);
    }

    function spotPx(uint32 index) external view returns (uint64) {
        return caller.spotPx(index);
    }

    function test_l1BlockNumber() public {
        uint64 expectedBlockNumber = 12_345;

        bytes memory expectedCalldata = abi.encode();
        _setupMockPrecompile(L1Read.L1_BLOCK_NUMBER_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedBlockNumber));

        uint64 result = caller.l1BlockNumber();
        assertEq(result, expectedBlockNumber);
    }

    function test_l1BlockNumber_Fail() public {
        bytes memory expectedCalldata = abi.encode();
        _setupFailingPrecompile(L1Read.L1_BLOCK_NUMBER_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("L1BlockNumber precompile call failed"))
        );
        this.l1BlockNumber();
    }

    function l1BlockNumber() external view returns (uint64) {
        return caller.l1BlockNumber();
    }

    function test_perpAssetInfo() public {
        uint32 perp = 1;
        L1Read.PerpAssetInfo memory expectedInfo = L1Read.PerpAssetInfo({
            coin: "BTC", marginTableId: 10, szDecimals: 8, maxLeverage: 20, onlyIsolated: false
        });

        bytes memory expectedCalldata = abi.encode(perp);
        _setupMockPrecompile(L1Read.PERP_ASSET_INFO_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedInfo));

        L1Read.PerpAssetInfo memory result = caller.perpAssetInfo(perp);
        assertEq(keccak256(bytes(result.coin)), keccak256(bytes(expectedInfo.coin)));
        assertEq(result.marginTableId, expectedInfo.marginTableId);
        assertEq(result.szDecimals, expectedInfo.szDecimals);
        assertEq(result.maxLeverage, expectedInfo.maxLeverage);
        assertEq(result.onlyIsolated, expectedInfo.onlyIsolated);
    }

    function test_perpAssetInfo_Fail() public {
        uint32 perp = 1;

        bytes memory expectedCalldata = abi.encode(perp);
        _setupFailingPrecompile(L1Read.PERP_ASSET_INFO_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("PerpAssetInfo precompile call failed"))
        );
        this.perpAssetInfo(perp);
    }

    function perpAssetInfo(uint32 perp) external view returns (L1Read.PerpAssetInfo memory) {
        return caller.perpAssetInfo(perp);
    }

    function test_spotInfo() public {
        uint32 spot = 1;
        L1Read.SpotInfo memory expectedInfo =
            L1Read.SpotInfo({ name: "BTC/USD", tokens: [uint64(1), uint64(2)] });

        bytes memory expectedCalldata = abi.encode(spot);
        _setupMockPrecompile(L1Read.SPOT_INFO_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedInfo));

        L1Read.SpotInfo memory result = caller.spotInfo(spot);
        assertEq(keccak256(bytes(result.name)), keccak256(bytes(expectedInfo.name)));
        assertEq(result.tokens[0], expectedInfo.tokens[0]);
        assertEq(result.tokens[1], expectedInfo.tokens[1]);
    }

    function test_spotInfo_Fail() public {
        uint32 spot = 1;

        bytes memory expectedCalldata = abi.encode(spot);
        _setupFailingPrecompile(L1Read.SPOT_INFO_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("SpotInfo precompile call failed"))
        );
        this.spotInfo(spot);
    }

    function spotInfo(uint32 spot) external view returns (L1Read.SpotInfo memory) {
        return caller.spotInfo(spot);
    }

    function test_tokenInfo() public {
        uint32 token = 1;
        L1Read.TokenInfo memory expectedInfo = L1Read.TokenInfo({
            name: "Bitcoin",
            spots: new uint64[](2),
            deployerTradingFeeShare: 100,
            deployer: makeAddr("deployer"),
            evmContract: makeAddr("evmContract"),
            szDecimals: 8,
            weiDecimals: 18,
            evmExtraWeiDecimals: 0
        });
        expectedInfo.spots[0] = 1;
        expectedInfo.spots[1] = 2;

        bytes memory expectedCalldata = abi.encode(token);
        _setupMockPrecompile(L1Read.TOKEN_INFO_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedInfo));

        L1Read.TokenInfo memory result = caller.tokenInfo(token);
        assertEq(keccak256(bytes(result.name)), keccak256(bytes(expectedInfo.name)));
        assertEq(result.spots.length, expectedInfo.spots.length);
        assertEq(result.deployerTradingFeeShare, expectedInfo.deployerTradingFeeShare);
        assertEq(result.deployer, expectedInfo.deployer);
        assertEq(result.evmContract, expectedInfo.evmContract);
        assertEq(result.szDecimals, expectedInfo.szDecimals);
        assertEq(result.weiDecimals, expectedInfo.weiDecimals);
        assertEq(result.evmExtraWeiDecimals, expectedInfo.evmExtraWeiDecimals);
    }

    function test_tokenInfo_Fail() public {
        uint32 token = 1;

        bytes memory expectedCalldata = abi.encode(token);
        _setupFailingPrecompile(L1Read.TOKEN_INFO_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("TokenInfo precompile call failed"))
        );
        this.tokenInfo(token);
    }

    function tokenInfo(uint32 token) external view returns (L1Read.TokenInfo memory) {
        return caller.tokenInfo(token);
    }

    function test_tokenSupply() public {
        uint32 token = 1;
        L1Read.UserBalance[] memory nonCirculating = new L1Read.UserBalance[](1);
        nonCirculating[0] = L1Read.UserBalance({ user: makeAddr("user"), balance: 1000 });
        L1Read.TokenSupply memory expectedSupply = L1Read.TokenSupply({
            maxSupply: 21_000_000,
            totalSupply: 19_000_000,
            circulatingSupply: 18_999_000,
            futureEmissions: 500_000,
            nonCirculatingUserBalances: nonCirculating
        });

        bytes memory expectedCalldata = abi.encode(token);
        _setupMockPrecompile(L1Read.TOKEN_SUPPLY_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedSupply));

        L1Read.TokenSupply memory result = caller.tokenSupply(token);
        assertEq(result.maxSupply, expectedSupply.maxSupply);
        assertEq(result.totalSupply, expectedSupply.totalSupply);
        assertEq(result.circulatingSupply, expectedSupply.circulatingSupply);
        assertEq(result.futureEmissions, expectedSupply.futureEmissions);
        assertEq(
            result.nonCirculatingUserBalances.length,
            expectedSupply.nonCirculatingUserBalances.length
        );
    }

    function test_tokenSupply_Fail() public {
        uint32 token = 1;

        bytes memory expectedCalldata = abi.encode(token);
        _setupFailingPrecompile(L1Read.TOKEN_SUPPLY_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("TokenSupply precompile call failed"))
        );
        this.tokenSupply(token);
    }

    function tokenSupply(uint32 token) external view returns (L1Read.TokenSupply memory) {
        return caller.tokenSupply(token);
    }

    function test_bbo() public {
        uint32 asset = 1;
        L1Read.Bbo memory expectedBbo = L1Read.Bbo({ bid: 99_500_000, ask: 100_500_000 });

        bytes memory expectedCalldata = abi.encode(asset);
        _setupMockPrecompile(L1Read.BBO_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedBbo));

        L1Read.Bbo memory result = caller.bbo(asset);
        assertEq(result.bid, expectedBbo.bid);
        assertEq(result.ask, expectedBbo.ask);
    }

    function test_bbo_Fail() public {
        uint32 asset = 1;

        bytes memory expectedCalldata = abi.encode(asset);
        _setupFailingPrecompile(L1Read.BBO_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(bytes.concat(bytes4(0x08c379a0), abi.encode("Bbo precompile call failed")));
        this.bbo(asset);
    }

    function bbo(uint32 asset) external view returns (L1Read.Bbo memory) {
        return caller.bbo(asset);
    }

    function test_accountMarginSummary() public {
        uint32 perpDexIndex = 1;
        address user = makeAddr("user");
        L1Read.AccountMarginSummary memory expectedSummary = L1Read.AccountMarginSummary({
            accountValue: 1_000_000, marginUsed: 500_000, ntlPos: 2_000_000, rawUsd: 800_000
        });

        bytes memory expectedCalldata = abi.encode(perpDexIndex, user);
        _setupMockPrecompile(L1Read.ACCOUNT_MARGIN_SUMMARY_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedSummary));

        L1Read.AccountMarginSummary memory result = caller.accountMarginSummary(perpDexIndex, user);
        assertEq(result.accountValue, expectedSummary.accountValue);
        assertEq(result.marginUsed, expectedSummary.marginUsed);
        assertEq(result.ntlPos, expectedSummary.ntlPos);
        assertEq(result.rawUsd, expectedSummary.rawUsd);
    }

    function test_accountMarginSummary_Fail() public {
        uint32 perpDexIndex = 1;
        address user = makeAddr("user");

        bytes memory expectedCalldata = abi.encode(perpDexIndex, user);
        _setupFailingPrecompile(L1Read.ACCOUNT_MARGIN_SUMMARY_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(
                bytes4(0x08c379a0), abi.encode("Account margin summary precompile call failed")
            )
        );
        this.accountMarginSummary(perpDexIndex, user);
    }

    function accountMarginSummary(uint32 perpDexIndex, address user)
        external
        view
        returns (L1Read.AccountMarginSummary memory)
    {
        return caller.accountMarginSummary(perpDexIndex, user);
    }

    function test_coreUserExists() public {
        address user = makeAddr("user");
        L1Read.CoreUserExists memory expectedExists = L1Read.CoreUserExists({ exists: true });

        bytes memory expectedCalldata = abi.encode(user);
        _setupMockPrecompile(L1Read.CORE_USER_EXISTS_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedExists));

        L1Read.CoreUserExists memory result = caller.coreUserExists(user);
        assertEq(result.exists, expectedExists.exists);
    }

    function test_coreUserExists_Fail() public {
        address user = makeAddr("user");

        bytes memory expectedCalldata = abi.encode(user);
        _setupFailingPrecompile(L1Read.CORE_USER_EXISTS_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(bytes4(0x08c379a0), abi.encode("Core user exists precompile call failed"))
        );
        this.coreUserExists(user);
    }

    function coreUserExists(address user) external view returns (L1Read.CoreUserExists memory) {
        return caller.coreUserExists(user);
    }

    function test_borrowLendUserState() public {
        address user = makeAddr("user");
        uint64 token = 1;
        L1Read.BorrowLendUserTokenState memory expectedState = L1Read.BorrowLendUserTokenState({
            borrow: L1Read.BasisAndValue({ basis: 1000, value: 2000 }),
            supply: L1Read.BasisAndValue({ basis: 5000, value: 10_000 })
        });

        bytes memory expectedCalldata = abi.encode(user, token);
        _setupMockPrecompile(L1Read.BORROW_LEND_USER_STATE_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedState));

        L1Read.BorrowLendUserTokenState memory result = caller.borrowLendUserState(user, token);
        assertEq(result.borrow.basis, expectedState.borrow.basis);
        assertEq(result.borrow.value, expectedState.borrow.value);
        assertEq(result.supply.basis, expectedState.supply.basis);
        assertEq(result.supply.value, expectedState.supply.value);
    }

    function test_borrowLendUserState_Fail() public {
        address user = makeAddr("user");
        uint64 token = 1;

        bytes memory expectedCalldata = abi.encode(user, token);
        _setupFailingPrecompile(L1Read.BORROW_LEND_USER_STATE_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(
                bytes4(0x08c379a0), abi.encode("Borrow lend user state precompile call failed")
            )
        );
        this.borrowLendUserState(user, token);
    }

    function borrowLendUserState(address user, uint64 token)
        external
        view
        returns (L1Read.BorrowLendUserTokenState memory)
    {
        return caller.borrowLendUserState(user, token);
    }

    function test_borrowLendReserveState() public {
        uint64 token = 1;
        L1Read.BorrowLendReserveState memory expectedState = L1Read.BorrowLendReserveState({
            borrowYearlyRateBps: 500,
            supplyYearlyRateBps: 300,
            balance: 1_000_000,
            utilizationBps: 7500,
            oraclePx: 100_000_000,
            ltvBps: 8000,
            totalSupplied: 10_000_000,
            totalBorrowed: 7_500_000
        });

        bytes memory expectedCalldata = abi.encode(token);
        _setupMockPrecompile(L1Read.BORROW_LEND_RESERVE_STATE_PRECOMPILE_ADDRESS, expectedCalldata, abi.encode(expectedState));

        L1Read.BorrowLendReserveState memory result = caller.borrowLendReserveState(token);
        assertEq(result.borrowYearlyRateBps, expectedState.borrowYearlyRateBps);
        assertEq(result.supplyYearlyRateBps, expectedState.supplyYearlyRateBps);
        assertEq(result.balance, expectedState.balance);
        assertEq(result.utilizationBps, expectedState.utilizationBps);
        assertEq(result.oraclePx, expectedState.oraclePx);
        assertEq(result.ltvBps, expectedState.ltvBps);
        assertEq(result.totalSupplied, expectedState.totalSupplied);
        assertEq(result.totalBorrowed, expectedState.totalBorrowed);
    }

    function test_borrowLendReserveState_Fail() public {
        uint64 token = 1;

        bytes memory expectedCalldata = abi.encode(token);
        _setupFailingPrecompile(L1Read.BORROW_LEND_RESERVE_STATE_PRECOMPILE_ADDRESS, expectedCalldata);

        vm.expectRevert(
            bytes.concat(
                bytes4(0x08c379a0), abi.encode("Borrow lend reserve state precompile call failed")
            )
        );
        this.borrowLendReserveState(token);
    }

    function borrowLendReserveState(uint64 token)
        external
        view
        returns (L1Read.BorrowLendReserveState memory)
    {
        return caller.borrowLendReserveState(token);
    }

}
