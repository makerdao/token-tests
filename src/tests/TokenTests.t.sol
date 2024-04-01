// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../TokenFuzzTests.sol";
import "./SampleToken.sol";

contract TokenTestsTests is TokenTests, TokenFuzzTests 
 {
    function setUp() public {
        _token_ = address(new SampleToken());
        _tokenName_ = "Sample Token";
        _contractName_ = "SampleToken";
        _symbol_ = "TKN";

        TokenLike(_token_).deny(address(this)); // this is not necessary and only done here to check that tests are not expecting the test contract to be auth
    }

    function testBulkMintBurn() public {
        checkBulkMintBurn(_token_, _contractName_);
    }
    function testBulkERC20() public {
        checkBulkERC20(_token_, _contractName_, _tokenName_, _symbol_, "1", 18);
    }
    function testBulkPermit() public {
        checkBulkPermit(_token_, _contractName_);
    }

    function testBulkMintBurnFuzz(        
        address who,
        uint256 allowance,
        uint256 mintAmount,
        uint256 burnAmount
    ) public {
        checkBulkMintBurnFuzz(_token_, _contractName_, who, allowance, mintAmount, burnAmount);
    }
    function testBulkERC20Fuzz(
        address from,
        address to,
        uint256 amount1,
        uint256 amount2
    ) public {
        checkBulkERC20Fuzz(_token_, _contractName_, from, to, amount1, amount2);
    }
    function testBulkPermitFuzz(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline,
        uint256 nonce
    ) public {
        checkBulkPermitFuzz(_token_, _contractName_, privKey, to, amount, deadline, nonce);
    }
}
