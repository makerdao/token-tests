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
    string internal version = "1";
    uint8 internal decimals = 18;

    function assertVarsSet() internal {
        assertTrue(_token_ != address(0), "TokenTests/_token_ is not set");
        assertTrue(bytes(_contractName_).length > 0, "TokenTests/_contractName_ is not set");
        assertTrue(bytes(_tokenName_).length > 0, "TokenTests/_tokenName_ is not set");
        assertTrue(bytes(_symbol_).length > 0, "TokenTests/_symbol_ is not set");
    }

    // ************************************************************************************************************
    // Mint/Burn
    // ************************************************************************************************************

    function test_MintBurn() public {
        assertVarsSet();
        checkMintBurn(_token_, _contractName_);
    }
    function test_Auth() public {
        assertVarsSet();
        checkTokenAuth(_token_, _contractName_);
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

    // TODO: Add tests for ERC20, Permit and fuzzing
}