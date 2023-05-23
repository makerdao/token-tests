// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../TokenFuzzChecks.sol";
import "./SampleToken.sol";

contract MintBurnTest is TokenChecks, TokenFuzzChecks {

    address token;
    string tokenName = "SampleToken";

    function setUp() public {
        token = address(new SampleToken());
        TokenLike(token).deny(address(this));
    }

    // Unit tests

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

    // Fuzz tests


    function test_fuzzCheckMintBurn(
        address who,
        uint256 mintAmount,
        uint256 burnAmount
    ) public {
        fuzzCheckMintBurn(token, tokenName, who, mintAmount, burnAmount);
    } 
    function test_fuzzCheckMint(
        address who,
        uint256 mintAmount
    ) public {
        fuzzCheckMint(token, tokenName, who, mintAmount);
    } 
    function test_fuzzCheckBurn(
        address who,
        uint256 mintAmount,
        uint256 burnAmount
    ) public {
        fuzzCheckBurn(token, who, mintAmount, burnAmount);
    } 
}
