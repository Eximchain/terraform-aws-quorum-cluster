#!/bin/bash
set -eu -o pipefail

# Number of keys required to unseal a vault server
KEY_THRESHOLD=1
# Number of unseal keys produced
KEY_SHARES=1

MAX_RETRIES=5

for retry in {1..$MAX_RETRIES}
do
    vault init -check

    if [ $? -eq 0 ]
    then
        echo "Already Initialized"
        exit 0
    elif [ $? -eq 1 ]
    then
        echo "Error checking init status. Retrying."
        sleep 5
    elif [ $? -eq 2 ]
    then
        echo "Initializing Vault"
        vault init -key-shares=$KEY_SHARES -key-threshold=$KEY_THRESHOLD
        exit $?
    else
        echo "Unexpected return code"
        exit 1
    fi
done

echo "Failed to check vault init status after $MAX_RETRIES attempts."
exit 1
