// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../TokenTests.sol";
import "./SampleToken.sol";

contract MintBurnTest is TokenTests {

    address token;
    string tokenName = "SampleToken";

    function setUp() public {
        token = address(new SampleToken());
    }

    function test_checkMintBurn() public {
        checkMintBurn(token, tokenName);
    } 
    function test_checkAuth() public {
        checkTokenAuth(token, tokenName);
    } 
    function test_checkMint() public {
        checkMint(token);
    } 
    function test_checkBurn() public {
        checkBurn(token);
    }
    function test_checkBurnDifferentFrom() public {
        checkBurnDifferentFrom(token);
    }
    function testFail_checkMintBadAddress_revert_name() public {
        checkMintBadAddress(token, "BadName");
    } 
    function test_checkMintBadAddress() public {
        checkMintBadAddress(token, tokenName);
    }
}
