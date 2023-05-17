// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../TokenTests.sol";
import "./SampleToken.sol";

contract PermitTest is TokenTests {

    address token;
    string tokenName = "SampleToken";

    function setUp() public {
        token = address(new SampleToken());
    }

    function test_checkPermit() public {
        checkPermit(token, tokenName);
    } 
    function test_checkPermitEOA() public {
        checkPermitEOA(token);
    } 
    function test_checkPermitContract() public {
        checkPermitContract(token);
    } 
    function test_checkPermitContractInvalidSignature() public {
        checkPermitContractInvalidSignature(token, tokenName);
    }
    function testFail_checkPermitContractInvalidSignature_revert_name() public {
        checkPermitContractInvalidSignature(token, "BadName");
    } 
    function test_checkPermitBadNonce() public {
        checkPermitBadNonce(token, tokenName);
    } 
    function testFail_checkPermitBadNonce_revert_name() public {
        checkPermitBadNonce(token, "BadName");
    } 
    function test_checkPermitBadDeadline() public {
        checkPermitBadDeadline(token, tokenName);
    } 
    function testFail_checkPermitBadDeadline_revert_name() public {
        checkPermitBadDeadline(token, "BadName");
    } 
    function test_checkPermitPastDeadline() public {
        checkPermitPastDeadline(token, tokenName);
    } 
    function testFail_checkPermitPastDeadline_revert_name() public {
        checkPermitPastDeadline(token, "BadName");
    } 
    function test_checkPermitOwnerZero() public {
        checkPermitOwnerZero(token, tokenName);
    } 
    function testFail_checkPermitOwnerZero_revert_name() public {
        checkPermitOwnerZero(token, "BadName");
    } 
    function test_checkPermitReplay() public {
        checkPermitReplay(token, tokenName);
    } 
    function testFail_checkPermitReplay_revert_name() public {
        checkPermitReplay(token, "BadName");
    } 

}
