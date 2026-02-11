// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { CoreWriter } from "../src/CoreWriter.sol";
import {
    BORROW_LEND_MAX_AMOUNT,
    BorrowLendOperation,
    FinalizeVariant,
    L1Write,
    NO_CLOID,
    SPOT_DEX,
    TimeInForce
} from "../src/L1Write.sol";
import { Test } from "forge-std/Test.sol";

// Test contract that uses L1Write library
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

contract L1WriteTest is Test {

    address constant CORE_WRITER_ADDRESS = 0x3333333333333333333333333333333333333333;

    L1WriteCaller caller;
    CoreWriter coreWriter;

    function setUp() public {
        // Deploy CoreWriter and etch it to the expected address
        coreWriter = new CoreWriter();
        bytes memory code = address(coreWriter).code;
        vm.etch(CORE_WRITER_ADDRESS, code);

        // Deploy test caller contract
        caller = new L1WriteCaller();
    }

    function test_sendLimitOrder() public {
        uint32 asset = 1;
        bool isBuy = true;
        uint64 limitPx = 100_000_000; // 1.0 * 10^8
        uint64 sz = 50_000_000; // 0.5 * 10^8
        bool reduceOnly = false;
        TimeInForce tif = TimeInForce.Gtc;
        uint128 cloid = 12_345;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_LIMIT_ORDER,
                abi.encode(asset, isBuy, limitPx, sz, reduceOnly, uint8(tif) + 1, cloid)
            )
        );

        caller.sendLimitOrder(asset, isBuy, limitPx, sz, reduceOnly, tif, cloid);
    }

    function test_sendLimitOrder_AllTimeInForce() public {
        uint32 asset = 1;
        bool isBuy = true;
        uint64 limitPx = 100_000_000;
        uint64 sz = 50_000_000;
        bool reduceOnly = false;
        uint128 cloid = 0;

        // Test Alo
        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_LIMIT_ORDER,
                abi.encode(asset, isBuy, limitPx, sz, reduceOnly, 1, cloid)
            )
        );
        caller.sendLimitOrder(asset, isBuy, limitPx, sz, reduceOnly, TimeInForce.Alo, cloid);

        // Test Gtc
        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_LIMIT_ORDER,
                abi.encode(asset, isBuy, limitPx, sz, reduceOnly, 2, cloid)
            )
        );
        caller.sendLimitOrder(asset, isBuy, limitPx, sz, reduceOnly, TimeInForce.Gtc, cloid);

        // Test Ioc
        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_LIMIT_ORDER,
                abi.encode(asset, isBuy, limitPx, sz, reduceOnly, 3, cloid)
            )
        );
        caller.sendLimitOrder(asset, isBuy, limitPx, sz, reduceOnly, TimeInForce.Ioc, cloid);
    }

    function test_sendVaultTransfer() public {
        address vault = address(0x1234);
        bool isDeposit = true;
        uint64 usd = 1_000_000_000; // 10.0 * 10^8

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(L1Write.ACTION_VAULT_TRANSFER, abi.encode(vault, isDeposit, usd))
        );

        caller.sendVaultTransfer(vault, isDeposit, usd);
    }

    function test_sendTokenDelegate() public {
        address validator = address(0x5678);
        uint64 amount = 1000;
        bool isUndelegate = false;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_TOKEN_DELEGATE, abi.encode(validator, amount, isUndelegate)
            )
        );

        caller.sendTokenDelegate(validator, amount, isUndelegate);
    }

    function test_sendStakingDeposit() public {
        uint64 amount = 5000;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller), abi.encodePacked(L1Write.ACTION_STAKING_DEPOSIT, abi.encode(amount))
        );

        caller.sendStakingDeposit(amount);
    }

    function test_sendStakingWithdraw() public {
        uint64 amount = 3000;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller), abi.encodePacked(L1Write.ACTION_STAKING_WITHDRAW, abi.encode(amount))
        );

        caller.sendStakingWithdraw(amount);
    }

    function test_sendSpotSend() public {
        address destination = address(0x9ABC);
        uint64 token = 42;
        uint64 amount = 100_000;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(L1Write.ACTION_SPOT_SEND, abi.encode(destination, token, amount))
        );

        caller.sendSpotSend(destination, token, amount);
    }

    function test_sendUsdClassTransfer() public {
        uint64 ntl = 2_000_000_000; // 20.0 * 10^8
        bool toPerp = true;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(L1Write.ACTION_USD_CLASS_TRANSFER, abi.encode(ntl, toPerp))
        );

        caller.sendUsdClassTransfer(ntl, toPerp);
    }

    function test_sendFinalizeEvmContract() public {
        uint64 token = 10;
        FinalizeVariant variant = FinalizeVariant.Create;
        uint64 createNonce = 5;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_FINALIZE_EVM_CONTRACT,
                abi.encode(token, uint8(variant) + 1, createNonce)
            )
        );

        caller.sendFinalizeEvmContract(token, variant, createNonce);
    }

    function test_sendFinalizeEvmContract_AllVariants() public {
        uint64 token = 10;
        uint64 createNonce = 5;

        // Test Create
        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_FINALIZE_EVM_CONTRACT, abi.encode(token, 1, createNonce)
            )
        );
        caller.sendFinalizeEvmContract(token, FinalizeVariant.Create, createNonce);

        // Test FirstStorageSlot
        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_FINALIZE_EVM_CONTRACT, abi.encode(token, 2, createNonce)
            )
        );
        caller.sendFinalizeEvmContract(token, FinalizeVariant.FirstStorageSlot, createNonce);

        // Test CustomStorageSlot
        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_FINALIZE_EVM_CONTRACT, abi.encode(token, 3, createNonce)
            )
        );
        caller.sendFinalizeEvmContract(token, FinalizeVariant.CustomStorageSlot, createNonce);
    }

    function test_sendAddApiWallet() public {
        address apiWallet = address(0xDEF0);
        string memory apiWalletName = "My API Wallet";

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(L1Write.ACTION_ADD_API_WALLET, abi.encode(apiWallet, apiWalletName))
        );

        caller.sendAddApiWallet(apiWallet, apiWalletName);
    }

    function test_sendAddApiWallet_EmptyName() public {
        address apiWallet = address(0xDEF0);
        string memory apiWalletName = "";

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(L1Write.ACTION_ADD_API_WALLET, abi.encode(apiWallet, apiWalletName))
        );

        caller.sendAddApiWallet(apiWallet, apiWalletName);
    }

    function test_sendCancelOrderByOid() public {
        uint32 asset = 2;
        uint64 oid = 98_765;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(L1Write.ACTION_CANCEL_ORDER_BY_OID, abi.encode(asset, oid))
        );

        caller.sendCancelOrderByOid(asset, oid);
    }

    function test_sendCancelOrderByCloid() public {
        uint32 asset = 2;
        uint128 cloid = 123_456_789;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(L1Write.ACTION_CANCEL_ORDER_BY_CLOID, abi.encode(asset, cloid))
        );

        caller.sendCancelOrderByCloid(asset, cloid);
    }

    function test_sendApproveBuilderFee() public {
        uint64 maxFeeRate = 10; // 0.01%
        address builder = address(0x1111);

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(L1Write.ACTION_APPROVE_BUILDER_FEE, abi.encode(maxFeeRate, builder))
        );

        caller.sendApproveBuilderFee(maxFeeRate, builder);
    }

    function test_sendAsset() public {
        address destination = address(0x2222);
        address subAccount = address(0);
        uint32 sourceDex = SPOT_DEX;
        uint32 destinationDex = SPOT_DEX;
        uint64 token = 7;
        uint64 amount = 500_000;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_SEND_ASSET,
                abi.encode(destination, subAccount, sourceDex, destinationDex, token, amount)
            )
        );

        caller.sendAsset(destination, subAccount, sourceDex, destinationDex, token, amount);
    }

    function test_sendAsset_WithSubAccount() public {
        address destination = address(0x2222);
        address subAccount = address(0x3333);
        uint32 sourceDex = 1;
        uint32 destinationDex = 2;
        uint64 token = 7;
        uint64 amount = 500_000;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_SEND_ASSET,
                abi.encode(destination, subAccount, sourceDex, destinationDex, token, amount)
            )
        );

        caller.sendAsset(destination, subAccount, sourceDex, destinationDex, token, amount);
    }

    function test_sendReflectEvmSupplyChange() public {
        uint64 token = 15;
        uint64 amount = 1_000_000;
        bool isMint = true;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_REFLECT_EVM_SUPPLY_CHANGE, abi.encode(token, amount, isMint)
            )
        );

        caller.sendReflectEvmSupplyChange(token, amount, isMint);
    }

    function test_sendBorrowLendOperation() public {
        BorrowLendOperation operation = BorrowLendOperation.Supply;
        uint64 token = 20;
        uint64 amount = 10_000;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_BORROW_LEND_OPERATION, abi.encode(uint8(operation), token, amount)
            )
        );

        caller.sendBorrowLendOperation(operation, token, amount);
    }

    function test_sendBorrowLendOperation_AllOperations() public {
        uint64 token = 20;
        uint64 amount = 10_000;

        // Test Supply
        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_BORROW_LEND_OPERATION, abi.encode(uint8(0), token, amount)
            )
        );
        caller.sendBorrowLendOperation(BorrowLendOperation.Supply, token, amount);

        // Test Withdraw
        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_BORROW_LEND_OPERATION, abi.encode(uint8(1), token, amount)
            )
        );
        caller.sendBorrowLendOperation(BorrowLendOperation.Withdraw, token, amount);
    }

    function test_sendBorrowLendOperation_MaxAmount() public {
        BorrowLendOperation operation = BorrowLendOperation.Withdraw;
        uint64 token = 20;
        uint64 amount = BORROW_LEND_MAX_AMOUNT;

        vm.expectEmit(true, false, false, true);
        emit CoreWriter.RawAction(
            address(caller),
            abi.encodePacked(
                L1Write.ACTION_BORROW_LEND_OPERATION, abi.encode(uint8(operation), token, amount)
            )
        );

        caller.sendBorrowLendOperation(operation, token, amount);
    }

    function test_actionEncoding() public pure {
        // Test that action encoding is correct: version (0x01) + 3-byte action ID
        uint8 actionId = 5;
        bytes4 expected = bytes4(uint32(0x01000000 | actionId));
        assertEq(uint32(expected), 0x01000005);
    }

    function test_constants() public pure {
        // Test that constants are correct
        assertEq(SPOT_DEX, type(uint32).max);
        assertEq(BORROW_LEND_MAX_AMOUNT, 0);
        assertEq(NO_CLOID, 0);
    }

}
