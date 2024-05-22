from web3 import Web3
from time import time, sleep

# Connect to network
w3 = Web3(Web3.HTTPProvider('http://35.202.216.224:8545'))

# Check if connected to network
if not w3.is_connected():
    print("Failed to connect to the Ethereum client.")
    exit()

sender_address = '0x9c9Ee9e319574BC73e5B01CCc86103fC5cBF5405'
receiver_address = '0x21493b1C72861D211a53d3d8608E166450f65E86'
private_key = '0x687e8564a85918060b43c9f04f930d92d63716430fbc0d439c1c9adbcf4512cc'

# Prepare to collect benchmark data
transaction_times = []
gas_costs = []
transaction_hashes = []

# Fetch the nonce
nonce = w3.eth.get_transaction_count(sender_address)

# Send transactions in a loop
num_transactions = 50
start_time = time()

for i in range(num_transactions):
    transaction = {
        'to': receiver_address,
        'value': w3.to_wei(1, 'ether'),
        'gas': 2000000,
        'gasPrice': w3.to_wei('50', 'gwei'),
        'nonce': nonce,
        'chainId': 4224
    }

    signed_txn = w3.eth.account.sign_transaction(transaction, private_key)
    
    try:
        txn_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
        transaction_hashes.append(txn_hash)
        print(f"Transaction {i+1} sent, hash: {txn_hash.hex()}")
        nonce += 1  # Increment nonce only if the transaction is successfully sent
    except ValueError as e:
        if 'already known' in str(e):
            print(f"Transaction {i+1} failed, nonce conflict. Retrying...")
            nonce = w3.eth.get_transaction_count(sender_address)  # Fetchingg current nonce
            transaction['nonce'] = nonce
            signed_txn = w3.eth.account.sign_transaction(transaction, private_key)
            try:
                txn_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
                transaction_hashes.append(txn_hash)
                print(f"Transaction {i+1} retried, hash: {txn_hash.hex()}")
                nonce += 1  # Increment nonce only if the transaction is successfully sent
            except ValueError as e:
                print(f"Failed to resend transaction {i+1}: {str(e)}")
        else:
            print(f"Transaction {i+1} failed with error: {str(e)}")
            raise

end_time = time()
elapsed_time = end_time - start_time
tps = num_transactions / elapsed_time
print(f"Sent {num_transactions} transactions in {elapsed_time:.2f} seconds. Approx. TPS: {tps:.2f}")

# Increase timeout and handle retries
def wait_for_receipt_with_retries(txn_hash, timeout=400, poll_latency=5):
    start_time = time()
    while True:
        try:
            receipt = w3.eth.wait_for_transaction_receipt(txn_hash, timeout=poll_latency)
            return receipt
        except TimeoutError:
            if time() - start_time > timeout:
                raise
            print(f"Waiting for transaction {txn_hash.hex()} to be mined...")


# Wait for all transactions to be mined
for txn_hash in transaction_hashes:
    try:
        txn_receipt = wait_for_receipt_with_retries(txn_hash, timeout=400) 
        # Calculate transaction time
        block = w3.eth.get_block(txn_receipt['blockNumber'])
        block_time = block['timestamp']
        
        # Time to be confirmed in a block
        transaction_time = time() - block_time
        transaction_times.append(transaction_time)
        
        # Gas cost for the transaction
        gas_cost = txn_receipt['gasUsed'] * txn_receipt['effectiveGasPrice']
        gas_costs.append(gas_cost)
        
        print(f"Transaction receipt received, hash: {txn_hash.hex()}, block: {txn_receipt['blockNumber']}, time: {transaction_time}s, gas cost: {gas_cost} wei")
    except Exception as e:
        print(f"Failed to get receipt for transaction {txn_hash.hex()}: {str(e)}")

# Calculate average transaction time and average gas cost
average_transaction_time = sum(transaction_times) / len(transaction_times) if transaction_times else 0
average_gas_cost = sum(gas_costs) / len(gas_costs) if gas_costs else 0

print(f"Average transaction confirmation time: {average_transaction_time:.2f} seconds")
print(f"Average gas cost per transaction: {average_gas_cost:.2f} wei")
