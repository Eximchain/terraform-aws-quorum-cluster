#!/bin/bash
set -eu -o pipefail

# Default Arg Values
FROM_REGION=""
FROM_INDEX=""
TO_REGION=""
TO_INDEX=""
CLEANUP="NO"
# Parse Args
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -fr|--from-region)
    FROM_REGION="$2"
    shift # past argument
    shift # past value
    ;;
    -fi|--from-index)
    FROM_INDEX="$2"
    shift # past argument
    shift # past value
    ;;
    -tr|--to-region)
    TO_REGION="$2"
    shift # past argument
    shift # past value
    ;;
    -ti|--to-index)
    TO_INDEX="$2"
    shift # past argument
    shift # past value
    ;;
    -r|--region)
    FROM_REGION="$2"
    TO_REGION="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--cleanup)
    CLEANUP="YES"
    shift # past argument
    ;;
    *)    # unknown option
    echo "Unexpected Option '$1' Found"
    exit 1
    ;;
esac
done

# Assert all args are specified
if [[ -z "$FROM_REGION" || -z "$FROM_INDEX" || -z "$TO_REGION" || -z "$TO_INDEX" ]]
then
  echo "Unset argument detected. Aborting."
  exit 1
fi

# Define paths we will work with
readonly FROM_PATH_ADDRESSES="quorum/addresses/$FROM_REGION/$FROM_INDEX"
readonly FROM_PATH_KEYS="quorum/keys/$FROM_REGION/$FROM_INDEX"
readonly FROM_PATH_PASSWORDS="quorum/passwords/$FROM_REGION/$FROM_INDEX"

readonly TO_PATH_ADDRESSES="quorum/addresses/$TO_REGION/$TO_INDEX"
readonly TO_PATH_KEYS="quorum/keys/$TO_REGION/$TO_INDEX"
readonly TO_PATH_PASSWORDS="quorum/passwords/$TO_REGION/$TO_INDEX"

# Find the next slot in the graveyard
# TODO: Enable resurrection of machines in graveyard
set +e
GRAVEYARD_SLOT=-1
until [ $? -ne 0 ]
do
    ((GRAVEYARD_SLOT++))
    GRAVEYARD_PATH="quorum/graveyard/$GRAVEYARD_SLOT"
    vault read $GRAVEYARD_PATH > /dev/null 2>&1
done
set -e

# Read all data for nodes
# This must be changed if fields are changed
readonly FROM_ADDRESS=$(vault read -field=address $FROM_PATH_ADDRESSES)
readonly FROM_CONSTELLATION_PUB_KEY=$(vault read -field=constellation_pub_key $FROM_PATH_ADDRESSES)
readonly FROM_HOSTNAME=$(vault read -field=hostname $FROM_PATH_ADDRESSES)

readonly FROM_CONSTELLATION_PRIV_KEY=$(vault read -field=constellation_priv_key $FROM_PATH_KEYS)
readonly FROM_GETH_KEY=$(vault read -field=geth_key $FROM_PATH_KEYS)
readonly FROM_GETH_KEY_FILE=$(vault read -field=geth_key_file $FROM_PATH_KEYS)

readonly FROM_GETH_PW=$(vault read -field=geth_pw $FROM_PATH_PASSWORDS)
readonly FROM_CONSTELLATION_PW=$(vault read -field=constellation_pw $FROM_PATH_PASSWORDS)

readonly TO_ADDRESS=$(vault read -field=address $TO_PATH_ADDRESSES)
readonly TO_CONSTELLATION_PUB_KEY=$(vault read -field=constellation_pub_key $TO_PATH_ADDRESSES)
readonly TO_HOSTNAME=$(vault read -field=hostname $TO_PATH_ADDRESSES)

readonly TO_CONSTELLATION_PRIV_KEY=$(vault read -field=constellation_priv_key $TO_PATH_KEYS)
readonly TO_GETH_KEY=$(vault read -field=geth_key $TO_PATH_KEYS)
readonly TO_GETH_KEY_FILE=$(vault read -field=geth_key_file $TO_PATH_KEYS)

readonly TO_GETH_PW=$(vault read -field=geth_pw $TO_PATH_PASSWORDS)
readonly TO_CONSTELLATION_PW=$(vault read -field=constellation_pw $TO_PATH_PASSWORDS)

# Save the to node data in the graveyard before we replace it
echo "Saving original node info in graveyard at path $GRAVEYARD_PATH\n"
vault write $GRAVEYARD_PATH address=$TO_ADDRESS constellation_pub_key=$TO_CONSTELLATION_PUB_KEY hostname=$TO_HOSTNAME geth_key=$TO_GETH_KEY geth_key_file=$TO_GETH_KEY_FILE constellation_priv_key=$TO_CONSTELLATION_PRIV_KEY geth_pw=$TO_GETH_PW constellation_pw=$TO_CONSTELLATION_PW

# Write the From data to the To location
# Role indexing should stay the same to keep the genesis block constant
vault write $TO_PATH_ADDRESSES address=$FROM_ADDRESS constellation_pub_key=$FROM_CONSTELLATION_PUB_KEY hostname=$FROM_HOSTNAME
vault write $TO_PATH_KEYS geth_key=$FROM_GETH_KEY geth_key_file=$FROM_GETH_KEY_FILE constellation_priv_key=$FROM_CONSTELLATION_PRIV_KEY
vault write $TO_PATH_PASSWORDS geth_pw=$FROM_GETH_PW constellation_pw=$FROM_CONSTELLATION_PW

# Clean up from address if requested
if [ "$CLEANUP" == "YES" ]
then
  vault delete $FROM_PATH_KEYS
  vault delete $FROM_PATH_PASSWORDS
  # Don't delete the address path because wait_for_all_nodes depends on it
  vault write $FROM_PATH_ADDRESSES address=DELETED
fi
