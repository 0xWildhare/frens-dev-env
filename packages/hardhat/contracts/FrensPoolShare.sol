// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

//import "hardhat/console.sol";
import "./interfaces/IStakingPool.sol";
import "./interfaces/ISSVRegistry.sol";
import "./interfaces/IStakingPoolFactory.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import 'base64-sol/base64.sol';


contract FrensPoolShare is ERC721Enumerable, Ownable {

  using Strings for uint256;

  uint private _tokenId;
  mapping(uint => address) poolById;

  IStakingPoolFactory factoryContract;
  ISSVRegistry ssvRegistry;

  constructor(address factoryAddress_, address ssvRegistryAddress_) ERC721("staking con amigos", "FRENS") {
    factoryContract = IStakingPoolFactory(factoryAddress_);
    ssvRegistry = ISSVRegistry(ssvRegistryAddress_);
  }

  modifier onlyStakingPools(address _stakingPoolAddress) {
    require(factoryContract.doesStakingPoolExist(_stakingPoolAddress), "must be a staking pool");
    _;
  }

  function incrementTokenId() public onlyStakingPools(msg.sender) returns(uint){
    _tokenId++;
    return _tokenId;
  }

  function mint(address userAddress, uint id, address _pool) public onlyStakingPools(msg.sender) {
    poolById[id] = _pool;
    _safeMint(userAddress,id);
  }

  function exists(uint _id) public view returns(bool){
    return _exists(_id);
  }

  function getPoolById(uint _id) public view returns(address){
    return poolById[_id];
  }

  //art stuff


  function tokenURI(uint256 id) public view override returns (string memory) {
    require(_exists(id), "not exist");
    address poolAddress = poolById[id];
    IStakingPool stakingPool = IStakingPool(payable(poolAddress));
    uint depositForId = stakingPool.getDepositAmount(id);
    string memory depositString = getEthDecimalString(depositForId);
    uint shareForId = stakingPool.getDistributableShare(id);
    string memory shareString = getEthDecimalString(shareForId);
    string memory stakingPoolAddress = Strings.toHexString(uint160(poolAddress), 20);
    uint32[] memory poolOperators = getOperatorsForPool(poolAddress);
    string memory poolState = stakingPool.getState();
    string memory name = string(abi.encodePacked('fren pool share #',id.toString()));
    string memory description = string(abi.encodePacked(
      'this fren has a deposit of ',depositString,
      ' Eth in pool ', stakingPoolAddress,
      ' with claimable balance of ', shareString, ' Eth'));
    string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

    return
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"',
                name,
                '", "description":"',
                description,
                '", "external_url":"https://frens.fun/token/',
                id.toString(),
                '", "attributes": [{"trait_type": "pool", "value":"',
                stakingPoolAddress,
                '"},{"trait_type": "deposit", "value": "',
                depositString, ' Eth',
                '"},{"trait_type": "claimable", "value": "',
                shareString, ' Eth',
                '"},{"trait_type": "pool state", "value": "',
                poolState,
                '"},{"trait_type": "operator1", "value": "',
                poolOperators.length == 0 ? "Not Set" : uint2str(poolOperators[0]),
                '"},{"trait_type": "operator2", "value": "',
                poolOperators.length == 0 ? "Not Set" : uint2str(poolOperators[1]),
                '"},{"trait_type": "operator3", "value": "',
                poolOperators.length == 0 ? "Not Set" : uint2str(poolOperators[2]),
                '"},{"trait_type": "operator4", "value": "',
                poolOperators.length == 0 ? "Not Set" : uint2str(poolOperators[3]),
                '"}], "image": "',
                'data:image/svg+xml;base64,',
                image,
                '"}'
              )
            )
          )
        )
      );
  }

  function generateSVGofTokenById(uint256 id) internal view returns (string memory) {

    string memory svg = string(abi.encodePacked(
      '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">',
        renderTokenById(id),
      '</svg>'
    ));

    return svg;
  }


  // Visibility is `public` to enable it being called by other contracts for composition.
  function renderTokenById(uint256 id) public view returns (string memory) {

    IStakingPool stakingPool = IStakingPool(payable(poolById[id]));
    uint depositForId = stakingPool.getDepositAmount(id);
    string memory depositString = getEthDecimalString(depositForId);
    uint shareForId = stakingPool.getDistributableShare(id);
    string memory shareString = getEthDecimalString(shareForId);

    string memory render = string(abi.encodePacked(

      '<defs>',
        '<style>',
          '@import url("https://fonts.googleapis.com/css?family=Permanent Marker:400,400i,700,700i");',
          '@import url("https://fonts.googleapis.com/css?family=Poppins:400,400i,700,700i");',
          '@import url("https://fonts.googleapis.com/css2?family=Noto+Color+Emoji");',
        '</style>',
      '</defs>',

      '<circle cx="200" cy="200" r="180" fill="teal" />',

      '<text font-size="210" font-family="Noto Color Emoji" transform="rotate(317 450,-10)">',
        '&#x1F919;',
      '</text>',

      '<polygon points="200,359 85,230 98,195 200,256" fill="teal" />',
      '<polygon points="200,359 98,215 200,276" fill="#8c8c8c" />',
      '<polygon points="200,359 302,215 200,276" fill="#3c3c3b" />',

      '<text font-size="120" x="10" y="120" font-family="Permanent Marker"  opacity="0.6">FRENS</text>',
        '<text font-size="60" x="75" y="200" fill="blue" stroke="#000" stroke-width="1" font-family="Poppins">',
          'Deposit:',
        '</text>',
        '<text font-size="40" x="100" y="250" fill="blue" stroke="#000" stroke-width="1" font-family="Poppins">',
          depositString, ' Eth',
        '</text>',
        '<text font-size="60" x="45" y="330" fill="green" stroke="#000" stroke-width="1" font-family="Poppins">',
          'Claimable:',
        '</text>',
        '<text font-size="40" x="100" y="380" fill="green" stroke="#000" stroke-width="1" font-family="Poppins">',
          shareString, ' Eth',
        '</text>'


      ));

    return render;
  }


  function getEthDecimalString(uint amountInWei) public pure returns(string memory){
    string memory leftOfDecimal = uint2str(amountInWei / 1 ether);
    uint rightOfDecimal = (amountInWei % 1 ether) / 10**14;
    string memory rod = uint2str(rightOfDecimal);
    if(rightOfDecimal < 1000) rod = string.concat("0", rod);
    if(rightOfDecimal < 100) rod = string.concat("0", rod);
    if(rightOfDecimal < 10) rod = string.concat("0", rod);
    return string.concat(leftOfDecimal, ".", rod);
  }

  function getOperatorsForPool(address poolAddress) public view returns (uint32[] memory) {
    IStakingPool stakingPool = IStakingPool(payable(poolAddress));
    bytes memory poolPubKey = stakingPool.getPubKey();
    uint32[] memory poolOperators = ssvRegistry.getOperatorsByValidator(poolPubKey);
    return poolOperators;
  }


  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
      if (_i == 0) {
          return "0";
      }
      uint j = _i;
      uint len;
      while (j != 0) {
          len++;
          j /= 10;
      }
      bytes memory bstr = new bytes(len);
      uint k = len;
      while (_i != 0) {
          k = k-1;
          uint8 temp = (48 + uint8(_i - _i / 10 * 10));
          bytes1 b1 = bytes1(temp);
          bstr[k] = b1;
          _i /= 10;
      }
      return string(bstr);
  }
}
