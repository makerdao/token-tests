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

    function test_bulkCheckMintBurn() public {
        bulkCheckMintBurn(_token_, _contractName_);
    }
    function test_bulkCheckERC20() public {
        bulkCheckERC20(_token_, _contractName_, _tokenName_, _symbol_, "1", 18);
    }
    function test_bulkCheckPermit() public {
        bulkCheckPermit(_token_, _contractName_);
    }
}
