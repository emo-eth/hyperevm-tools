# HypeEVM Tools

Solidity libraries for building on [HyperEVM](https://hyperliquid.gitbook.io/hyperliquid-docs/hyperevm).

These libraries are based on the L1Read and CoreWriter contracts from the [Hyperliquid documentation](https://hyperliquid.gitbook.io/hyperliquid-docs/for-developers/hyperevm/interacting-with-hypercore).

## Installation

```sh
forge soldeer install hyperevm-tools
```

## Libraries

### L1Read

Read HyperCore L1 state from HyperEVM via precompile staticcalls. Values match the latest L1 state at the time the EVM block is constructed.

```solidity
import { L1Read, Position, SpotBalance } from "hyperevm-tools/L1Read.sol";

contract MyContract {
    function getPosition(address user, uint16 perp) external view returns (Position memory) {
        return L1Read.position(user, perp);
    }

    function getBalance(address user, uint64 token) external view returns (SpotBalance memory) {
        return L1Read.spotBalance(user, token);
    }
}
```

Available functions:

| Function                                | Description                       |
| --------------------------------------- | --------------------------------- |
| `position(address, uint16)`             | Perpetual position (16-bit index) |
| `position2(address, uint32)`            | Perpetual position (32-bit index) |
| `spotBalance(address, uint64)`          | Spot token balance                |
| `userVaultEquity(address, address)`     | User equity in a vault            |
| `withdrawable(address)`                 | Withdrawable amount               |
| `delegations(address)`                  | Staking delegations               |
| `delegatorSummary(address)`             | Aggregated delegation summary     |
| `markPx(uint32)`                        | Mark price                        |
| `oraclePx(uint32)`                      | Oracle price                      |
| `spotPx(uint32)`                        | Spot price                        |
| `l1BlockNumber()`                       | Latest L1 block number            |
| `perpAssetInfo(uint32)`                 | Perp asset metadata               |
| `spotInfo(uint32)`                      | Spot pair metadata                |
| `tokenInfo(uint32)`                     | Token metadata                    |
| `tokenSupply(uint32)`                   | Token supply breakdown            |
| `bbo(uint32)`                           | Best bid and offer                |
| `accountMarginSummary(uint32, address)` | Account margin summary            |
| `coreUserExists(address)`               | Whether user exists on HyperCore  |
| `borrowLendUserState(address, uint64)`  | Borrow/lend user state            |
| `borrowLendReserveState(uint64)`        | Borrow/lend reserve state         |

All functions revert with a typed error (e.g. `PositionPrecompileCallFailed()`) on invalid inputs.

### L1Write

Encode and send actions to HyperCore via the CoreWriter system contract.

```solidity
import { L1Write, TimeInForce, NO_CLOID } from "hyperevm-tools/L1Write.sol";

contract MyContract {
    function placeBid(uint32 asset, uint64 price, uint64 size) external {
        L1Write.sendLimitOrder(asset, true, price, size, false, TimeInForce.Gtc, NO_CLOID);
    }

    function withdraw(uint64 amount) external {
        L1Write.sendStakingWithdraw(amount);
    }
}
```

Each action has an `encode*` variant (which returns the encoded bytes of the CoreWriter action) and a `send*` variant (which both encodes and sends the action):

| Function                          | Description                     |
| --------------------------------- | ------------------------------- |
| `sendLimitOrder(...)`             | Limit order (perp)              |
| `sendVaultTransfer(...)`          | Vault deposit/withdrawal        |
| `sendTokenDelegate(...)`          | Token delegate/undelegate       |
| `sendStakingDeposit(...)`         | Staking deposit                 |
| `sendStakingWithdraw(...)`        | Staking withdraw                |
| `sendSpotSend(...)`               | Spot token send                 |
| `sendUsdClassTransfer(...)`       | USD transfer perp ↔ spot        |
| `sendFinalizeEvmContract(...)`    | Finalize EVM contract           |
| `sendAddApiWallet(...)`           | Add API wallet                  |
| `sendCancelOrderByOid(...)`       | Cancel order by order ID        |
| `sendCancelOrderByCloid(...)`     | Cancel order by client order ID |
| `sendApproveBuilderFee(...)`      | Approve builder fee             |
| `sendAsset(...)`                  | Cross-DEX asset transfer        |
| `sendReflectEvmSupplyChange(...)` | Reflect EVM supply (mint/burn)  |
| `sendBorrowLendOperation(...)`    | Borrow/lend operation (testnet) |

## Testing

Run unit tests:

```sh
forge test
```

### Fork Tests

Fork tests call the real HyperEVM testnet precompiles via FFI. They require `cast` in your PATH.

```sh
FOUNDRY_PROFILE=ffi forge test
```

### HyperliquidTestFixture

`hyperevm-tools` includes a test fixture that allows networked fork tests to call HyperEVM precompiles and the CoreWriter system contract by using an FFI-based mock to query the real chain using `cast`. No manual mocking is required. Pass block number `0` to use the RPC's latest block instead of a pinned block.

Since it requires FFI to be enabled, it is recommended to make a separate test profile and directory for forked tests:

```toml
[profile.ffi]
test = "<fork-test-directory>"
ffi = true
```

Then run with `FOUNDRY_PROFILE=ffi forge test`.

```solidity
import { HyperliquidTestFixture } from "hyperevm-tools/fixtures/HyperliquidTestFixture.sol";
import { Test } from "forge-std/Test.sol";

contract MyForkTest is Test {
    function setUp() public {
        // Testnet at a pinned block:
        HyperliquidTestFixture.setUp(45_995_652);
        // Or custom RPC at latest block (0 = latest):
        // HyperliquidTestFixture.setUp("https://custom-rpc.example.com", 0);
    }

    function test_readPosition() public view {
        Position memory pos = L1Read.position(user, 0);
        // ...
    }
}
```

## License

MIT
