// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {

    error __ClaimAirdropScript__InvalidSignatureLength();

    address public constant CLAIMING_ADDRESS =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 public constant CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 proofOne =
        0x3707681888b88e6c150b2b44927bab35484380cd259e49c1b40d88d2652ab63f;
    bytes32 proofTwo =
        0x1f054b8bec370a6ac2add00abcbec49f390544adb8f04c668e12bf35dec2ba18;
    bytes32[] public proof = [proofOne, proofTwo];
    uint256 private CLAIMING_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    function claimAirdrop(address airdrop) public {
         bytes32 messageHash = MerkleAirdrop(airdrop).getMessage(
        CLAIMING_ADDRESS,
        CLAIMING_AMOUNT
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(CLAIMING_PRIVATE_KEY, messageHash);
        vm.startBroadcast();
        MerkleAirdrop(airdrop).claim(
            CLAIMING_ADDRESS,
            CLAIMING_AMOUNT,
            proof,
            v,
            r,
            s
        );
        vm.stopBroadcast();
    }
    // function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s){
    //     if(sig.length != 65){
    //         revert __ClaimAirdropScript__InvalidSignatureLength();
    //     }
    //     assembly {
    //         r := mload(add(sig, 32))
    //         s := mload(add(sig, 64))
    //         v := byte(0, mload(add(sig, 96)))
    //     }
    // }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
            "MerkleAirdrop",
            block.chainid
        );
        claimAirdrop(mostRecentDeployed);
    }
}
