#!/bin/bash
set -eu -o pipefail

# Source the IPC path
EXIM_IPC=$(cat /opt/quorum/info/exim-ipc.txt)

# Constellation public key of the recipient
RECIPIENT_PUB_KEY=$1


if [ $# -lt 2 ]
then
    # Default value if no second argument specified
    OUTPUT_SCRIPT="/opt/quorum/bin/private-transaction-test-sender.js"
else
    OUTPUT_SCRIPT=$2
fi

# Generate the Javascript test
cat << EOF > $OUTPUT_SCRIPT
a = eth.accounts[0]
web3.eth.defaultAccount = a;

var simpleCompiled = "0x6060604052341561000f57600080fd5b60405160208061014b833981016040528080519060200190919050508060008190555050610109806100426000396000f3006060604052600436106053576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632a1afcd914605857806360fe47b114607e5780636d4ce63c14609e575b600080fd5b3415606257600080fd5b606860c4565b6040518082815260200191505060405180910390f35b3415608857600080fd5b609c600480803590602001909190505060ca565b005b341560a857600080fd5b60ae60d4565b6040518082815260200191505060405180910390f35b60005481565b8060008190555050565b600080549050905600a165627a7a72305820e14fcef2e49e666a66f83e43e7c26f1abcc5b658d2ea9f61dd3000aab655fd370029";
var simpleAbi = [{"constant": true,"inputs": [],"name": "storedData","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "x","type": "uint256"}],"name": "set","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "get","outputs": [{"name": "retVal","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"inputs": [{"name": "initVal","type": "uint256"}],"payable": false,"stateMutability": "nonpayable","type": "constructor"}];
var simpleCallback = function(e, contract) {
  if (e) {
    console.log("err creating contract", e);
  } else {
    if (!contract.address) {
      console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
    } else {
      console.log("Contract mined! Address: " + contract.address);
      console.log(contract);
    }
  }
};

var simpleContract = web3.eth.contract(simpleAbi);
var simple = simpleContract.new(42, {from:web3.eth.accounts[0], data: simpleCompiled, gas: 300000, privateFor: ["$RECIPIENT_PUB_KEY"]}, simpleCallback);
EOF

# Attach the exim console and execute the script
exim --preload $OUTPUT_SCRIPT attach $EXIM_IPC
