// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import { DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script{

    address public constant CLAIMING_ADDRESS = 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D;
    uint256 public constant CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 proofOne = 0x16440518c56abeb829b31fe7f6f64b0ffc6e3b5ab8cf006e3b0bb439388da388;
    bytes32 proofTwo = 0x1f054b8bec370a6ac2add00abcbec49f390544adb8f04c668e12bf35dec2ba18;
    bytes32[] public proof = [proofOne, proofTwo];
   

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(CLAIMING_ADDRESS, MerkleAirdrop(airdrop).getMessage(CLAIMING_ADDRESS, CLAIMING_AMOUNT));
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentDeployed);
    }
}