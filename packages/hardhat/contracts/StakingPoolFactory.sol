// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./StakingPool.sol";
import "./FrensBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//should ownable be replaced with equivalent in storage/base?
contract StakingPoolFactory is Ownable, FrensBase {

//these items move to storage
  mapping(address => bool) existsStakingPool;
  address depositContractAddress;
  address ssvRegistryAddress;
  address frensPoolShareAddress;
//^^^^

  event Create(
    address indexed contractAddress,
    address creator,
    address owner,
    address depositContractAddress
  );

//these no longer need to be in the constructor (storage contract)
  constructor(address depContAddress_, address ssvRegistryAddress_, IFrensStorage _frensStorage) FrensBase(_frensStorage){
    depositContractAddress = depContAddress_;
    ssvRegistryAddress = ssvRegistryAddress_;
  }

  //this moves to baseContract - this no longer needs to be "ownable"
  function setFrensPoolShare(address frensPoolShareAddress_) public onlyOwner {
    frensPoolShareAddress = frensPoolShareAddress_;
  }

  function create(
    address owner_
  ) public returns(address) {
    //only the owner address needs to be sent to constructor for pool contract
    StakingPool stakingPool = new StakingPool(depositContractAddress, address(this), frensPoolShareAddress, owner_, frensStorage);
    setBool(keccak256(abi.encodePacked("pool.exists", address(stakingPool))), true);//do we need both pool.exists and contract.exists?
    setBool(keccak256(abi.encodePacked("contract.exists", address(stakingPool))), true);
    emit Create(address(stakingPool), msg.sender, owner_, depositContractAddress);
    return(address(stakingPool));
  }

}
