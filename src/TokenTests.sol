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

    function test_MintBurn() public {
        assertVarsSet();
        checkMintBurn(_token_, _contractName_);
    }
    function test_TokenAuth() public {
        assertVarsSet();
        checkTokenAuth(_token_, _contractName_);
    }
    function test_TokenModifiers() public {
        assertVarsSet();
        checkTokenModifiers(_token_, _contractName_);
    }
    function test_Mint() public {
        assertVarsSet();
        checkMint(_token_);
    }
    function test_Burn() public {
        assertVarsSet();
        checkBurn(_token_);
    }
    function test_BurnDifferentFrom() public {
        assertVarsSet();
        checkBurnDifferentFrom(_token_);
    }
    function test_MintBadAddress() public {
        assertVarsSet();
        checkMintBadAddress(_token_, _contractName_);
    }
    function test_BurnInsufficientBalance() public {
        assertVarsSet();
        checkBurnInsufficientBalance(_token_, _contractName_);
    }

    // ************************************************************************************************************
    // ERC20
    // ************************************************************************************************************

    function test_ERC20() public {
        assertVarsSet();
        checkERC20(_token_, _contractName_, _tokenName_, _symbol_, _version_, _decimals_);
    }
    function test_Metadata() public {
        assertVarsSet();
        checkMetadata(_token_, _tokenName_, _symbol_, _version_, _decimals_);
    }
    function test_Approve() public {
        assertVarsSet();
        checkApprove(_token_);
    }
    function test_IncreaseAllowance() public {
        assertVarsSet();
        checkIncreaseAllowance(_token_);
    }
    function test_Transfer() public {
        assertVarsSet();
        checkTransfer(_token_);
    }
    function test_TransferFrom() public {
        assertVarsSet();
        checkTransferFrom(_token_);
    }
    function test_InfiniteApproveTransferFrom() public {
        assertVarsSet();
        checkInfiniteApproveTransferFrom(_token_);
    }
    function test_DecreaseAllowanceInsufficientBalance() public {
        assertVarsSet();
        checkDecreaseAllowanceInsufficientBalance(_token_, _contractName_);
    }
    function test_TransferBadAddress() public {
        assertVarsSet();
        checkTransferBadAddress(_token_, _contractName_);
    }
    function test_TransferFromBadAddress() public {
        assertVarsSet();
        checkTransferFromBadAddress(_token_, _contractName_);
    }
    function test_TransferInsufficientBalance() public {
        assertVarsSet();
        checkTransferInsufficientBalance(_token_, _contractName_);
    }
    function test_TransferFromInsufficientAllowance() public {
        assertVarsSet();
        checkTransferFromInsufficientAllowance(_token_, _contractName_);
    }
    function test_TransferFromInsufficientBalance() public {
        assertVarsSet();
        checkTransferFromInsufficientBalance(_token_, _contractName_);
    }

    // ************************************************************************************************************
    // Permit
    // ************************************************************************************************************

    function test_Permit() public {
        assertVarsSet();
        checkPermit(_token_, _contractName_);
    } 
    function test_PermitEOA() public {
        assertVarsSet();
        checkPermitEOA(_token_);
    } 
    function test_PermitContract() public {
        assertVarsSet();
        checkPermitContract(_token_);
    } 
    function test_PermitContractInvalidSignature() public {
        assertVarsSet();
        checkPermitContractInvalidSignature(_token_, _contractName_);
    }
    function test_PermitBadNonce() public {
        assertVarsSet();
        checkPermitBadNonce(_token_, _contractName_);
    } 
    function test_PermitBadDeadline() public {
        assertVarsSet();
        checkPermitBadDeadline(_token_, _contractName_);
    } 
    function test_PermitPastDeadline() public {
        assertVarsSet();
        checkPermitPastDeadline(_token_, _contractName_);
    } 
    function test_PermitOwnerZero() public {
        assertVarsSet();
        checkPermitOwnerZero(_token_, _contractName_);
    } 
    function test_PermitReplay() public {
        assertVarsSet();
        checkPermitReplay(_token_, _contractName_);
    } 
}