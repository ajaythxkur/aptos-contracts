"use client";

import { Layout, Row, Col } from "antd";
import { WalletSelector } from "@aptos-labs/wallet-adapter-ant-design";
import "@aptos-labs/wallet-adapter-ant-design/dist/index.css";
import { Aptos } from "@aptos-labs/ts-sdk";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { useEffect, useState } from "react";
export const moduleAddress = "0xfc8ece4c92d01e5b3b220baf0cb5473352f9deea9fb6edc962b50e486f5df598";
export default function Home() {
  const aptos = new Aptos(); //default devnet
  const { account } = useWallet();
  const [accountHasList, setAccountHasList] = useState<boolean>(false)
  const fetchList = async() => {
    if(!account) return;
    try{
      const todoListResource = await aptos.getAccountResource(
        {
          accountAddress: account?.address,
          resourceType: `${moduleAddress}::todolist::TodoList`
        }
      );
      setAccountHasList(true)
    }catch(err:any){
      setAccountHasList(false)
    }
  }
  useEffect(()=>{
    fetchList()
  },[account?.address])
  return (
  <>
  <Layout>
      <Row align="middle">
        <Col span={10} offset={2}>
          <h1>Our todolist</h1>
        </Col>
        <Col span={12} style={{ textAlign: "right", paddingRight: "200px" }}>
        <WalletSelector />
        </Col>
      </Row>
    </Layout>
  </>
  )
}
