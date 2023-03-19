import { Button, Divider, List } from "antd";
import React, { useState } from "react";
import { utils } from "ethers";
import { MerkleTree } from 'merkletreejs'
import { Address, AddressInput } from "../components";

export default function MerkleGenerator({
  
  mainnetProvider,
  
}) {
  
  const [newAddress, setNewAddress] = useState();
  const [addresses, setAddresses] = useState([]);
  const [tree, setTree] = useState();
  const [root, setRoot] = useState();

  const addAddress = () => {
    const addressUpdate = addresses;
    addressUpdate.push(newAddress);
    setAddresses(addressUpdate);
    setNewAddress("");
  }

  const makeTree = () => {
    const leaves = addresses.map(x => utils.keccak256(x));
    console.log("leaves", leaves);
    const newTree = new MerkleTree(leaves, utils.keccak256, { sort: true });
    setTree(newTree);
    console.log("tree", newTree);
    const newRoot = newTree.getHexRoot();
    setRoot(newRoot);
    console.log("root", newRoot);
    for(let i=0; i < leaves.length; i++){
      const proof = newTree.getHexProof(leaves[i]);
      console.log("proof", addresses[i], proof);
      console.log("valid?", newTree.verify(proof, leaves[i], newRoot));
    }
    

  }
  

console.log("rerender");
  return (
    <div>
      {/*
        ⚙️ Here is an example UI that displays and sets the purpose in your smart contract:
      */}
      <div style={{ border: "1px solid #cccccc", padding: 16, width: 620, margin: "auto", marginTop: 64 }}>
        <h2>Merkle Tree Generator</h2>
        <Divider />
        <h4>add frens:</h4>
        <div style={{ margin: 8 }}>
          <AddressInput
            autoFocus
            ensProvider={mainnetProvider}
            placeholder="Enter address"
            value={newAddress}
            onChange={setNewAddress}
          />
          
          
          <Button
            style={{ marginTop: 8 }}
            onClick={addAddress}
          >
            add address
          </Button>
          
        </div>
        <Divider />
        <div >
          <h4>allowed addresses:</h4>
          <List
            bordered
            dataSource={addresses}
            renderItem={item => {
              
              return (
                <List.Item key={item}>
                 
                      
                    <Address
                      address={item}
                      ensProvider={mainnetProvider}
                      fontSize={16}
                    />
                    
                </List.Item>
              );
            }}
          />
        </div>
        <Divider />
        <div>
          <Button
            style={{ marginTop: 8 }}
            onClick={makeTree}
          >
            create tree
          </Button>
        </div>
        <Divider />
        <div>
          {root ? 
            <div>
              <div>
                <h2>root:</h2>
                {root}
              </div>
              <Divider />
              <div>
                <h2>leaves:</h2>
                <List
                  bordered
                  dataSource={addresses}
                  renderItem={item => {
                    return (
                      <List.Item key={item}>
                      
                          <h4>address:</h4> 
                          <Address
                            address={item}
                            ensProvider={mainnetProvider}
                            fontSize={16}
                          />
                          <Divider />
                          <h4>leaf:</h4>
                          {utils.keccak256(item)}
                          <Divider />
                          <h4>proof:</h4>
                          <ul>
                            {tree.getHexProof(utils.keccak256(item)).map(x => {
                              return <li>{x}</li>;
                            })}
                          </ul>
                          
                      </List.Item>
                    );
                  }}
                />
              </div>
             
              
            </div>
            
            
            : ""
          }
          

        </div>
      </div>
    </div>
  );
}
