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

/** 
 * @title Token Fuzz Tests
 * @dev Contains fuzz tests for token contracts similar to test/SampleToken.sol
 */
contract TokenFuzzTests is TokenTests {

    // ************************************************************************************************************
    // Mint/Burn
    // ************************************************************************************************************

    function fuzzCheckMintBurn(address _token, string memory _contractName) public {

    }


    // ************************************************************************************************************
    // ERC20
    // ************************************************************************************************************

    function fuzzCheckERC20(address _token, string memory _contractName, string memory _tokenName, string memory _symbol, string memory _version, uint8 _decimals) public {
        
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