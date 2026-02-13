//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";



contract MerkleAirdropTest is Test {
    MerkleAirdrop public airdrop;
    BagelToken public token;

    uint256 AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 5;
    bytes32 public ROOT = 0x900b34c437080f723e44527ecdb5c37ffab0679b5f240eb0d64032bb9da0e207;
    bytes32 proofOne = 0x16440518c56abeb829b31fe7f6f64b0ffc6e3b5ab8cf006e3b0bb439388da388;
    bytes32 proofTwo = 0x1f054b8bec370a6ac2add00abcbec49f390544adb8f04c668e12bf35dec2ba18;
    bytes32[] public PROOF = [proofOne, proofTwo];
    address user;
    uint256 userPrivKey;

    function setUp() public {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
            (user, userPrivKey) = makeAddrAndKey("user");

    }

    function testUserCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        console.log("Starting balance:", startingBalance);
        vm.prank(user);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF);
        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance:", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }

    function testCantClaimMoreThanOnce() public {
        vm.prank(user);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__AlreadyClaimed.selector);
        vm.prank(user);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF);
    }
    function testGetMerkleRoot() public {
        bytes32 merkleRoot = airdrop.getMerkleRoot();
        assertEq(merkleRoot, ROOT);
    }
    
} 