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
  //set address
  function setContractAddress(address _contractAddress, string memory _contractName) public onlyGuardian{
    setAddress(keccak256(abi.encodePacked("contract.address", _contractName)), _contractAddress);
  }
  //set name
  function setContractName(address _contractAddress, string memory _contractName) public onlyGuardian{
    setString(keccak256(abi.encodePacked("contract.name", _contractAddress)), _contractName);
  }

  function deleteContractName(address _contractAddress) public onlyGuardian {
    deleteString(keccak256(abi.encodePacked("contract.name", _contractAddress)));
  }

  function deleteContractAddress(string memory _contractName) public onlyGuardian {
    deleteAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
  }

  ///add deletes

}
