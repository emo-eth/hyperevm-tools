# Juba

Solidity libraries for building on [HyperEVM](https://hyperliquid.gitbook.io/hyperliquid-docs/hyperevm).

## Installation

```sh
forge soldeer install juba
```

## Libraries

### L1Read

Read HyperCore L1 state from HyperEVM via precompile staticcalls. Values match the latest L1 state at the time the EVM block is constructed.

```solidity
import { L1Read, Position, SpotBalance } from "juba/L1Read.sol";

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

| Function | Description |
|---|---|
| `position(address, uint16)` | Perpetual position (16-bit index) |
| `position2(address, uint32)` | Perpetual position (32-bit index) |
| `spotBalance(address, uint64)` | Spot token balance |
| `userVaultEquity(address, address)` | User equity in a vault |
| `withdrawable(address)` | Withdrawable amount |
| `delegations(address)` | Staking delegations |
| `delegatorSummary(address)` | Aggregated delegation summary |
| `markPx(uint32)` | Mark price |
| `oraclePx(uint32)` | Oracle price |
| `spotPx(uint32)` | Spot price |
| `l1BlockNumber()` | Latest L1 block number |
| `perpAssetInfo(uint32)` | Perp asset metadata |
| `spotInfo(uint32)` | Spot pair metadata |
| `tokenInfo(uint32)` | Token metadata |
| `tokenSupply(uint32)` | Token supply breakdown |
| `bbo(uint32)` | Best bid and offer |
| `accountMarginSummary(uint32, address)` | Account margin summary |
| `coreUserExists(address)` | Whether user exists on HyperCore |
| `borrowLendUserState(address, uint64)` | Borrow/lend user state |
| `borrowLendReserveState(uint64)` | Borrow/lend reserve state |

All functions revert with a typed error (e.g. `PositionPrecompileCallFailed()`) on invalid inputs.

### L1Write

Encode and send actions to HyperCore via the CoreWriter system contract.

```solidity
import { L1Write, TimeInForce, NO_CLOID } from "juba/L1Write.sol";

contract MyContract {
    function placeBid(uint32 asset, uint64 price, uint64 size) external {
        L1Write.sendLimitOrder(asset, true, price, size, false, TimeInForce.Gtc, NO_CLOID);
    }

    function withdraw(uint64 amount) external {
        L1Write.sendStakingWithdraw(amount);
    }
}
```

Each action has an `encode*` variant (returns bytes) and a `send*` variant (encodes and sends):

`sendLimitOrder`, `sendVaultTransfer`, `sendTokenDelegate`, `sendStakingDeposit`, `sendStakingWithdraw`, `sendSpotSend`, `sendUsdClassTransfer`, `sendFinalizeEvmContract`, `sendAddApiWallet`, `sendCancelOrderByOid`, `sendCancelOrderByCloid`, `sendApproveBuilderFee`, `sendAsset`, `sendReflectEvmSupplyChange`, `sendBorrowLendOperation`

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

A test fixture that makes HyperEVM precompiles and the CoreWriter system contract work transparently in Foundry fork tests. No manual mocking required.

```solidity
import { HyperliquidTestFixture } from "juba/fixtures/HyperliquidTestFixture.sol";
import { Test } from "forge-std/Test.sol";

contract MyForkTest is Test {
    function setUp() public {
        HyperliquidTestFixture.setUp(45_995_652); // pin to block
    }

    function test_readPosition() public view {
        Position memory pos = L1Read.position(user, 0);
        // ...
    }
}
```

Pass `0` for latest block. Use the two-argument form for a custom RPC:

```solidity
HyperliquidTestFixture.setUp("https://custom-rpc.example.com", blockNumber);
```

Add to your `foundry.toml`:

```toml
[profile.ffi]
test = "test-ffi"
ffi = true
```

Then run with `FOUNDRY_PROFILE=ffi forge test`.

## License

MIT
