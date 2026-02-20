// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    BorrowLendUserStatePrecompileCallFailed,
    VaultEquityPrecompileCallFailed
} from "../src/L1Read.sol";
import { HyperliquidTestFixture } from "../src/fixtures/HyperliquidTestFixture.sol";
import { L1ReadCaller } from "../test/L1ReadCaller.sol";
import { Test } from "forge-std/Test.sol";

/// @notice Fork tests that call L1Read precompiles against HyperEVM testnet.
/// @dev HyperliquidTestFixture etches an FFI mock at each precompile address.
///      The mock pauses gas metering, shells out to `cast call`, then resumes.
///      This makes all calls — capped and uncapped — work transparently.
contract L1ReadForkTest is Test {

    uint256 constant FORK_BLOCK = 45_995_652;

    L1ReadCaller caller;

    address constant ZERO = address(0);
    uint32 constant BTC_PERP = 0;

    function setUp() public {
        HyperliquidTestFixture.setUp(FORK_BLOCK);
        caller = new L1ReadCaller();
    }

    // ============ Capped gas functions ============

    function test_position() public view {
        caller.position(ZERO, uint16(BTC_PERP));
    }

    function test_position2() public view {
        caller.position2(ZERO, BTC_PERP);
    }

    function test_spotBalance() public view {
        caller.spotBalance(ZERO, 0);
    }

    function test_userVaultEquity_revertsOnInvalidInput() public {
        vm.expectRevert(VaultEquityPrecompileCallFailed.selector);
        caller.userVaultEquity(ZERO, ZERO);
    }

    function test_withdrawable() public view {
        caller.withdrawable(ZERO);
    }

    function test_delegatorSummary() public view {
        caller.delegatorSummary(ZERO);
    }

    function test_markPx() public view {
        caller.markPx(BTC_PERP);
    }

    function test_oraclePx() public view {
        caller.oraclePx(BTC_PERP);
    }

    function test_spotPx() public view {
        caller.spotPx(BTC_PERP);
    }

    function test_l1BlockNumber() public view {
        caller.l1BlockNumber();
    }

    function test_bbo() public view {
        caller.bbo(BTC_PERP);
    }

    function test_accountMarginSummary() public view {
        caller.accountMarginSummary(0, ZERO);
    }

    function test_coreUserExists() public view {
        caller.coreUserExists(ZERO);
    }

    function test_borrowLendUserState_revertsOnInvalidInput() public {
        vm.expectRevert(BorrowLendUserStatePrecompileCallFailed.selector);
        caller.borrowLendUserState(ZERO, 0);
    }

    function test_borrowLendReserveState() public view {
        caller.borrowLendReserveState(0);
    }

    // ============ Uncapped (dynamic output) functions ============

    function test_delegations() public view {
        caller.delegations(ZERO);
    }

    function test_perpAssetInfo() public view {
        caller.perpAssetInfo(BTC_PERP);
    }

    function test_spotInfo() public view {
        caller.spotInfo(BTC_PERP);
    }

    function test_tokenInfo() public view {
        caller.tokenInfo(0);
    }

    function test_tokenSupply() public view {
        caller.tokenSupply(0);
    }

}
