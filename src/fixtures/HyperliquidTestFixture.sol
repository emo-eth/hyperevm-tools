// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { CoreWriter } from "../CoreWriter.sol";
import { FfiPrecompileMock } from "./FfiPrecompileMock.sol";
import { Vm } from "forge-std/Vm.sol";

/// @title HyperliquidTestFixture
/// @notice Test fixture library that makes HyperEVM precompiles and system contracts work in
/// Foundry fork tests.
/// @dev Creates a fork, deploys an FFI-based mock, and etches it to every L1Read precompile
///      address (0x0800-0x0813). Also etches CoreWriter at its system address.
///
///      Usage:
///        import { HyperliquidTestFixture } from "test/HyperliquidTestFixture.sol";
///
///        contract MyTest is Test {
///            function setUp() public {
///                HyperliquidTestFixture.setUp(45_995_652);
///            }
///        }
///
///      Requirements:
///        - `ffi = true` in foundry.toml
///        - `cast` in PATH (standard Foundry install)
library HyperliquidTestFixture {

    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    string constant TESTNET_RPC = "https://rpc.hyperliquid-testnet.xyz/evm";

    address constant CORE_WRITER_ADDRESS = 0x3333333333333333333333333333333333333333;

    /// @notice Set up a fork against the HyperEVM testnet at the given block.
    /// @param blockNumber Block to pin the fork to. 0 = latest.
    function setUp(uint256 blockNumber) internal {
        setUp(TESTNET_RPC, blockNumber);
    }

    /// @notice Set up a fork against a custom RPC at the given block.
    /// @param rpcUrl RPC endpoint URL.
    /// @param blockNumber Block to pin the fork to. 0 = latest.
    function setUp(string memory rpcUrl, uint256 blockNumber) internal {
        // Create fork; resolve actual block number when 0 (latest) is requested
        if (blockNumber > 0) {
            vm.createSelectFork(rpcUrl, blockNumber);
        } else {
            vm.createSelectFork(rpcUrl);
            blockNumber = block.number;
        }
        vm.setEnv("FORK_RPC_URL", rpcUrl);

        // Deploy FFI mock and etch to all L1Read precompile addresses
        FfiPrecompileMock mock = new FfiPrecompileMock(blockNumber);
        bytes memory mockCode = address(mock).code;

        for (uint256 i = 0x0800; i <= 0x0813; i++) {
            address addr = address(uint160(i));
            vm.etch(addr, mockCode);
            vm.allowCheatcodes(addr);
        }

        // Etch CoreWriter at its system address
        CoreWriter writer = new CoreWriter();
        vm.etch(CORE_WRITER_ADDRESS, address(writer).code);
    }

}
