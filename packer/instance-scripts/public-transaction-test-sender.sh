#!/bin/bash
set -eu -o pipefail

# Source the IPC path
GETH_IPC=$(cat /opt/quorum/info/geth-ipc.txt)

# geth address public key of the recipient
RECIPIENT_ADDRESS=$1


if [ $# -lt 2 ]
then
    # Default value if no second argument specified
    OUTPUT_SCRIPT="/opt/quorum/bin/public-transaction-test-sender.js"
else
    OUTPUT_SCRIPT=$2
fi

# Generate the Javascript test
cat << EOF > $OUTPUT_SCRIPT
a = eth.accounts[0]
web3.eth.defaultAccount = a;

console.log(eth.coinbase);

var recipient = "$RECIPIENT_ADDRESS";

console.log(recipient);

eth.sendTransaction({from: eth.coinbase, to: recipient, value: web3.toWei(1, "ether")});
EOF

# Attach the geth console and execute the script
geth --preload $OUTPUT_SCRIPT attach $GETH_IPC
