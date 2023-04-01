pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

///@title Frens Staking Pool Factory
///@author 0xWildhare and Frens team
///@dev allows user to create a new staking pool

//import "hardhat/console.sol";
import "./StakingPool.sol";
import "./interfaces/IStakingPoolFactory.sol";
import "./interfaces/IFrensPoolShare.sol";
import "./interfaces/IFrensArt.sol";
import "./interfaces/IFrensStorage.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

contract StakingPoolFactory is IStakingPoolFactory{
    event Create(
        address indexed contractAddress,
        address creator,
        address owner
    );

    IFrensPoolShare frensPoolShare;
    IFrensStorage frensStorage;

    constructor(IFrensStorage frensStorage_) {
       frensStorage = frensStorage_;
       frensPoolShare = IFrensPoolShare(frensStorage.getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolShare"))));
    }

    ///@dev creates a new pool
    ///@return address of new pool
    function create(
        address _owner,
        bool _validatorLocked,
        bool _frensLocked, 
        uint _poolMin,
        uint _poolMax,
        bytes32 _merkleRoot
    )
        public
        returns (
            address
        )
    {
        StakingPool stakingPool = new StakingPool(
            _owner,
            _validatorLocked,
            _frensLocked,
            _poolMin,
            _poolMax,
            _merkleRoot,
            frensStorage
        );
        // allow this stakingpool to mint shares in our NFT contract
        IAccessControl(address(frensPoolShare)).grantRole(keccak256("MINTER_ROLE"),address(stakingPool));
        emit Create(address(stakingPool), msg.sender, address(this));
        return (address(stakingPool));
    }
}
