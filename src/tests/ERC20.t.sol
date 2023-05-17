// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../TokenTests.sol";
import "./SampleToken.sol";



contract ERC20Test is TokenTests {

    address token;
    string contractName = "SampleToken";
    string tokenName = "Sample Token";
    string symbol = "TKN";
    string version = "1";
    uint8 decimals = 18;

    function setUp() public {
        token = address(new SampleToken());
    }

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
}
