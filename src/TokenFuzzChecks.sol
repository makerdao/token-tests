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

/** 
 * @title Token Fuzz Checks
 * @dev Contains fuzz checks for token contracts similar to test/SampleToken.sol
 */
contract TokenFuzzChecks is TokenChecks {

    using GodMode for *;

    // ************************************************************************************************************
    // Mint/Burn
    // ************************************************************************************************************

    function fuzzCheckMintBurn(
        address _token,
        string memory _contractName,
        address who,
        uint256 mintAmount,
        uint256 burnAmount
    ) public {
        fuzzCheckMint(_token, _contractName, who, mintAmount);
        fuzzCheckBurn(_token, who, mintAmount, burnAmount);
    }


    function fuzzCheckMint(
        address _token,
        string memory _contractName,
        address to,
        uint256 mintAmount
    ) public {
        uint256 prevSupply = TokenLike(_token).totalSupply();
        uint256 prevToBalance = TokenLike(_token).balanceOf(to);
        mintAmount = bound(mintAmount, 0, type(uint256).max - prevSupply);
        uint256 prevWard = TokenLike(_token).wards(address(this));
        _token.setWard(address(this), 1);
        if (to != address(0) && to != _token) {
            vm.expectEmit(true, true, true, true);
            emit Transfer(address(0), to, mintAmount);
        } else {
            vm.expectRevert(abi.encodePacked(_contractName, "/invalid-address"));
        }

        TokenLike(_token).mint(to, mintAmount);

        if (to != address(0) && to != _token) {
            assertEq(TokenLike(_token).totalSupply(), prevSupply + mintAmount);
            assertEq(TokenLike(_token).balanceOf(to), prevToBalance + mintAmount);
        }
        _token.setWard(address(this), prevWard);
    }

    function fuzzCheckBurn(
        address _token,
        address from,
        uint256 mintAmount,
        uint256 burnAmount
    ) public {
        if (from == address(0) || from == _token) return;
        uint256 prevSupply = TokenLike(_token).totalSupply();
        uint256 prevFromBalance = TokenLike(_token).balanceOf(from);
        mintAmount = bound(mintAmount, 0, type(uint256).max - prevSupply);
        burnAmount = bound(burnAmount, 0, mintAmount);

        forceMint(_token, from, mintAmount);

        vm.expectEmit(true, true, true, true);
        emit Transfer(from, address(0), burnAmount);
        vm.prank(from);
        TokenLike(_token).burn(from, burnAmount);

        assertEq(TokenLike(_token).totalSupply(), prevSupply + mintAmount - burnAmount);
        assertEq(TokenLike(_token).balanceOf(from), prevFromBalance + mintAmount - burnAmount);
    }

    // ************************************************************************************************************
    // ERC20
    // ************************************************************************************************************

    function fuzzCheckERC20(
        address _token,
        string memory _tokenName,
        string memory _symbol,
        string memory _version,
        uint8 _decimals,
        address to,
        uint256 approval,
        uint256 amount
    ) public {
        fuzzCheckMetadata(_token, _tokenName, _symbol, _version, _decimals);
        fuzzCheckApprove(_token, to, amount);
        fuzzCheckTransfer(_token, to, amount);
        fuzzCheckTransferFrom(_token, to, approval, amount);
    }

    function fuzzCheckMetadata(
        address _token,
        string memory _tokenName,
        string memory _symbol,
        string memory _version,
        uint8 _decimals
    ) public {
        assertEq(TokenLike(_token).version(), _version); // Note that this is not part of the ERC20 standard
        assertEq(TokenLike(_token).name(), _tokenName);
        assertEq(TokenLike(_token).symbol(), _symbol);
        assertEq(TokenLike(_token).decimals(), _decimals);
    }

    function fuzzCheckApprove(
        address _token,
        address to,
        uint256 amount
    ) public {
        uint256 prevAllowance = TokenLike(_token).allowance(address(this), to);

        vm.expectEmit(true, true, true, true);
        emit Approval(address(this), to, amount);
        assertTrue(TokenLike(_token).approve(to, amount));

        assertEq(TokenLike(_token).allowance(address(this), to), prevAllowance + amount);
    }

    function fuzzCheckTransfer(
        address _token,
        address to,
        uint256 amount
    ) public {
        if (to == address(0) || to == _token) return;
        uint256 prevToBalance = TokenLike(_token).balanceOf(to);
        amount = bound(amount, 0, type(uint256).max - prevToBalance);
        forceMint(_token, address(this), amount);
        uint256 prevSupply = TokenLike(_token).totalSupply();
        uint256 prevSenderBalance = TokenLike(_token).balanceOf(address(this));

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(this), to, amount);
        assertTrue(TokenLike(_token).transfer(to, amount));

        assertEq(TokenLike(_token).totalSupply(), prevSupply);
        if (address(this) == to) {
            assertEq(TokenLike(_token).balanceOf(address(this)), prevSenderBalance);
        } else {
            assertEq(TokenLike(_token).balanceOf(address(this)), prevSenderBalance - amount);
            assertEq(TokenLike(_token).balanceOf(to), prevToBalance + amount);
        }
    }

    function fuzzCheckTransferFrom(
        address _token,
        address to,
        uint256 approval,
        uint256 amount
    ) public {
        if (to == address(0) || to == _token) return;
        uint256 prevToBalance = TokenLike(_token).balanceOf(to);
        approval = bound(approval, 0, type(uint256).max - prevToBalance);
        amount = bound(amount, 0, approval);
        address from = address(0xABCD);
        forceMint(_token, from, amount);
        uint256 prevSupply = TokenLike(_token).totalSupply();
        uint256 prevFromBalance = TokenLike(_token).balanceOf(from);
        vm.prank(from);
        TokenLike(_token).approve(address(this), approval);

        vm.expectEmit(true, true, true, true);
        emit Transfer(from, to, amount);
        assertTrue(TokenLike(_token).transferFrom(from, to, amount));

        assertEq(TokenLike(_token).totalSupply(), prevSupply);
        uint256 app = from == address(this) || approval == type(uint256).max ? approval : approval - amount;
        assertEq(TokenLike(_token).allowance(from, address(this)), app);
        if (from == to) {
            assertEq(TokenLike(_token).balanceOf(from), prevFromBalance);
        } else  {
            assertEq(TokenLike(_token).balanceOf(from), prevFromBalance - amount);
            assertEq(TokenLike(_token).balanceOf(to), prevToBalance + amount);
        }
    }

    // ************************************************************************************************************
    // PERMIT
    // ************************************************************************************************************

    function fuzzCheckPermit(
        address _token,
        string memory _contractName,
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline,
        uint256 nonce
    ) internal {
        fuzzCheckPermitEOA(_token, privKey, to, amount, deadline);
        fuzzCheckPermitBadNonce(_token, _contractName, privKey, to, amount, deadline, nonce);
        fuzzCheckPermitBadDeadline(_token, _contractName, privKey, to, amount, deadline);
        fuzzCheckPermitPastDeadline(_token, _contractName, privKey, to, amount, deadline);
        fuzzCheckPermitReplay(_token, _contractName, privKey, to, amount, deadline);
    }

    function fuzzCheckPermitEOA(
        address _token,
        uint248 privKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public {
        uint256 privateKey = privKey;
        if (deadline < block.timestamp) deadline = block.timestamp;
        if (privateKey == 0) privateKey = 1;

        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(_token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, to, amount, 0, deadline))
                )
            )
        );

        vm.expectEmit(true, true, true, true);
        emit Approval(owner, to, amount);
        TokenLike(_token).permit(owner, to, amount, deadline, v, r, s);

        assertEq(TokenLike(_token).allowance(owner, to), amount);
        assertEq(TokenLike(_token).nonces(owner), 1);
    }

    function fuzzCheckPermitBadNonce(
        address _token, 
        string memory _contractName,
        uint128 privateKey,
        address to,
        uint256 amount,
        uint256 deadline,
        uint256 nonce
    ) public {
        if (deadline < block.timestamp) deadline = block.timestamp;
        if (privateKey == 0) privateKey = 1;
        address owner = vm.addr(privateKey);
        if (nonce == TokenLike(_token).nonces(owner)) nonce++;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(_token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, to, amount, nonce, deadline))
                )
            )
        );

        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-permit"));
        TokenLike(_token).permit(owner, to, amount, deadline, v, r, s);
    }

    function fuzzCheckPermitBadDeadline(
        address _token,
        string memory _contractName,
        uint128 privateKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public {
        if (deadline == type(uint256).max) deadline -= 1;
        if (deadline < block.timestamp) deadline = block.timestamp;
        if (privateKey == 0) privateKey = 1;

        address owner = vm.addr(privateKey);
        uint256 nonce = TokenLike(_token).nonces(owner);
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(_token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, to, amount, nonce, deadline))
                )
            )
        );

        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-permit"));
        TokenLike(_token).permit(owner, to, amount, deadline + 1, v, r, s);
    }

    function fuzzCheckPermitPastDeadline(
        address _token,
        string memory _contractName,
        uint128 privateKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public {
        if (deadline == type(uint256).max) deadline -= 1;

        // private key cannot be 0 for secp256k1 pubkey generation
        if (privateKey == 0) privateKey = 1;

        address owner = vm.addr(privateKey);
        uint256 nonce = TokenLike(_token).nonces(owner);

        bytes32 domain_separator = TokenLike(_token).DOMAIN_SEPARATOR();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    domain_separator,
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, to, amount, nonce, deadline))
                )
            )
        );

        vm.warp(deadline + 1);

        vm.expectRevert(abi.encodePacked(_contractName, "/permit-expired"));
        TokenLike(_token).permit(owner, to, amount, deadline, v, r, s);
    }

    function fuzzCheckPermitReplay(
        address _token,
        string memory _contractName,
        uint128 privateKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) public {
        if (deadline < block.timestamp) deadline = block.timestamp;
        if (privateKey == 0) privateKey = 1;

        address owner = vm.addr(privateKey);
        uint256 nonce = TokenLike(_token).nonces(owner);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(_token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, to, amount, nonce, deadline))
                )
            )
        );

        TokenLike(_token).permit(owner, to, amount, deadline, v, r, s);
        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-permit"));
        TokenLike(_token).permit(owner, to, amount, deadline, v, r, s);
    }
}