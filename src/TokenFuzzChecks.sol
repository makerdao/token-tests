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

    function checkBulkMintBurnFuzz(
        address _token,
        string memory _contractName,
        address who,
        uint256 allowance,
        uint256 mintAmount,
        uint256 burnAmount
    ) internal {
        checkMintFuzz(_token, _contractName, who, mintAmount);
        checkBurnFuzz(_token, who, mintAmount, burnAmount);
        checkBurnInsufficientBalanceFuzz(_token, _contractName, who, mintAmount, burnAmount);
        checkBurnInsufficientAllowanceFuzz(_token, _contractName, who, allowance, mintAmount, burnAmount);
        checkTokenModifiersFuzz(_token, _contractName, who);
    }

    function checkMintFuzz(
        address _token,
        string memory _contractName,
        address to,
        uint256 mintAmount
    ) internal {
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

    function checkBurnFuzz(
        address _token,
        address from,
        uint256 mintAmount,
        uint256 burnAmount
    ) internal {
        uint256 prevSupply = TokenLike(_token).totalSupply();
        uint256 prevFromBalance = TokenLike(_token).balanceOf(from);
        mintAmount = bound(mintAmount, 0, type(uint256).max - prevSupply);
        burnAmount = bound(burnAmount, 0, prevFromBalance + mintAmount);
        deal(_token, from, prevFromBalance + mintAmount, true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(from, address(0), burnAmount);
        vm.prank(from); TokenLike(_token).burn(from, burnAmount);

        assertEq(TokenLike(_token).totalSupply(), prevSupply + mintAmount - burnAmount);
        assertEq(TokenLike(_token).balanceOf(from), prevFromBalance + mintAmount - burnAmount);
    }

    function checkBurnInsufficientBalanceFuzz(
        address _token,
        string memory _contractName,
        address from,
        uint256 mintAmount,
        uint256 burnAmount
    ) internal {
        uint256 prevSupply = TokenLike(_token).totalSupply();
        if (prevSupply == type(uint256).max) return;
        uint256 prevFromBalance = TokenLike(_token).balanceOf(from);

        mintAmount = bound(mintAmount, 0, type(uint256).max - prevSupply - 1);
        burnAmount = bound(burnAmount, prevFromBalance + mintAmount + 1, type(uint256).max);
        deal(_token, from, prevFromBalance + mintAmount, true);

        vm.expectRevert(abi.encodePacked(_contractName, "/insufficient-balance"));
        TokenLike(_token).burn(from, burnAmount);
    }

    function checkBurnInsufficientAllowanceFuzz(
        address _token,
        string memory _contractName,
        address from,
        uint256 allowance,
        uint256 mintAmount,
        uint256 burnAmount
    ) internal {
        vm.assume(from != address(this));
        uint256 prevSupply = TokenLike(_token).totalSupply();
        if (prevSupply == type(uint256).max) return;
        uint256 prevFromBalance = TokenLike(_token).balanceOf(from);

        mintAmount = bound(mintAmount, 1, type(uint256).max - prevSupply);
        burnAmount = bound(burnAmount, 1, prevFromBalance + mintAmount);
        allowance = bound(allowance, 0, burnAmount - 1);
        deal(_token, from, prevFromBalance + mintAmount, true);
        vm.prank(from); TokenLike(_token).approve(address(this), allowance);

        vm.expectRevert(abi.encodePacked(_contractName, "/insufficient-allowance"));
        TokenLike(_token).burn(from, burnAmount);
    }

    function checkTokenModifiersFuzz(
        address _token,
        string memory _contractName,
        address sender
    ) internal {
        vm.assume(TokenLike(_token).wards(sender) == 0);
        bytes4[] memory authedMethods = new bytes4[](1);
        authedMethods[0] = TokenLike(_token).mint.selector;

        vm.startPrank(sender);
        checkModifier(_token, string(abi.encodePacked(_contractName, "/not-authorized")), authedMethods);
        vm.stopPrank();
    }

    // ************************************************************************************************************
    // ERC20
    // ************************************************************************************************************

    function checkBulkERC20Fuzz(
        address _token,
        string memory _contractName,
        address from,
        address to,
        uint256 amount1,
        uint256 amount2
    ) internal {
        checkApproveFuzz(_token, to, amount1);
        checkTransferFuzz(_token, to, amount1);
        checkTransferFromFuzz(_token, from, to, amount1, amount2);
        checkTransferInsufficientBalanceFuzz(_token, _contractName, to, amount1, amount2);
        checkTransferFromInsufficientBalanceFuzz(_token, _contractName, from, to, amount1, amount2);
        checkTransferFromInsufficientAllowanceFuzz(_token, _contractName, from, to, amount1, amount2);
    }

    function checkApproveFuzz(
        address _token,
        address to,
        uint256 amount
    ) internal {
        vm.expectEmit(true, true, true, true);
        emit Approval(address(this), to, amount);
        assertTrue(TokenLike(_token).approve(to, amount));

        assertEq(TokenLike(_token).allowance(address(this), to), amount);
    }

    function checkTransferFuzz(
        address _token,
        address to,
        uint256 amount
    ) internal {
        vm.assume(to != address(0) && to != _token);
        uint256 prevSupply = TokenLike(_token).totalSupply();
        uint256 prevToBalance = TokenLike(_token).balanceOf(to);
        amount = bound(amount, 0, type(uint256).max - prevSupply);
        uint256 prevSenderBalance = TokenLike(_token).balanceOf(address(this));
        deal(_token, address(this), prevSenderBalance + amount, true);
        prevSenderBalance += amount;
        prevSupply += amount;

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

    function checkTransferFromFuzz(
        address _token,
        address from,
        address to,
        uint256 approval,
        uint256 amount
    ) internal {
        vm.assume(to != address(0) && to != _token);
        uint256 prevSupply = TokenLike(_token).totalSupply();
        uint256 prevToBalance = TokenLike(_token).balanceOf(to);
        approval = bound(approval, 0, type(uint256).max - prevSupply);
        amount = bound(amount, 0, approval);
        uint256 prevFromBalance = TokenLike(_token).balanceOf(from);
        deal(_token, from, prevFromBalance + amount, true);
        prevFromBalance += amount;
        prevSupply += amount;
        vm.prank(from); TokenLike(_token).approve(address(this), approval);

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

    function checkTransferInsufficientBalanceFuzz(
        address _token,
        string memory _contractName,
        address to,
        uint256 mintAmount,
        uint256 sendAmount
    ) internal {
        vm.assume(to != address(0) && to != address(_token));
        uint256 prevSupply = TokenLike(_token).totalSupply();
        if (prevSupply == type(uint256).max) return;
        uint256 prevBalance = TokenLike(_token).balanceOf(address(this));
        mintAmount = bound(mintAmount, 0, type(uint256).max - prevSupply - 1);
        sendAmount = bound(sendAmount, mintAmount + prevBalance + 1, type(uint256).max);
        deal(_token, address(this), prevBalance + mintAmount, true);

        vm.expectRevert(abi.encodePacked(_contractName, "/insufficient-balance"));
        TokenLike(_token).transfer(to, sendAmount);
    }

    function checkTransferFromInsufficientBalanceFuzz(
        address _token,
        string memory _contractName,
        address from,
        address to,
        uint256 mintAmount,
        uint256 sendAmount
    ) internal {
        vm.assume(to != address(0) && to != address(_token));
        uint256 prevSupply = TokenLike(_token).totalSupply();
        if (prevSupply == type(uint256).max) return;
        uint256 prevFromBalance = TokenLike(_token).balanceOf(from);
        mintAmount = bound(mintAmount, 0, type(uint256).max - prevSupply - 1);
        sendAmount = bound(sendAmount, prevFromBalance + mintAmount + 1, type(uint256).max);
        deal(_token, from, prevFromBalance + mintAmount, true);
        vm.prank(from); TokenLike(_token).approve(address(this), sendAmount);

        vm.expectRevert(abi.encodePacked(_contractName, "/insufficient-balance"));
        TokenLike(_token).transferFrom(from, to, sendAmount);
    }

    function checkTransferFromInsufficientAllowanceFuzz(
        address _token,
        string memory _contractName,
        address from,
        address to,
        uint256 allowance,
        uint256 amount
    ) internal {
        vm.assume(to != address(0) && to != address(_token) && from != address(this));
        uint256 prevSupply = TokenLike(_token).totalSupply();
        if (prevSupply == type(uint256).max) return;

        amount = bound(amount, 1, type(uint256).max - prevSupply);
        allowance = bound(allowance, 0, amount - 1);
        deal(_token, from, TokenLike(_token).balanceOf(from) + amount, true);
        vm.prank(from); TokenLike(_token).approve(address(this), allowance);

        vm.expectRevert(abi.encodePacked(_contractName, "/insufficient-allowance"));
        TokenLike(_token).transferFrom(from, to, amount);
    }

    // ************************************************************************************************************
    // PERMIT
    // ************************************************************************************************************

    function checkBulkPermitFuzz(
        address _token,
        string memory _contractName,
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline,
        uint256 nonce
    ) internal {
        checkPermitEOAFuzz(_token, privKey, to, amount, deadline);
        checkPermitBadNonceFuzz(_token, _contractName, privKey, to, amount, deadline, nonce);
        checkPermitBadDeadlineFuzz(_token, _contractName, privKey, to, amount, deadline);
        checkPermitPastDeadlineFuzz(_token, _contractName, privKey, to, amount, deadline);
        checkPermitReplayFuzz(_token, _contractName, privKey, to, amount, deadline);
    }

    function checkPermitEOAFuzz(
        address _token,
        uint128 privateKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) internal {
        deadline = bound(deadline, block.timestamp, type(uint256).max);
        vm.assume(privateKey > 0);

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

    function checkPermitBadNonceFuzz(
        address _token, 
        string memory _contractName,
        uint128 privateKey,
        address to,
        uint256 amount,
        uint256 deadline,
        uint256 nonce
    ) internal {
        deadline = bound(deadline, block.timestamp, type(uint256).max);
        vm.assume(privateKey > 0);
        address owner = vm.addr(privateKey);
        vm.assume(nonce != TokenLike(_token).nonces(owner));

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

    function checkPermitBadDeadlineFuzz(
        address _token,
        string memory _contractName,
        uint128 privateKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) internal {
        deadline = bound(deadline, block.timestamp, type(uint256).max - 1);
        vm.assume(privateKey > 0);

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

    function checkPermitPastDeadlineFuzz(
        address _token,
        string memory _contractName,
        uint128 privateKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) internal {
        deadline = bound(deadline, 0, block.timestamp - 1);

        // private key cannot be 0 for secp256k1 pubkey generation
        vm.assume(privateKey > 0);

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

        vm.expectRevert(abi.encodePacked(_contractName, "/permit-expired"));
        TokenLike(_token).permit(owner, to, amount, deadline, v, r, s);
    }

    function checkPermitReplayFuzz(
        address _token,
        string memory _contractName,
        uint128 privateKey,
        address to,
        uint256 amount,
        uint256 deadline
    ) internal {
        deadline = bound(deadline, block.timestamp, type(uint256).max);
        vm.assume(privateKey > 0);

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
