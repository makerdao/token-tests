// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../TokenFuzzTests.sol";
import "./SampleToken.sol";



contract ERC20Test is TokenTests, TokenFuzzTests {

    address token;
    string contractName = "SampleToken";
    string tokenName = "Sample Token";
    string symbol = "TKN";
    string version = "1";
    uint8 decimals = 18;

    function setUp() public {
        token = address(new SampleToken());
    }

    // Unit Tests

    function test_checkERC20() public {
        checkERC20(token, contractName, tokenName, symbol, version, decimals);
    }
    function test_checkMetadata() public {
        checkMetadata(token, tokenName, symbol, version, decimals);
    }
    function test_checkApprove() public {
        checkApprove(token);
    }
    function test_checkIncreaseAllowance() public {
        checkIncreaseAllowance(token);
    }
    function test_checkTransfer() public {
        checkTransfer(token);
    }
    function test_checkTransferFrom() public {
        checkTransferFrom(token);
    }
    function test_checkInfiniteApproveTransferFrom() public {
        checkInfiniteApproveTransferFrom(token);
    }
    function test_checkDecreaseAllowanceInsufficientBalance() public {
        checkDecreaseAllowanceInsufficientBalance(token, contractName);
    }
    function testFail_checkDecreaseAllowanceInsufficientBalance() public {
        checkDecreaseAllowanceInsufficientBalance(token, "BadName");
    }
    function test_checkTransferBadAddress() public {
        checkTransferBadAddress(token, contractName);
    }
    function testFail_checkTransferBadAddress() public {
        checkTransferBadAddress(token, "BadName");
    }
    function test_checkTransferFromBadAddress() public {
        checkTransferFromBadAddress(token, contractName);
    }
    function testFail_checkTransferFromBadAddress() public {
        checkTransferFromBadAddress(token, "BadName");
    }
    function test_checkTransferInsufficientBalance() public {
        checkTransferInsufficientBalance(token, contractName);
    }
    function testFail_checkTransferInsufficientBalance() public {
        checkTransferInsufficientBalance(token, "BadName");
    }
    function test_checkTransferFromInsufficientAllowance() public {
        checkTransferFromInsufficientAllowance(token, contractName);
    }
    function testFail_checkTransferFromInsufficientAllowance() public {
        checkTransferFromInsufficientAllowance(token, "BadName");
    }
    function test_checkTransferFromInsufficientBalance() public {
        checkTransferFromInsufficientBalance(token, contractName);
    }
    function testFail_checkTransferFromInsufficientBalance() public {
        checkTransferFromInsufficientBalance(token, "BadName");
    }

    // Fuzz Tests

    function test_fuzzCheckERC20(
        address to,
        uint256 approval,
        uint256 amount
    ) public {
        fuzzCheckERC20(token, to, approval, amount);
    } 
    function test_fuzzCheckApprove(
        address to,
        uint256 amount
    ) public {
        fuzzCheckApprove(token, to, amount);
    } 
    function test_fuzzCheckTransfer(
        address to,
        uint256 amount
    ) public {
        fuzzCheckTransfer(token, to, amount);
    } 
    function test_fuzzCheckTransferFrom(
        address to,
        uint256 approval,
        uint256 amount
    ) public {
        fuzzCheckTransferFrom(token, to, approval, amount);
    } 
}
