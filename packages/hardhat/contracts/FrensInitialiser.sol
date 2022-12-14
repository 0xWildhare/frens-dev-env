// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./FrensBase.sol";

contract FrensInitialiser is FrensBase {

  constructor(IFrensStorage _frensStorage) FrensBase(_frensStorage) {
    //nothing?
  }
  //set boolean
  function setContractExists(address _contractAddress, bool _exists) public onlyGuardian{
    setBool(keccak256(abi.encodePacked("contract.exists", _contractAddress)), _exists);
  }
  //set name and address
  function setContract(address _contractAddress, string memory _contractName) public onlyGuardian{
    setAddress(keccak256(abi.encodePacked("contract.address", _contractName)), _contractAddress);
    setString(keccak256(abi.encodePacked("contract.name", _contractAddress)), _contractName);
    setBool(keccak256(abi.encodePacked("contract.exists", _contractAddress)), true);
  }

  function deleteContract(address _contractAddress, string memory _contractName) public onlyGuardian {
    deleteAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
    deleteString(keccak256(abi.encodePacked("contract.name", _contractAddress)));
    setBool(keccak256(abi.encodePacked("contract.exists", _contractAddress)), false);
  }

  function setExternalContract(address _contractAddress, string memory _contractName) public onlyGuardian {
    setAddress(keccak256(abi.encodePacked("external.contract.address", _contractName)), _contractAddress);
    setString(keccak256(abi.encodePacked("external.contract.name", _contractAddress)), _contractName);
  }

  ///add deletes

}
