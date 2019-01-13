#!/bin/bash
set -eu -o pipefail

# Source the IPC path
GETH_IPC=$(cat /opt/quorum/info/geth-ipc.txt)

# The address at which the private contract was mined
CONTRACT_ADDR=$1


if [ $# -lt 2 ]
then
    # Default value if no second argument specified
    OUTPUT_SCRIPT="/opt/quorum/bin/private-transaction-test-recipient.js"
else
    OUTPUT_SCRIPT=$2
fi

# Generate the Javascript test
cat << EOF > $OUTPUT_SCRIPT
a = eth.accounts[0]
web3.eth.defaultAccount = a;

var simpleAbi = [{"constant": true,"inputs": [],"name": "storedData","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "x","type": "uint256"}],"name": "set","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "get","outputs": [{"name": "retVal","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"inputs": [{"name": "initVal","type": "uint256"}],"payable": false,"stateMutability": "nonpayable","type": "constructor"}];
var simpleContract = web3.eth.contract(simpleAbi);
var simple = simpleContract.at("$CONTRACT_ADDR");
EOF

# Attach the geth console and execute the script
geth --preload $OUTPUT_SCRIPT attach $GETH_IPC
