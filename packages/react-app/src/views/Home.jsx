import { useContractReader } from "eth-hooks";
import { ethers } from "ethers";
import React, { useCallback, useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Button, List, Card } from "antd";
import { Address, AddressInput } from "../components";
import { useEventListener } from "eth-hooks/events/useEventListener";

/**
 * web3 props can be passed from '../App.jsx' into your local view component for use
 * @param {*} yourLocalBalance balance on current network
 * @param {*} readContracts contracts from current chain already pre-loaded using ethers contract module. More here https://docs.ethers.io/v5/api/contract/contract/
 * @returns react component
 **/
function Home({
  yourLocalBalance,
  readContracts,
  balance,
  address,
  mainnetProvider,
  localProvider,
  blockExplorer,
  writeContracts,
  tx,
  injectedProvider,
  loadWeb3Modal,
  USE_BURNER_WALLET,
}) {
  // you can also use hooks locally in your component of choice

  const yourBalance = balance && balance.toNumber && balance.toNumber();

  const mintPrice = 1;
  const [yourCollectibles, setYourCollectibles] = useState();
  const isSigner = USE_BURNER_WALLET
    ? USE_BURNER_WALLET
    : injectedProvider && injectedProvider.getSigner && injectedProvider.getSigner()._isSigner;

  useEffect(() => {
    const updateYourCollectibles = async () => {
      const collectibleUpdate = [];
      for (let tokenIndex = 0; tokenIndex < balance; tokenIndex++) {
        try {
          console.log("GEtting token index", tokenIndex);
          const tokenId = await readContracts.FrensPoolShare.tokenOfOwnerByIndex(address, tokenIndex);
          console.log("tokenId", tokenId);
          const tokenURI = await readContracts.FrensPoolShare.tokenURI(tokenId);
          const jsonManifestString = atob(tokenURI.substring(29));
          console.log("jsonManifestString", jsonManifestString);
          /*
          const ipfsHash = tokenURI.replace("https://ipfs.io/ipfs/", "");
          console.log("ipfsHash", ipfsHash);

          const jsonManifestBuffer = await getFromIPFS(ipfsHash);

        */
          try {
            const jsonManifest = JSON.parse(jsonManifestString);
            console.log("jsonManifest", jsonManifest);
            collectibleUpdate.push({ id: tokenId, uri: tokenURI, owner: address, ...jsonManifest });
          } catch (e) {
            console.log(e);
          }
        } catch (e) {
          console.log(e);
        }
      }
      setYourCollectibles(collectibleUpdate.reverse());
    };
    updateYourCollectibles();
  }, [address, yourBalance]);

  const [transferToAddresses, setTransferToAddresses] = useState({});
  const createEvents = useEventListener(readContracts, "StakingPoolFactory", "Create", localProvider, 1);

  const [newestPool, setNewestPool] = useState();
  useEffect(()=>{
    const lastCreate = createEvents&&createEvents[createEvents.length - 1];
    console.log("lastCreate", lastCreate);
    const newPool = lastCreate&&lastCreate.args&&lastCreate.args.contractAddress;
    setNewestPool(newPool);
  }, [createEvents]);
  console.log("📟 create events:", createEvents);

  return (
    <div>
      <div style={{ maxWidth: 820, margin: "auto", marginTop: 32, paddingBottom: 32 }}>
        {isSigner ? (


            <Button
              type={"primary"}
              onClick={() => {
                tx(writeContracts.StakingPool.depositToPool({ value: mintPrice }));
              }}
            >
              MINT
            </Button>

        ) : (
          <Button type={"primary"} onClick={loadWeb3Modal}>
            CONNECT WALLET
          </Button>
        )}
      </div>
      <div style={{ width: 820, margin: "auto", paddingBottom: 0 }}>
        <List
          bordered
          dataSource={yourCollectibles}
          renderItem={item => {
            const id = item.id.toNumber();

            console.log("IMAGE", item.image);

            return (
              <List.Item key={id + "_" + item.uri + "_" + item.owner}>
                <Card
                  title={
                    <div>
                      <span style={{ fontSize: 18, marginRight: 8 }}>{item.name}</span>
                    </div>
                  }
                >
                  <a
                    href={
                      "https://opensea.io/assets/" +
                      (readContracts && readContracts.FrensPoolShare && readContracts.FrensPoolShare.address) +
                      "/" +
                      item.id
                    }
                    target="_blank"
                    rel="noreferrer"
                  >
                    <img src={item.image} />
                  </a>
                  <div>{item.description}</div>
                </Card>

                <div>
                  owner:{" "}
                  <Address
                    address={item.owner}
                    ensProvider={mainnetProvider}
                    blockExplorer={blockExplorer}
                    fontSize={16}
                  />
                  <AddressInput
                    ensProvider={mainnetProvider}
                    placeholder="transfer to address"
                    value={transferToAddresses[id]}
                    onChange={newValue => {
                      const update = {};
                      update[id] = newValue;
                      setTransferToAddresses({ ...transferToAddresses, ...update });
                    }}
                  />
                  <Button
                    onClick={() => {
                      console.log("writeContracts", writeContracts);
                      tx(writeContracts.FrensPoolShare.transferFrom(address, transferToAddresses[id], id));
                    }}
                  >
                    Transfer
                  </Button>
                  <div style={{ marginTop: 8 }}>
                    <Button
                      onClick={() => {
                        tx(writeContracts.FrensPoolShare.rageQuit(id));
                      }}
                    >
                      Burn
                    </Button>
                  </div>
                </div>
              </List.Item>

            );
          }}
        />
      </div>
      <div style={{paddingBottom: 256}}>
        <h1>latest pool</h1>
        <Address
          address={newestPool}
          ensProvider={mainnetProvider}
          blockExplorer={blockExplorer}
          fontSize={16}
        />
      </div>
    </div>
  );
}

export default Home;
