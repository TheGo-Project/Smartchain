#!/bin/sh

# Default as full
NODE_TYPE=${NODE_TYPE:-full}

# Geth init genesis block
geth --datadir /node/data init /root/genesis.json

# Common settings
echo "password123" > /node/data/password.txt
if [ ! -f "/node/data/keystore/created" ]; then
    ADDRESS=$(geth --datadir /node/data account new --password /node/data/password.txt | awk '/Public address of the key/ {print $NF}')
    echo "Generated address: $ADDRESS"
    touch /node/data/keystore/created
else
    ADDRESS=$(geth --datadir /node/data account list | head -n 1 | awk '{print $3}' | tr -d '{}')
    echo "Using existing address: $ADDRESS"
fi

BOOTNODE_URL="enode://5c1726331dcef14bb7e5d729cc59a78cbf5839da5f46a3f8cb024d86380305d09b4f37525c2849c0446859f9c21f0a8963e749671f6b3dedf2298097e1b1fdc5@bootnode-service.default.svc.cluster.local:30301"

# Node type based actions
case "$NODE_TYPE" in
  "full")
    geth --datadir /node/data --networkid 4224 --syncmode "full" --http --http.addr "0.0.0.0" --http.port 8545 --http.api "admin,eth,debug,miner,net,txpool,personal,web3" --bootnodes "$BOOTNODE_URL"
    ;;
  "archive")
    geth --datadir /node/data --networkid 4224 --syncmode "full" --gcmode "archive" --http --http.addr "0.0.0.0" --http.port 8545 --http.api "admin,eth,debug,miner,net,txpool,personal,web3" --bootnodes "$BOOTNODE_URL"
    ;;
  "miner")
    geth --datadir /node/data --syncmode "full" --mine --miner.etherbase "$ADDRESS" --miner.threads=1 --networkid 4224 --bootnodes "$BOOTNODE_URL" --http --http.addr "0.0.0.0" --http.port 8545 --http.api "admin,eth,debug,miner,net,txpool,personal,web3"
    ;;
  "bootnode")
    bootnode -nodekey /root/boot/boot.key -addr :30301
    ;;
esac
