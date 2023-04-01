pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

///@title Frens Merkle Prover
///@author 0xWildhare and Frens Team
///@dev checks merkle proof validity for address

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./interfaces/IFrensMerkleProver.sol";

contract FrensMerkleProver is IFrensMerkleProver{

    function verify(bytes32[] calldata merkleProof, bytes32 merkleRoot, address sender) public pure {
            require(MerkleProof.verify(merkleProof, merkleRoot, keccak256(abi.encodePacked(sender))), "invalid merkle proof");
    }
}