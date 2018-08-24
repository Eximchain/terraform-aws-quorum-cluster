#!/bin/bash
set -eu -o pipefail

# Source the IPC path
GETH_IPC=$(cat /opt/quorum/info/geth-ipc.txt)

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

var simpleSource = 'contract simplestorage { uint public storedData; function simplestorage(uint initVal) { storedData = initVal; } function set(uint x) { storedData = x; } function get() constant returns (uint retVal) { return storedData; } }'
var simpleCompiled = web3.eth.compile.solidity(simpleSource);
var simpleRoot = Object.keys(simpleCompiled)[0];
var simpleContract = web3.eth.contract(simpleCompiled[simpleRoot].info.abiDefinition);
var simple = simpleContract.new(42, {from:web3.eth.accounts[0], data: simpleCompiled[simpleRoot].code, gas: 300000, privateFor: ["$RECIPIENT_PUB_KEY"]}, function(e, contract) {
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
});
EOF

# Attach the geth console and execute the script
geth --preload $OUTPUT_SCRIPT attach $GETH_IPC
