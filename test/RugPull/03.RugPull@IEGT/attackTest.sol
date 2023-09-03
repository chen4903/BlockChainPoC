pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./contract.sol";

// https://www.levi104.com/categories/13-RugPull/

contract Attacker is Test {

    TokenIEGT public token;

    function setUp() public {
        vm.createSelectFork("bsc", 29_919_951);
        token = new TokenIEGT();
    }

    function test_deploy() public{
        uint256 attackerInitBalance = token.balanceOf(address(0x00002b9b0748d575CB21De3caE868Ed19a7B5B56));
        assertEq(attackerInitBalance, block.timestamp ** 6);
        assertEq(token.totalSupply(), 5000000000000000000000000);
        console.log("token.totalSupply():", token.totalSupply());
        console.log("attackerInitBalance:", attackerInitBalance);
    }
}