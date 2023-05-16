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

import "forge-std/Test.sol";

interface TokenLike {
    function allowance(address, address) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function nonces(address) external view returns (uint256);
    function permit(address, address, uint256, uint256, bytes memory) external;
    function permit(address, address, uint256, uint256, uint8, bytes32, bytes32) external;
}

interface SignerLike {
    function isValidSignature(
        bytes32,
        bytes memory
    ) external view returns (bytes4);
}

contract MockMultisig is SignerLike {
    address public signer1;
    address public signer2;

    constructor(address signer1_, address signer2_) {
        signer1 = signer1_;
        signer2 = signer2_;
    }

    function isValidSignature(bytes32 digest, bytes memory signature) external view returns (bytes4 sig) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
        if (signer1 == ecrecover(digest, v, r, s)) {
            assembly {
                r := mload(add(signature, 0x80))
                s := mload(add(signature, 0xA0))
                v := byte(0, mload(add(signature, 0xC0)))
            }
            if (signer2 == ecrecover(digest, v, r, s)) {
                sig = SignerLike.isValidSignature.selector;
            }
        }
    }
}

/** 
 * @title Token Tests
 * @dev Contains tests for token contracts similar to https://github.com/makerdao/xdomain-dss/blob/master/src/Dai.sol
 */
contract TokenTests is Test {

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    bytes32 constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    function checkPermit(address token) internal {
        checkPermitEOA(token);
        checkPermitContract(token);
        checkPermitContractInvalidSignature(token);
        checkPermitBadNonce(token);
        checkPermitBadDeadline(token);
        checkPermitPastDeadline(token);
        checkPermitOwnerZero(token);
        checkPermitReplay(token);
    }

    function checkPermitEOA(address token) internal {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        vm.expectEmit(true, true, true, true);
        emit Approval(owner, address(0xCAFE), 1e18);
        TokenLike(token).permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);

        assertEq(TokenLike(token).allowance(owner, address(0xCAFE)), 1e18);
        assertEq(TokenLike(token).nonces(owner), 1);
    }

    function checkPermitContract(address token) internal {
        uint256 privateKey1 = 0xBEEF;
        address signer1 = vm.addr(privateKey1);
        uint256 privateKey2 = 0xBEEE;
        address signer2 = vm.addr(privateKey2);

        address mockMultisig = address(new MockMultisig(signer1, signer2));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            uint256(privateKey1),
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, mockMultisig, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(
            uint256(privateKey2),
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, mockMultisig, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        bytes memory signature = abi.encode(r, s, bytes32(uint256(v) << 248), r2, s2, bytes32(uint256(v2) << 248));
        vm.expectEmit(true, true, true, true);
        emit Approval(mockMultisig, address(0xCAFE), 1e18);
        TokenLike(token).permit(mockMultisig, address(0xCAFE), 1e18, block.timestamp, signature);

        assertEq(TokenLike(token).allowance(mockMultisig, address(0xCAFE)), 1e18);
        assertEq(TokenLike(token).nonces(mockMultisig), 1);
    }

    function checkPermitContractInvalidSignature(address token) public {
        uint256 privateKey1 = 0xBEEF;
        address signer1 = vm.addr(privateKey1);
        uint256 privateKey2 = 0xBEEE;
        address signer2 = vm.addr(privateKey2);

        address mockMultisig = address(new MockMultisig(signer1, signer2));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            uint256(privateKey1),
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, mockMultisig, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(
            uint256(0xCEEE),
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, mockMultisig, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        bytes memory signature = abi.encode(r, s, bytes32(uint256(v) << 248), r2, s2, bytes32(uint256(v2) << 248));
        vm.expectRevert(); // TODO: check that revert reason matches ".+\/invalid-permit"
        TokenLike(token).permit(mockMultisig, address(0xCAFE), 1e18, block.timestamp, signature);
    }

    function checkPermitBadNonce(address token) public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 12345, block.timestamp))
                )
            )
        );

        vm.expectRevert();  // TODO: check that revert reason matches ".+\/invalid-permit"
        TokenLike(token).permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
    }

    function checkPermitBadDeadline(address token) public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        vm.expectRevert();  // TODO: check that revert reason matches ".+\/invalid-permit"
        TokenLike(token).permit(owner, address(0xCAFE), 1e18, block.timestamp + 1, v, r, s);
    }

    function checkPermitPastDeadline(address token) public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);
        uint256 deadline = block.timestamp;

        bytes32 domain_separator = TokenLike(token).DOMAIN_SEPARATOR();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    domain_separator,
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, deadline))
                )
            )
        );

        vm.warp(deadline + 1);

        vm.expectRevert();  // TODO: check that revert reason matches ".+\/permit-expired"
        TokenLike(token).permit(owner, address(0xCAFE), 1e18, deadline, v, r, s);
    }

    function checkPermitOwnerZero(address token) public {
        vm.expectRevert(); // TODO: check that revert reason matches ".+\/invalid-owner"
        TokenLike(token).permit(address(0), address(0xCAFE), 1e18, block.timestamp, 28, bytes32(0), bytes32(0));
    }

    function checkPermitReplay(address token) public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, TokenLike(token).nonces(owner), block.timestamp))
                )
            )
        );

        TokenLike(token).permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
        vm.expectRevert(); // TODO: check that revert reason matches ".+\/invalid-permit"
        TokenLike(token).permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
    }
}