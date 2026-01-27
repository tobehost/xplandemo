// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol";
import "../contracts/XplanDemoToken.sol";

contract XplanDemoTokenTest {
    XplanDemoToken token;

    constructor() {
        token = new XplanDemoToken();
    }
    function testTokenInitialValues() public {
        Assert.equal(token.name(), "XplanDemoToken", "name mismatch");
        Assert.equal(token.symbol(), "XPD", "token symbol mismatch");
        Assert.equal(token.decimals(), 9, "token decimals mismatch");
        Assert.equal(token.totalSupply(), 10000 * 10**token.decimals(), "token total supply mismatch");
    }
}