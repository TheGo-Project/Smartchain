#!/bin/sh

# Default as fill
NODE_TYPE=${NODE_TYPE:-full}

# Geth init genesis block
geth --datadir /node/data init /root/genesis.json

# common settings
echo "password123" > /node/data/password.txt
ADDRESS=$(geth --datadir /node/data account new --password /node/data/password.txt | awk '/Public address of the key/ {print $NF}')
echo "Generated address: $ADDRESS"

# Start the bootnode
bootnode -genkey /node/data/boot.key
BOOTNODE_URL=$(bootnode -nodekey /node/data/boot.key -writeaddress)
ENODE="enode://$BOOTNODE_URL@127.0.0.1:30305"
bootnode -nodekey /node/data/boot.key -addr :30305 &

# Node type based actions

case "$NODE_TYPE" in
  "full")
    geth --datadir /node/data --networkid 4224 --syncmode "full" --http --http.addr "0.0.0.0" --http.port 8545 --http.api "admin,eth,debug,miner,net,txpool,personal,web3" --bootnodes "$ENODE"
    ;;
  "archive")
    geth --datadir /node/data --networkid 4224 --syncmode "full" --gcmode "archive" --http --http.addr "0.0.0.0" --http.port 8545 --http.api "admin,eth,debug,miner,net,txpool,personal,web3" --bootnodes "$ENODE"
    ;;
  "miner")
    geth --datadir /node/data --syncmode "full" --mine --miner.etherbase "$ADDRESS" --miner.threads=1 --networkid 4224 --bootnodes "$ENODE" --password /node/data/password.txt --unlock "$ADDRESS" --http --http.addr "0.0.0.0" --http.port 8545 --http.api "admin,eth,debug,miner,net,txpool,personal,web3"
    ;;
esac
