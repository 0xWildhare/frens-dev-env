pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT


interface IFrensOracle {

function checkValidatorState(address pool) external;

   function setExiting(bytes memory pubKey, bool isExiting) external;
    
}