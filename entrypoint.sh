#!/bin/sh

if [ ! -d "/root/.ethereum/geth/chaindata" ]; then
    echo "Initializing Geth with genesis block..."
    geth init /root/genesis.json
fi

# Start Geth with HTTP RPC enabled
echo "Starting Geth node..."
geth --networkid 4224 --http --http.addr "0.0.0.0" --http.port "8545" \
     --http.api "admin,eth,net,web3,personal,miner" --allow-insecure-unlock --ws --ws.addr "0.0.0.0" --ws.port "8546" \
     --ws.api "admin,eth,net,web3,personal,miner" --ws.origins "*" --maxpeers 10 --ipcpath "/root/.ethereum/geth.ipc" &

# Wait for Geth to be fully up and ready
sleep 60

# Retrieve the first account address 
ACCOUNT_ADDRESS=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' \
    -H "Content-Type: application/json" \
    http://localhost:8545 | jq -r '.result[0]')

echo "Using account address: $ACCOUNT_ADDRESS"

curl -X POST --data '{"jsonrpc":"2.0","method":"personal_unlockAccount","params":["'"$ACCOUNT_ADDRESS"'", "123456789", null],"id":1}' \
    -H "Content-Type: application/json" \
    http://localhost:8545

# Set etherbase
curl -X POST --data '{"jsonrpc":"2.0","method":"miner_setEtherbase","params":["'"$ACCOUNT_ADDRESS"'"],"id":3}' \
    -H "Content-Type: application/json" \
    http://localhost:8545


curl -X POST --data '{"jsonrpc":"2.0","method":"miner_start","params":[],"id":2}' \
    -H "Content-Type: application/json" \
    http://localhost:8545

echo "Mining started..."


# Keepng the container alive
tail -f /dev/null