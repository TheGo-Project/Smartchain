#!/bin/sh

DATA_DIR="/root/.ethereum"
GENESIS_PATH="/root/genesis.json"
PASSWORD_PATH="$DATA_DIR/.password"
FIXED_PASSWORD="123456789"  #

mkdir -p $DATA_DIR

if [ -z "$(ls -A $DATA_DIR/keystore 2>/dev/null)" ]; then
    echo "No account found. Creating new account..."

    echo $FIXED_PASSWORD > $PASSWORD_PATH

    OUTPUT=$(geth account new --datadir $DATA_DIR --password $PASSWORD_PATH)
    echo "Geth output: $OUTPUT"
    
    ADDRESS=$(echo "$OUTPUT" | awk '/Public address of the key:/ {print substr($NF, 3)}')

    echo "Extracted Address: $ADDRESS"

    if [ -z "$ADDRESS" ]; then
        echo "Address extraction failed."
        exit 1
    fi

    EXTRADATA="0x0000000000000000000000000000000000000000000000000000000000000000${ADDRESS}0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"

    jq --arg extradata "$EXTRADATA" '.extradata = $extradata' $GENESIS_PATH > "${GENESIS_PATH}.tmp" && mv "${GENESIS_PATH}.tmp" $GENESIS_PATH
    echo "Genesis file updated with new extradata: $EXTRADATA"
else
    echo "Account already exists. Using existing account..."
    PASSWORD=$(cat $PASSWORD_PATH)
    ADDRESS=$(ls -1 $DATA_DIR/keystore | grep -oE 'UTC--.*--([a-fA-F0-9]{40})' | head -n 1 | grep -oE '[a-fA-F0-9]{40}')
fi

export ACCOUNT_ADDRESS="0x$ADDRESS"
export ACCOUNT_PASSWORD=$FIXED_PASSWORD

echo "Using address: $ACCOUNT_ADDRESS"

/bin/sh /root/entrypoint.sh
