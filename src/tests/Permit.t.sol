// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../TokenFuzzChecks.sol";
import "./SampleToken.sol";

contract PermitTest is TokenChecks, TokenFuzzChecks {

    address token;
    string contractName = "SampleToken";

    function setUp() public {
        token = address(new SampleToken());
        TokenLike(token).deny(address(this));
    }

    // Unit tests

    function test_checkPermit() public {
        checkPermit(token, contractName);
    }
    function test_checkPermitEOA() public {
        checkPermitEOA(token);
    }
    function test_checkPermitContract() public {
        checkPermitContract(token);
    }
    function test_checkPermitContractInvalidSignature() public {
        checkPermitContractInvalidSignature(token, contractName);
    }
    function testFail_checkPermitContractInvalidSignature_revert_name() public {
        checkPermitContractInvalidSignature(token, "BadName");
    }
    function test_checkPermitBadNonce() public {
        checkPermitBadNonce(token, contractName);
    }
    function testFail_checkPermitBadNonce_revert_name() public {
        checkPermitBadNonce(token, "BadName");
    }
    function test_checkPermitBadDeadline() public {
        checkPermitBadDeadline(token, contractName);
    }
    function testFail_checkPermitBadDeadline_revert_name() public {
        checkPermitBadDeadline(token, "BadName");
    }
    function test_checkPermitPastDeadline() public {
        checkPermitPastDeadline(token, contractName);
    }
    function testFail_checkPermitPastDeadline_revert_name() public {
        checkPermitPastDeadline(token, "BadName");
    }
    function test_checkPermitOwnerZero() public {
        checkPermitOwnerZero(token, contractName);
    }
    function testFail_checkPermitOwnerZero_revert_name() public {
        checkPermitOwnerZero(token, "BadName");
    }
    function test_checkPermitReplay() public {
        checkPermitReplay(token, contractName);
    }
    function testFail_checkPermitReplay_revert_name() public {
        checkPermitReplay(token, "BadName");
    }

    // Fuzz tests

    function test_fuzzCheckPermit(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline,
        uint256 nonce
    ) public {
        fuzzCheckPermit(token, contractName, privKey, to, amount, deadline, nonce);
    }
    function test_fuzzCheckPermitEOA(
        uint248 privKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public {
        fuzzCheckPermitEOA(token, privKey, to, amount, deadline);
    }
    function test_fuzzCheckPermitBadNonce(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline,
        uint256 nonce
    ) public {
        fuzzCheckPermitBadNonce(token, contractName, privKey, to, amount, deadline, nonce);
    }
    function test_fuzzCheckPermitBadDeadline(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public {
        fuzzCheckPermitBadDeadline(token, contractName, privKey, to, amount, deadline);
    }
    function test_fuzzCheckPermitPastDeadline(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public {
        fuzzCheckPermitPastDeadline(token, contractName, privKey, to, amount, deadline);
    }
    function test_fuzzCheckPermitReplay(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public {
        fuzzCheckPermitReplay(token, contractName, privKey, to, amount, deadline);
    }

}