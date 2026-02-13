// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";
import {Merkle} from "murky/src/Merkle.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";

contract MakeMerkle is Script, ScriptHelper {
    using stdJson for string;

    Merkle private m = new Merkle();

    string private inputPath = "/script/target/input.json";
    string private outputPath = "/script/target/output.json";

    string private elements = vm.readFile(string.concat(vm.projectRoot(), inputPath));
    string[] private types = elements.readStringArray(".types");
    uint256 private count = elements.readUint(".count");

    bytes32[] private leafs = new bytes32[](count);
    string[] private inputs = new string[](count);
    string[] private outputs = new string[](count);

    string private output;

    function getValuesByIndex(uint256 i, uint256 j) internal pure returns (string memory) {
        return string.concat(".values.", vm.toString(i), ".", vm.toString(j));
    }

    function generateJsonEntries(
        string memory _inputs,
        string memory _proof,
        string memory _root,
        string memory _leaf
    ) internal pure returns (string memory) {
        string memory result = string.concat(
            "{",
            "\"inputs\":", _inputs, ",",
            "\"proof\":", _proof, ",",
            "\"root\":\"", _root, "\",",
            "\"leaf\":\"", _leaf, "\"",
            "}"
        );
        return result;
    }

    function run() public {
        console.log("Generating Merkle Proof for %s", inputPath);

        // ===== FIXED SECTION =====
        for (uint256 i = 0; i < count; ++i) {
            // Read address and amount directly
            address userAddress = elements.readAddress(getValuesByIndex(i, 0));
            uint256 amount = vm.parseUint(elements.readString(getValuesByIndex(i, 1)));
            
            // Create leaf EXACTLY as contract does
            // Must match: keccak256(bytes.concat(keccak256(abi.encodePacked(address, amount))))
            leafs[i] = keccak256(
                bytes.concat(
                    keccak256(abi.encodePacked(userAddress, amount))
                )
            );
            
            // Store for JSON output
            string[] memory input = new string[](2);
            input[0] = vm.toString(userAddress);
            input[1] = vm.toString(amount);
            inputs[i] = stringArrayToString(input);
        }
        // ===== END FIXED SECTION =====

        // Generate proofs (this stays the same)
        for (uint256 i = 0; i < count; ++i) {
            string memory proof = bytes32ArrayToString(m.getProof(leafs, i));
            string memory root = vm.toString(m.getRoot(leafs));
            string memory leaf = vm.toString(leafs[i]);
            string memory input = inputs[i];

            outputs[i] = generateJsonEntries(input, proof, root, leaf);
        }

        output = stringArrayToArrayString(outputs);
        vm.writeFile(string.concat(vm.projectRoot(), outputPath), output);

        console.log("DONE: The output is found at %s", outputPath);
    }
}