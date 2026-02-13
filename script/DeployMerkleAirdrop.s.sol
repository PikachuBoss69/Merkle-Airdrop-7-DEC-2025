//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script{
    bytes32 private s_merkleRoot = 0x900b34c437080f723e44527ecdb5c37ffab0679b5f240eb0d64032bb9da0e207;
    uint256 private s_amountToTransfer = 4 * 25 ether;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken){
        vm.startBroadcast();
        BagelToken token = new BagelToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(token)));
        token.mint(token.owner(), s_amountToTransfer);
        token.transfer(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (airdrop, token);
    }

    function run() external returns (MerkleAirdrop, BagelToken){
        return deployMerkleAirdrop();
    }



}