# LayerRegistry

**LayerRegistry** is deployed at **TBD** on the ethereum mainnet.

## Read-Only Functions

### getLayer

```sql
function getLayer() external view returns (address);
```

Returns the address of the [Layer](layer.md) contract. Returns **\_layer** from the contract and defaults to **address\(0\)**.

### getLayerReverts

```sql
function getLayerReverts() external view returns (address);
```

Returns the address of the [Layer](layer.md) contract. Returns **\_layer** from the contract and if **\_layer** is **address\(0\)**, the function will revert.

