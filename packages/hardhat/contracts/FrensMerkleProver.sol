pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./interfaces/IFrensMerkleProver.sol";

contract FrensMerkleProver is IFrensMerkleProver{

    function verify(bytes32[] calldata merkleProof, bytes32 merkleRoot, address sender) public pure {
            require(MerkleProof.verify(merkleProof, merkleRoot, _toBytes32(sender)), "invalid merkle proof");
    }

    function _toBytes32(address addr) pure internal returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}