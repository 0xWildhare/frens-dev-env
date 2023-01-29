// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

//import "hardhat/console.sol";
import "./StakingPool.sol";
import "./FrensBase.sol";
import "./interfaces/IStakingPoolFactory.sol";

contract StakingPoolFactory is IStakingPoolFactory, FrensBase {

  event Create(
    address indexed contractAddress,
    address creator,
    address owner
  );

  constructor(IFrensStorage _frensStorage) FrensBase(_frensStorage){
    version = 0;
  }

  function create(
    address owner_, 
    bool validatorLocked// ,THESE AR NOT MAINNET READY YET
    //bool frensLocked,
    //uint poolMin,
    //uint poolMax
    ) public override returns(address) {
    StakingPool stakingPool = new StakingPool(owner_, validatorLocked, frensStorage);
    //Should these be moved to a setter contract so that the pool/factory can be updated by FrensManager
    IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
    bool success = frensPoolSetter.create(address(stakingPool), validatorLocked);//, frensLocked, poolMin, poolMax);
    assert(success);
    emit Create(address(stakingPool), msg.sender, owner_);
    return(address(stakingPool));
  }


}
