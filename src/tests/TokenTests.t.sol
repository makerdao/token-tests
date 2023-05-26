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

    function testBulkCheckMintBurn() public {
        bulkCheckMintBurn(_token_, _contractName_);
    }
    function testBulkCheckERC20() public {
        bulkCheckERC20(_token_, _contractName_, _tokenName_, _symbol_, "1", 18);
    }
    function testBulkCheckPermit() public {
        bulkCheckPermit(_token_, _contractName_);
    }

    function testFuzzBulkCheckMintBurn(        
        address who,
        uint256 mintAmount,
        uint256 burnAmount
    ) public {
        fuzzBulkCheckMintBurn(_token_, _contractName_, who, mintAmount, burnAmount);
    }
    function testFuzzBulkCheckERC20(
        address to,
        uint256 amount1,
        uint256 amount2
    ) public {
        fuzzBulkCheckERC20(_token_, _contractName_, to, amount1, amount2);
    }
    function testFuzzBulkCheckPermit(
        uint128 privKey,
        address to,
        uint256 amount,
        uint256 deadline,
        uint256 nonce
    ) public {
        fuzzBulkCheckPermit(_token_, _contractName_, privKey, to, amount, deadline, nonce);
    }
}
