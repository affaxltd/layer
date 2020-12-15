# Layer

**Layer** is deployed at **TBD** on the ethereum mainnet.

{% hint style="warning" %}
We recommend getting the **Layer** contract address from the [LayerRegistry](layerregistry.md) contract, as that contract will never change address but the **Layer** might \(critical bugs might be found and wanted to be fixed, requiring a new **Layer** contract\).
{% endhint %}

## Events

### Swap

```csharp
event Swap(
    address indexed buyToken,
    address indexed sellToken,
    address indexed target,
    address initiator,
    uint256 amountIn,
    uint256 slippage,
    uint256 total
);
```

Emitted each time a token gets swapped.

* **buyToken**: the token to "buy" aka swap to
* **sellToken**: the token to "sell" aka swap from
* **target**: the address receives the tokens
* **initiator**: the address that started the swap
* **amountIn**: the amount of sellToken to swap
* **slippage**: the maximum amount of slippage allowed
* **total**: total amount of tokens received from swap

## Read-Only Functions

### getBestDexForSwap

```sql
function getBestDexForSwap(
    address buyToken,
    address sellToken,
    uint256 amount
) external view returns (string memory best, uint256 count);
```

Returns the name and amount of tokens received for the **dex** that gives out most **buyTokens**.

* **buyToken**: the token to "buy" aka swap to
* **sellToken**: the token to "sell" aka swap from
* **amount**: the amount of sellToken to swap

### getAllDexes

```sql
function getAllDexes() external view returns (string[] memory);
```

Returns a string array of all the **dexes**.

## State-Changing Functions

{% hint style="warning" %}
For all of the swap functions, you will have to grant allowance for the **sellToken** of equal or more to the **Layer** contract or the swap will revert.
{% endhint %}

### swapTokenOnMultipleDEXes

```sql
function swapTokenOnMultipleDEXes(
    uint256 amountIn,
    uint256 slippage,
    address payable target,
    address[] memory path,
    string[] memory dexes
) external returns (uint256);
```

### swapTokenOnDEX

```sql
function swapTokenOnDEX(
    address buyToken,
    address sellToken,
    uint256 amountIn,
    uint256 slippage,
    address payable target,
    string memory dexName
) external returns (uint256);
```

### swapTokensOnDEX

```sql
function swapTokensOnDEX(
    address buyToken,
    address[] memory sellTokens,
    uint256[] memory amountsIn,
    uint256 slippage,
    address payable target,
    string memory dexName
) external returns (uint256);
```

Swaps token\(s\) for **buyToken** and returns the amount of **buyTokens** received.

**Will revert if no tokens would be received or not enough tokens were received.**

* **buyToken**: the token to "buy" aka swap to
* **path**: the path for the swaps between multiple dexes
* **sellToken\(s\)**: the token\(s\) to swap from
* **amoun\(s\)In**: the amount\(s\) of sellToken\(s\) to swap
* **slippage:** the maximum amount of slippage allowed
* **target**: the address receives the tokens
* **dexName**: the name of the dex the swap will happen on

