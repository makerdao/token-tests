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

import "dss-test/DssTest.sol";

interface TokenLike {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function version() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function nonces(address) external view returns (uint256);
    function wards(address) external view returns (uint256);
    function deny(address) external;
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function mint(address, uint256) external;
    function burn(address, uint256) external;
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
 * @title Token Checks
 * @dev Contains checks for token contracts similar to test/SampleToken.sol
 */
contract TokenChecks is DssTest {

    using GodMode for *;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    // ************************************************************************************************************
    // Mint/Burn
    // ************************************************************************************************************

    function checkBulkMintBurn(address _token, string memory _contractName) internal {
        checkTokenAuth(_token, _contractName);
        checkTokenModifiers(_token, _contractName);
        checkMint(_token);
        checkBurn(_token);
        checkBurnDifferentFrom(_token);
        checkMintBadAddress(_token, _contractName);
        checkBurnInsufficientBalance(_token, _contractName);
        checkBurnInsufficientAllowance(_token, _contractName);
    }

    function checkTokenAuth(address _token, string memory _contractName) internal {
        checkAuth(_token, _contractName);
    }

    function checkTokenModifiers(address _token, string memory _contractName) internal {
        bytes4[] memory authedMethods = new bytes4[](1);
        authedMethods[0] = TokenLike(_token).mint.selector;

        vm.startPrank(address(0xBEEF));
        checkModifier(_token, string(abi.encodePacked(_contractName, "/not-authorized")), authedMethods);
        vm.stopPrank();
    }

    function checkMint(address _token) internal {
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), address(0xBEEF), 1e18);
        uint256 prevSupply = TokenLike(_token).totalSupply();
        uint256 prevRecipientBalance = TokenLike(_token).balanceOf(address(0xBEEF));
        uint256 prevWard = TokenLike(_token).wards(address(this));
        _token.setWard(address(this), 1);

        TokenLike(_token).mint(address(0xBEEF), 1e18);
        
