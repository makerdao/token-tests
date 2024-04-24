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

    modifier setup {
        assertTrue(_token_ != address(0), "TokenTests/_token_ is not set");
        assertTrue(bytes(_contractName_).length > 0, "TokenTests/_contractName_ is not set");
        assertTrue(bytes(_tokenName_).length > 0, "TokenTests/_tokenName_ is not set");
        assertTrue(bytes(_symbol_).length > 0, "TokenTests/_symbol_ is not set");
        _;
    }

    // ************************************************************************************************************
    // Mint/Burn
    // ************************************************************************************************************

    function testTokenAuth() public setup {
        checkTokenAuth(_token_, _contractName_);
    }
    function testTokenModifiers() public setup {
        checkTokenModifiers(_token_, _contractName_);
    }
    function testMint() public setup {
        checkMint(_token_);
    }
    function testBurn() public setup {
        checkBurn(_token_);
    }
    function testBurnDifferentFrom() public setup {
        checkBurnDifferentFrom(_token_);
    }
    function testMintBadAddress() public setup {
        checkMintBadAddress(_token_, _contractName_);
    }
    function testBurnInsufficientBalance() public setup {
        checkBurnInsufficientBalance(_token_, _contractName_);
    }
    function testBurnInsufficientAllowance() public setup {
        checkBurnInsufficientAllowance(_token_, _contractName_);
    }

    // ************************************************************************************************************
    // ERC20
    // ************************************************************************************************************

    function testMetadata() public setup view {
        checkMetadata(_token_, _tokenName_, _symbol_, _version_, _decimals_);
    }
    function testApprove() public setup {
        checkApprove(_token_);
    }
    function testTransfer() public setup {
        checkTransfer(_token_);
    }
    function testTransferBadAddress() public setup {
        checkTransferBadAddress(_token_, _contractName_);
    }
    function testTransferInsufficientBalance() public setup {
        checkTransferInsufficientBalance(_token_, _contractName_);
    }
    function testTransferFrom() public setup {
        checkTransferFrom(_token_);
    }
    function testInfiniteApproveTransferFrom() public setup {
        checkInfiniteApproveTransferFrom(_token_);
    }
    function testTransferFromBadAddress() public setup {
        checkTransferFromBadAddress(_token_, _contractName_);
    }
    function testTransferFromInsufficientAllowance() public setup {
        checkTransferFromInsufficientAllowance(_token_, _contractName_);
    }
    function testTransferFromInsufficientBalance() public setup {
        checkTransferFromInsufficientBalance(_token_, _contractName_);
    }

    // ************************************************************************************************************
    // Permit
    // ************************************************************************************************************

    function testPermitEOA() public setup {
        checkPermitEOA(_token_);
    } 
    function testPermitContract() public setup {
        checkPermitContract(_token_);
    } 
    function testPermitContractInvalidSignature() public setup {
        checkPermitContractInvalidSignature(_token_, _contractName_);
    }
    function testPermitBadNonce() public setup {
        checkPermitBadNonce(_token_, _contractName_);
    } 
    function testPermitBadDeadline() public setup {
        checkPermitBadDeadline(_token_, _contractName_);
    } 
    function testPermitPastDeadline() public setup {
        checkPermitPastDeadline(_token_, _contractName_);
    } 
    function testPermitOwnerZero() public setup {
        checkPermitOwnerZero(_token_, _contractName_);
    } 
    function testPermitReplay() public setup {
        checkPermitReplay(_token_, _contractName_);
    } 
}
