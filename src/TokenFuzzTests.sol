// SPDX-FileCopyrightText: © 2023 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
pragma solidity >=0.8.0;

import "./TokenTests.sol";
import "./TokenFuzzChecks.sol";

abstract contract TokenFuzzTests is TokenTests, TokenFuzzChecks {


    // ************************************************************************************************************
    // Mint/Burn
    // ************************************************************************************************************

    function test_fuzzMint(
        address who,
        uint256 mintAmount
    ) public {
        assertVarsSet();
        fuzzCheckMint(_token_, _contractName_, who, mintAmount);
    }
    function test_fuzzBurn(
        address who,
        uint256 mintAmount,
        uint256 burnAmount
    ) public {
        assertVarsSet();
        fuzzCheckBurn(_token_, who, mintAmount, burnAmount);
    }
    function test_fuzzCheckBurnInsufficientBalance(
        address to,
        uint256 mintAmount,
        uint256 burnAmount
    ) public {
        assertVarsSet();
        fuzzCheckBurnInsufficientBalance(_token_, _contractName_, to, mintAmount, burnAmount);
    }
    function test_fuzzCheckTokenModifiers(
        address sender
    ) public {
        assertVarsSet();
        fuzzCheckTokenModifiers(_token_, _contractName_, sender);
    }

    // ************************************************************************************************************
    // ERC20
    // ************************************************************************************************************
    
    function test_fuzzMetadata(
    ) public {
        assertVarsSet();
        fuzzCheckMetadata(_token_, _tokenName_, _symbol_, _version_, _decimals_);
    }
    function test_fuzzApprove(
        address to,
        uint256 amount
    ) public {
        assertVarsSet();
        fuzzCheckApprove(_token_, to, amount);
    }
    function test_fuzzTransfer(
        address to,
        uint256 amount
    ) public {
        assertVarsSet();
        fuzzCheckTransfer(_token_, to, amount);
    }
    function test_fuzzTransferFrom(
        address to,
        uint256 approval,
        uint256 amount
    ) public {
        assertVarsSet();
        fuzzCheckTransferFrom(_token_, to, approval, amount);
    }
    function test_fuzzCheckTransferInsufficientBalance(
        address to,
        uint256 mintAmount,
        uint256 sendAmount
    ) public {
        assertVarsSet();
        fuzzCheckTransferInsufficientBalance(_token_, _contractName_, to, mintAmount, sendAmount);
    }
    function test_fuzzCheckTransferFromInsufficientBalance(
        address to,
        uint256 mintAmount,
        uint256 sendAmount
    ) public {
        assertVarsSet();
        fuzzCheckTransferFromInsufficientBalance(_token_, _contractName_, to, mintAmount, sendAmount);
    }
    function test_fuzzCheckTransferFromInsufficientAllowance(
        address to,
        uint256 allowance,
        uint256 amount
    ) public {
        assertVarsSet();
        fuzzCheckTransferFromInsufficientAllowance(_token_, _contractName_, to, allowance, amount);
    }
   
    // ************************************************************************************************************
    // Permit
    // ************************************************************************************************************

    function test_fuzzPermitEOA(
        uint248 privKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public {
        assertVarsSet();
        fuzzCheckPermitEOA(_token_, privKey, to, amount, deadline);
    } 
    function test_fuzzPermitBadNonce(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline,
        uint256 nonce
    ) public {
        assertVarsSet();
        fuzzCheckPermitBadNonce(_token_, _contractName_, privKey, to, amount, deadline, nonce);
    } 
    function test_fuzzPermitBadDeadline(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public {
        assertVarsSet();
        fuzzCheckPermitBadDeadline(_token_, _contractName_, privKey, to, amount, deadline);
    } 
    function test_fuzzPermitPastDeadline(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public {
        assertVarsSet();
        fuzzCheckPermitPastDeadline(_token_, _contractName_, privKey, to, amount, deadline);
    } 
    function test_fuzzPermitReplay(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public {
        assertVarsSet();
        fuzzCheckPermitReplay(_token_, _contractName_, privKey, to, amount, deadline);
    } 

}