        _token.setWard(address(this), prevWard);
        assertEq(TokenLike(_token).totalSupply(), prevSupply + 1e18);
        assertEq(TokenLike(_token).balanceOf(address(0xBEEF)), prevRecipientBalance + 1e18);
    }

    function checkBurn(address _token) internal {
        deal(_token, address(0xBEEF), TokenLike(_token).balanceOf(address(0xBEEF)) + 1e18, true);
        uint256 prevSupply = TokenLike(_token).totalSupply();
        uint256 prevTargetBalance = TokenLike(_token).balanceOf(address(0xBEEF));

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0xBEEF), address(0), 0.9e18);
        vm.prank(address(0xBEEF)); TokenLike(_token).burn(address(0xBEEF), 0.9e18);

        assertEq(TokenLike(_token).totalSupply(), prevSupply - 0.9e18);
        assertEq(TokenLike(_token).balanceOf(address(0xBEEF)), prevTargetBalance - 0.9e18);
    }

    function checkBurnDifferentFrom(address _token) internal {
        deal(_token, address(0xBEEF), TokenLike(_token).balanceOf(address(0xBEEF)) + 1e18, true);
        uint256 prevSupply = TokenLike(_token).totalSupply();
        uint256 prevTargetBalance = TokenLike(_token).balanceOf(address(0xBEEF));
        vm.prank(address(0xBEEF)); TokenLike(_token).approve(address(this), 0.4e18);
        assertEq(TokenLike(_token).allowance(address(0xBEEF), address(this)), 0.4e18);

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0xBEEF), address(0), 0.4e18);
        TokenLike(_token).burn(address(0xBEEF), 0.4e18);

        assertEq(TokenLike(_token).allowance(address(0xBEEF), address(this)), 0);
        assertEq(TokenLike(_token).totalSupply(), prevSupply - 0.4e18);
        assertEq(TokenLike(_token).balanceOf(address(0xBEEF)), prevTargetBalance - 0.4e18);

        vm.prank(address(0xBEEF)); TokenLike(_token).approve(address(this), type(uint256).max);
        assertEq(TokenLike(_token).allowance(address(0xBEEF), address(this)), type(uint256).max);

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0xBEEF), address(0), 0.4e18);
        TokenLike(_token).burn(address(0xBEEF), 0.4e18);

        assertEq(TokenLike(_token).allowance(address(0xBEEF), address(this)), type(uint256).max);
        assertEq(TokenLike(_token).totalSupply(), prevSupply - 0.4e18 - 0.4e18);
        assertEq(TokenLike(_token).balanceOf(address(0xBEEF)), prevTargetBalance - 0.4e18 - 0.4e18);
    }

    function checkMintBadAddress(address _token, string memory _contractName) internal {
        uint256 prevWard = TokenLike(_token).wards(address(this));
        _token.setWard(address(this), 1);

        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-address"));
        TokenLike(_token).mint(address(0), 1e18);
        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-address"));
        TokenLike(_token).mint(_token, 1e18);

        _token.setWard(address(this), prevWard);
    }

    function checkBurnInsufficientBalance(address _token, string memory _contractName) internal {
        uint256 prevSenderBalance = TokenLike(_token).balanceOf(address(this));
        deal(_token, address(this), TokenLike(_token).balanceOf(address(this)) + 0.9e18, true);

        vm.expectRevert(abi.encodePacked(_contractName, "/insufficient-balance"));
        TokenLike(_token).burn(address(this), prevSenderBalance + 1e18);
    }

    function checkBurnInsufficientAllowance(address _token, string memory _contractName) internal {
        deal(_token, address(0xBEEF), TokenLike(_token).balanceOf(address(0xBEEF)) + 1e18, true);

        vm.prank(address(0xBEEF)); TokenLike(_token).approve(address(this), 0.9e18);
        assertEq(TokenLike(_token).allowance(address(0xBEEF), address(this)), 0.9e18);

        vm.expectRevert(abi.encodePacked(_contractName, "/insufficient-allowance"));
        TokenLike(_token).burn(address(0xBEEF), 1e18);
    }

    // ************************************************************************************************************
    // ERC20
    // ************************************************************************************************************

    function checkBulkERC20(address _token, string memory _contractName, string memory _tokenName, string memory _symbol, string memory _version, uint8 _decimals) internal {
        checkMetadata(_token, _tokenName, _symbol, _version, _decimals);
        checkApprove(_token);
        checkTransfer(_token);
        checkTransferFrom(_token);
        checkInfiniteApproveTransferFrom(_token);
        checkTransferBadAddress(_token, _contractName);
        checkTransferFromBadAddress(_token, _contractName);
        checkTransferInsufficientBalance(_token, _contractName);
        checkTransferFromInsufficientAllowance(_token, _contractName);
        checkTransferFromInsufficientBalance(_token, _contractName);
    }

    function checkMetadata(address _token, string memory _tokenName, string memory _symbol, string memory _version, uint8 _decimals) internal view {
        assertEq(TokenLike(_token).version(), _version); // Note that this is not part of the ERC20 standard
        assertEq(TokenLike(_token).name(), _tokenName);
        assertEq(TokenLike(_token).symbol(), _symbol);
        assertEq(TokenLike(_token).decimals(), _decimals);
    }

    function checkApprove(address _token) internal {
        vm.expectEmit(true, true, true, true);
        emit Approval(address(this), address(0xBEEF), 1e18);

        assertTrue(TokenLike(_token).approve(address(0xBEEF), 1e18));

        assertEq(TokenLike(_token).allowance(address(this), address(0xBEEF)), 1e18);
    }

    function checkTransfer(address _token) internal {
        deal(_token, address(this), TokenLike(_token).balanceOf(address(this)) + 1e18, true);
        uint256 prevSupply = TokenLike(_token).totalSupply();
        uint256 prevRecipientBalance = TokenLike(_token).balanceOf(address(0xBEEF));
        uint256 prevSenderBalance = TokenLike(_token).balanceOf(address(this));

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(this), address(0xBEEF), 1e18);
        assertTrue(TokenLike(_token).transfer(address(0xBEEF), 1e18));

        assertEq(TokenLike(_token).totalSupply(), prevSupply);
        assertEq(TokenLike(_token).balanceOf(address(this)), prevSenderBalance - 1e18);
        assertEq(TokenLike(_token).balanceOf(address(0xBEEF)), prevRecipientBalance + 1e18);
    }

    function checkTransferBadAddress(address _token, string memory _contractName) internal {
        deal(_token, address(this), TokenLike(_token).balanceOf(address(this)) + 1e18, true);

        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-address"));
        TokenLike(_token).transfer(address(0), 1e18);
        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-address"));
        TokenLike(_token).transfer(_token, 1e18);
    }

    function checkTransferInsufficientBalance(address _token, string memory _contractName) internal {
        uint256 prevSenderBalance = TokenLike(_token).balanceOf(address(this));
        deal(_token, address(this), prevSenderBalance + 0.9e18, true);

        vm.expectRevert(abi.encodePacked(_contractName, "/insufficient-balance"));
        TokenLike(_token).transfer(address(0xBEEF), prevSenderBalance + 1e18);
    }

    function checkTransferFrom(address _token) internal {
        address from = address(0xABCD);
        deal(_token, from, TokenLike(_token).balanceOf(address(from)) + 1e18, true);
        vm.prank(from); TokenLike(_token).approve(address(this), 1e18);
        uint256 prevSupply = TokenLike(_token).totalSupply();
        uint256 prevRecipientBalance = TokenLike(_token).balanceOf(address(0xBEEF));
        uint256 prevFromBalance = TokenLike(_token).balanceOf(from);
        uint256 prevAllowance = TokenLike(_token).allowance(from, address(this));

        vm.expectEmit(true, true, true, true);
        emit Transfer(from, address(0xBEEF), 1e18);
        assertTrue(TokenLike(_token).transferFrom(from, address(0xBEEF), 1e18));

        assertEq(TokenLike(_token).totalSupply(), prevSupply);
        assertEq(TokenLike(_token).allowance(from, address(this)), prevAllowance - 1e18);
        assertEq(TokenLike(_token).balanceOf(from), prevFromBalance - 1e18);
        assertEq(TokenLike(_token).balanceOf(address(0xBEEF)), prevRecipientBalance + 1e18);
    }

    function checkInfiniteApproveTransferFrom(address _token) internal {
        address from = address(0xABCD);
        deal(_token, from, TokenLike(_token).balanceOf(address(from)) + 1e18, true);
        vm.expectEmit(true, true, true, true);
        emit Approval(from, address(this), type(uint256).max);
        vm.prank(from); TokenLike(_token).approve(address(this), type(uint256).max);
        uint256 prevSupply = TokenLike(_token).totalSupply();
        uint256 prevRecipientBalance = TokenLike(_token).balanceOf(address(0xBEEF));
        uint256 prevFromBalance = TokenLike(_token).balanceOf(from);

        vm.expectEmit(true, true, true, true);
        emit Transfer(from, address(0xBEEF), 1e18);
        assertTrue(TokenLike(_token).transferFrom(from, address(0xBEEF), 1e18));

        assertEq(TokenLike(_token).totalSupply(), prevSupply);
        assertEq(TokenLike(_token).allowance(from, address(this)), type(uint256).max);
        assertEq(TokenLike(_token).balanceOf(from), prevFromBalance - 1e18);
        assertEq(TokenLike(_token).balanceOf(address(0xBEEF)), prevRecipientBalance + 1e18);
    }

    function checkTransferFromBadAddress(address _token, string memory _contractName) internal {
        deal(_token, address(this), TokenLike(_token).balanceOf(address(this)) + 1e18, true);

        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-address"));
        TokenLike(_token).transferFrom(address(this), address(0), 1e18);
        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-address"));
        TokenLike(_token).transferFrom(address(this), address(TokenLike(_token)), 1e18);
    }

    function checkTransferFromInsufficientAllowance(address _token, string memory _contractName) internal {
        address from = address(0xABCD);
        deal(_token, from, TokenLike(_token).balanceOf(from) + 1e18, true);
        vm.prank(from); TokenLike(_token).approve(address(this), 0.9e18);

        vm.expectRevert(abi.encodePacked(_contractName, "/insufficient-allowance"));
        TokenLike(_token).transferFrom(from, address(0xBEEF), 1e18);
    }

    function checkTransferFromInsufficientBalance(address _token, string memory _contractName) internal {
        address from = address(0xABCD);
        uint256 prevFromBalance = TokenLike(_token).balanceOf(from);
        deal(_token, from, prevFromBalance + 0.9e18, true);
        vm.prank(from); TokenLike(_token).approve(address(this), 1e18);

        vm.expectRevert(abi.encodePacked(_contractName, "/insufficient-balance"));
        TokenLike(_token).transferFrom(from, address(0xBEEF), prevFromBalance + 1e18);
    }

    // ************************************************************************************************************
    // PERMIT
    // ************************************************************************************************************

    bytes32 constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    function checkBulkPermit(address _token, string memory _contractName) internal {
        checkPermitEOA(_token);
        checkPermitContract(_token);
        checkPermitContractInvalidSignature(_token, _contractName);
        checkPermitBadNonce(_token, _contractName);
        checkPermitBadDeadline(_token, _contractName);
        checkPermitPastDeadline(_token, _contractName);
        checkPermitOwnerZero(_token, _contractName);
        checkPermitReplay(_token, _contractName);
    }

    function checkPermitEOA(address _token) internal {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(_token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        vm.expectEmit(true, true, true, true);
        emit Approval(owner, address(0xCAFE), 1e18);
        TokenLike(_token).permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);

        assertEq(TokenLike(_token).allowance(owner, address(0xCAFE)), 1e18);
        assertEq(TokenLike(_token).nonces(owner), 1);
    }

    function checkPermitContract(address _token) internal {
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
                    TokenLike(_token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, mockMultisig, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(
            uint256(privateKey2),
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(_token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, mockMultisig, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        bytes memory signature = abi.encode(r, s, bytes32(uint256(v) << 248), r2, s2, bytes32(uint256(v2) << 248));
        vm.expectEmit(true, true, true, true);
        emit Approval(mockMultisig, address(0xCAFE), 1e18);
        TokenLike(_token).permit(mockMultisig, address(0xCAFE), 1e18, block.timestamp, signature);

        assertEq(TokenLike(_token).allowance(mockMultisig, address(0xCAFE)), 1e18);
        assertEq(TokenLike(_token).nonces(mockMultisig), 1);
    }

    function checkPermitContractInvalidSignature(address _token, string memory _contractName) internal {
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
                    TokenLike(_token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, mockMultisig, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(
            uint256(0xCEEE),
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(_token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, mockMultisig, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        bytes memory signature = abi.encode(r, s, bytes32(uint256(v) << 248), r2, s2, bytes32(uint256(v2) << 248));
        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-permit"));
        TokenLike(_token).permit(mockMultisig, address(0xCAFE), 1e18, block.timestamp, signature);
    }

    function checkPermitBadNonce(address _token, string memory _contractName) internal {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(_token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 12345, block.timestamp))
                )
            )
        );

        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-permit"));
        TokenLike(_token).permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
    }

    function checkPermitBadDeadline(address _token, string memory _contractName) internal {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(_token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-permit"));
        TokenLike(_token).permit(owner, address(0xCAFE), 1e18, block.timestamp + 1, v, r, s);
    }

    function checkPermitPastDeadline(address _token, string memory _contractName) internal {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);
        uint256 deadline = block.timestamp;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(_token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, deadline))
                )
            )
        );

        vm.warp(deadline + 1);

        vm.expectRevert(abi.encodePacked(_contractName, "/permit-expired"));
        TokenLike(_token).permit(owner, address(0xCAFE), 1e18, deadline, v, r, s);
    }

    function checkPermitOwnerZero(address _token, string memory _contractName) internal {
        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-owner"));
        TokenLike(_token).permit(address(0), address(0xCAFE), 1e18, block.timestamp, 28, bytes32(0), bytes32(0));
    }

    function checkPermitReplay(address _token, string memory _contractName) internal {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    TokenLike(_token).DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, TokenLike(_token).nonces(owner), block.timestamp))
                )
            )
        );

        TokenLike(_token).permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
        vm.expectRevert(abi.encodePacked(_contractName, "/invalid-permit"));
        TokenLike(_token).permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
    }
}
