# token-tests

Test suite for a standard "Maker-style" ERC20 token. An example of such a standard token can be found in `src/tests/SampleToken.sol`.

## Getting Started

Run `forge install makerdao/token-tests` in your newly setup repository.

There are two possible ways to use `token-tests`

### 1) Letting `token-tests` handle testing for you

This is the recommended way. Inherit your test contract from `token-tests/TokenTests.sol` instead of `std-forge/Test.sol` (`contract YourTokenTest is TokenTests {`). You will then need to set the following inherited variables:

```solidity
    function setUp() public {
        _token_ = address(new YourToken());
        _contractName_ = "YourToken";
        _tokenName_ = "Your Token";
        _symbol_ = "TKN";
        _version_ = "1"; // this can be omitted, in which case a default value of "1" is assumed
        _decimals_ = 18; // this can be omitted, in which case a default value of 18 is assumed
    }
```

That's it. A suite of tests covering Mint/Burn, ERC20 functionalities and Permit will automatically be run for you. If you also want fuzz tests to be run, use `token-tests/TokenFuzzTests.sol` as your base class (which itself inherits from `TokenTests.sol`).

You can use `tests/TokenTests.t.sol` as an example of this first approach.

### 2) Explicitely specifying your tests in your test class

Alternatively, if you want more fine-grained control over your tests, you can inherit your test contract from `token-tests/TokenChecks.sol`. You will then be able to call individual token testing functions (all starting with the prefix `check`) or, alternatively, bulk testing functions such as `checkBulkERC20()`, `checkBulkMintBurn()` or `checkBulkPermit()`.

If you wish to use fuzz testing functions to fuzz test your token, inherit your test contract from `token-tests/FuzzTokenChecks.sol`. You will then be able to call any of the token fuzz testing functions (all in the form `checkXXXFuzz` or `checkBulkXXXFuzz`).
