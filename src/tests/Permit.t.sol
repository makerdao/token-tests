// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../TokenTests.sol";
import "./SampleToken.sol";

contract PermitTest is TokenTests {

    address token;
    function setUp() public {
        token = address(new SampleToken());
    }

    function test_checkPermit() public {
        checkPermit(token);
    } 
    function test_checkPermitEOA() public {
        checkPermitEOA(token);
    } 
    function test_checkPermitContract() public {
        checkPermitContract(token);
    } 
    function test_checkPermitContractInvalidSignature() public {
        checkPermitContractInvalidSignature(token);
    } 
    function test_checkPermitBadNonce() public {
        checkPermitBadNonce(token);
    } 
    function test_checkPermitBadDeadline() public {
        checkPermitBadDeadline(token);
    } 
    function test_checkPermitPastDeadline() public {
        checkPermitPastDeadline(token);
    } 
    function test_checkPermitOwnerZero() public {
        checkPermitOwnerZero(token);
    } 
    function test_checkPermitReplay() public {
        checkPermitReplay(token);
    } 

}
