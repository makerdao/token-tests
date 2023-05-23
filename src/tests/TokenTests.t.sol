// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../TokenFuzzTests.sol";
import "./SampleToken.sol";

contract TokenTestsTests is TokenTests, TokenFuzzTests 
 {
    function setUp() public {
        _token_ = address(new SampleToken());
        _tokenName_ = "Sample Token";
        _contractName_ = "SampleToken";
        _symbol_ = "TKN";
        TokenLike(_token_).deny(address(this));
    }
}
