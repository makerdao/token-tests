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

    function testMintFuzz(
        address who,
        uint256 mintAmount
    ) public setup {
        checkMintFuzz(_token_, _contractName_, who, mintAmount);
    }
    function testBurnFuzz(
        address who,
        uint256 mintAmount,
        uint256 burnAmount
    ) public setup {
        checkBurnFuzz(_token_, who, mintAmount, burnAmount);
    }
    function testBurnInsufficientBalanceFuzz(
        address from,
        uint256 mintAmount,
        uint256 burnAmount
    ) public setup {
        checkBurnInsufficientBalanceFuzz(_token_, _contractName_, from, mintAmount, burnAmount);
    }
    function testBurnInsufficientAllowanceFuzz(
        address from,
        uint256 allowance,
        uint256 mintAmount,
        uint256 burnAmount
    ) public setup {
        checkBurnInsufficientAllowanceFuzz(_token_, _contractName_, from, allowance, mintAmount, burnAmount);
    }
    function testTokenModifiersFuzz(
        address sender
    ) public setup {
        checkTokenModifiersFuzz(_token_, _contractName_, sender);
    }

    // ************************************************************************************************************
    // ERC20
    // ************************************************************************************************************
    
    function testApproveFuzz(
        address to,
        uint256 amount
    ) public setup {
        checkApproveFuzz(_token_, to, amount);
    }
    function testTransferFuzz(
        address to,
        uint256 amount
    ) public setup {
        checkTransferFuzz(_token_, to, amount);
    }
    function testTransferFromFuzz(
        address from,
        address to,
        uint256 approval,
        uint256 amount
    ) public setup {
        checkTransferFromFuzz(_token_, from, to, approval, amount);
    }
    function testTransferInsufficientBalanceFuzz(
        address to,
        uint256 mintAmount,
        uint256 sendAmount
    ) public setup {
        checkTransferInsufficientBalanceFuzz(_token_, _contractName_, to, mintAmount, sendAmount);
    }
    function testTransferFromInsufficientBalanceFuzz(
        address from,
        address to,
        uint256 mintAmount,
        uint256 sendAmount
    ) public setup {
        checkTransferFromInsufficientBalanceFuzz(_token_, _contractName_, from, to, mintAmount, sendAmount);
    }
    function testTransferFromInsufficientAllowanceFuzz(
        address from,
        address to,
        uint256 allowance,
        uint256 amount
    ) public setup {
        checkTransferFromInsufficientAllowanceFuzz(_token_, _contractName_, from, to, allowance, amount);
    }
   
    // ************************************************************************************************************
    // Permit
    // ************************************************************************************************************

    function testPermitEOAFuzz(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public setup {
        checkPermitEOAFuzz(_token_, privKey, to, amount, deadline);
    } 
    function testPermitBadNonceFuzz(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline,
        uint256 nonce
    ) public setup {
        checkPermitBadNonceFuzz(_token_, _contractName_, privKey, to, amount, deadline, nonce);
    } 
    function testPermitBadDeadlineFuzz(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public setup {
        checkPermitBadDeadlineFuzz(_token_, _contractName_, privKey, to, amount, deadline);
    } 
    function testPermitPastDeadlineFuzz(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public setup {
        checkPermitPastDeadlineFuzz(_token_, _contractName_, privKey, to, amount, deadline);
    } 
    function testPermitReplayFuzz(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public setup {
        checkPermitReplayFuzz(_token_, _contractName_, privKey, to, amount, deadline);
    } 

}
