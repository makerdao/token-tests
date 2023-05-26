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

import "./TokenChecks.sol";

abstract contract TokenTests is TokenChecks {
    address internal _token_;
    string internal _contractName_;
    string internal _tokenName_;
    string internal _symbol_;
    string internal _version_ = "1";
    uint8 internal _decimals_ = 18;

    function assertVarsSet() internal {
        assertTrue(_token_ != address(0), "TokenTests/_token_ is not set");
        assertTrue(bytes(_contractName_).length > 0, "TokenTests/_contractName_ is not set");

        if(bytes(_tokenName_).length > 0) {
            _tokenName_ = TokenLike(_token_).name();
        }
        if(bytes(_symbol_).length > 0) {
            _symbol_ = TokenLike(_token_).symbol();
        }
    }

    // ************************************************************************************************************
    // Mint/Burn
    // ************************************************************************************************************

    function testTokenAuth() public {
        assertVarsSet();
        checkTokenAuth(_token_, _contractName_);
    }
    function testTokenModifiers() public {
        assertVarsSet();
        checkTokenModifiers(_token_, _contractName_);
    }
    function testMint() public {
        assertVarsSet();
        checkMint(_token_);
    }
    function testBurn() public {
        assertVarsSet();
        checkBurn(_token_);
    }
    function testBurnDifferentFrom() public {
        assertVarsSet();
        checkBurnDifferentFrom(_token_);
    }
    function testMintBadAddress() public {
        assertVarsSet();
        checkMintBadAddress(_token_, _contractName_);
    }
    function testBurnInsufficientBalance() public {
        assertVarsSet();
        checkBurnInsufficientBalance(_token_, _contractName_);
    }

    // ************************************************************************************************************
    // ERC20
    // ************************************************************************************************************

    function testMetadata() public {
        assertVarsSet();
        checkMetadata(_token_, _tokenName_, _symbol_, _version_, _decimals_);
    }
    function testApprove() public {
        assertVarsSet();
        checkApprove(_token_);
    }
    function testIncreaseAllowance() public {
        assertVarsSet();
        checkIncreaseAllowance(_token_);
    }
    function testDecreaseAllowance() public {
        assertVarsSet();
        checkDecreaseAllowance(_token_);
    }
    function testTransfer() public {
        assertVarsSet();
        checkTransfer(_token_);
    }
    function testTransferFrom() public {
        assertVarsSet();
        checkTransferFrom(_token_);
    }
    function testInfiniteApproveTransferFrom() public {
        assertVarsSet();
        checkInfiniteApproveTransferFrom(_token_);
    }
    function testDecreaseAllowanceInsufficientAllowance() public {
        assertVarsSet();
        checkDecreaseAllowanceInsufficientAllowance(_token_, _contractName_);
    }
    function testTransferBadAddress() public {
        assertVarsSet();
        checkTransferBadAddress(_token_, _contractName_);
    }
    function testTransferFromBadAddress() public {
        assertVarsSet();
        checkTransferFromBadAddress(_token_, _contractName_);
    }
    function testTransferInsufficientBalance() public {
        assertVarsSet();
        checkTransferInsufficientBalance(_token_, _contractName_);
    }
    function testTransferFromInsufficientAllowance() public {
        assertVarsSet();
        checkTransferFromInsufficientAllowance(_token_, _contractName_);
    }
    function testTransferFromInsufficientBalance() public {
        assertVarsSet();
        checkTransferFromInsufficientBalance(_token_, _contractName_);
    }

    // ************************************************************************************************************
    // Permit
    // ************************************************************************************************************

    function testPermitEOA() public {
        assertVarsSet();
        checkPermitEOA(_token_);
    } 
    function testPermitContract() public {
        assertVarsSet();
        checkPermitContract(_token_);
    } 
    function testPermitContractInvalidSignature() public {
        assertVarsSet();
        checkPermitContractInvalidSignature(_token_, _contractName_);
    }
    function testPermitBadNonce() public {
        assertVarsSet();
        checkPermitBadNonce(_token_, _contractName_);
    } 
    function testPermitBadDeadline() public {
        assertVarsSet();
        checkPermitBadDeadline(_token_, _contractName_);
    } 
    function testPermitPastDeadline() public {
        assertVarsSet();
        checkPermitPastDeadline(_token_, _contractName_);
    } 
    function testPermitOwnerZero() public {
        assertVarsSet();
        checkPermitOwnerZero(_token_, _contractName_);
    } 
    function testPermitReplay() public {
        assertVarsSet();
        checkPermitReplay(_token_, _contractName_);
    } 
}
