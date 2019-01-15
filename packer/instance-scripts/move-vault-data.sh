#!/bin/bash
set -eu -o pipefail

# Default Arg Values
FROM_REGION=""
FROM_INDEX=""
TO_REGION=""
TO_INDEX=""
CLEANUP="YES"
GRAVEYARD_RESURRECT="NO"
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
    -nc|--no-cleanup)
    CLEANUP="NO"
    shift # past argument
    ;;
    -g|--graveyard-resurrect)
    GRAVEYARD_RESURRECT="YES"
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
FROM_PATH_ADDRESSES="quorum/addresses/$FROM_REGION/$FROM_INDEX"
FROM_PATH_KEYS="quorum/keys/$FROM_REGION/$FROM_INDEX"
FROM_PATH_PASSWORDS="quorum/passwords/$FROM_REGION/$FROM_INDEX"

readonly TO_PATH_ADDRESSES="quorum/addresses/$TO_REGION/$TO_INDEX"
readonly TO_PATH_KEYS="quorum/keys/$TO_REGION/$TO_INDEX"
readonly TO_PATH_PASSWORDS="quorum/passwords/$TO_REGION/$TO_INDEX"

if [ "$GRAVEYARD_RESURRECT" == "YES" ]
then
  readonly TO_ADDRESS_TEST=$(vault read -field=address $TO_PATH_ADDRESSES)
  # If doing a graveyard resurrection, ensure the destination slot is empty
  if [ "$TO_ADDRESS_TEST" != "DELETED" ]
  then
    echo "Address at $TO_PATH_ADDRESSES is not DELETED, found '$TO_ADDRESS_TEST' instead. Aborting."
    exit 1
  fi

  # Swap the FROM paths to the graveyard path
  FROM_PATH_ADDRESSES="quorum/graveyard/$FROM_INDEX"
  FROM_PATH_KEYS="quorum/graveyard/$FROM_INDEX"
  FROM_PATH_PASSWORDS="quorum/graveyard/$FROM_INDEX"
fi


# Find the next slot in the graveyard
if [ "$GRAVEYARD_RESURRECT" == "NO" ]
then
  set +e
  GRAVEYARD_SLOT=-1
  until [ $? -ne 0 ]
  do
      ((GRAVEYARD_SLOT++))
      GRAVEYARD_PATH="quorum/graveyard/$GRAVEYARD_SLOT"
      vault read $GRAVEYARD_PATH > /dev/null 2>&1
  done
  set -e
fi

# Read all data for nodes
# This must be changed if fields are changed
readonly FROM_ADDRESS=$(vault read -field=address $FROM_PATH_ADDRESSES)
readonly FROM_CONSTELLATION_PUB_KEY=$(vault read -field=constellation_pub_key $FROM_PATH_ADDRESSES)
readonly FROM_HOSTNAME=$(vault read -field=hostname $FROM_PATH_ADDRESSES)

readonly FROM_CONSTELLATION_PRIV_KEY=$(vault read -field=constellation_priv_key $FROM_PATH_KEYS)
readonly FROM_EXIM_KEY=$(vault read -field=exim_key $FROM_PATH_KEYS)
readonly FROM_EXIM_KEY_FILE=$(vault read -field=exim_key_file $FROM_PATH_KEYS)

readonly FROM_EXIM_PW=$(vault read -field=exim_pw $FROM_PATH_PASSWORDS)
readonly FROM_CONSTELLATION_PW=$(vault read -field=constellation_pw $FROM_PATH_PASSWORDS)

# Save the to node data in the graveyard before we replace it
if [ "$GRAVEYARD_RESURRECT" == "NO" ]
then
  readonly TO_ADDRESS=$(vault read -field=address $TO_PATH_ADDRESSES)
  readonly TO_CONSTELLATION_PUB_KEY=$(vault read -field=constellation_pub_key $TO_PATH_ADDRESSES)
  readonly TO_HOSTNAME=$(vault read -field=hostname $TO_PATH_ADDRESSES)

  readonly TO_CONSTELLATION_PRIV_KEY=$(vault read -field=constellation_priv_key $TO_PATH_KEYS)
  readonly TO_EXIM_KEY=$(vault read -field=exim_key $TO_PATH_KEYS)
  readonly TO_EXIM_KEY_FILE=$(vault read -field=exim_key_file $TO_PATH_KEYS)

  readonly TO_EXIM_PW=$(vault read -field=exim_pw $TO_PATH_PASSWORDS)
  readonly TO_CONSTELLATION_PW=$(vault read -field=constellation_pw $TO_PATH_PASSWORDS)
  
  echo "Saving original node info in graveyard at path $GRAVEYARD_PATH"
  vault write $GRAVEYARD_PATH address=$TO_ADDRESS constellation_pub_key=$TO_CONSTELLATION_PUB_KEY hostname=$TO_HOSTNAME exim_key=$TO_EXIM_KEY exim_key_file=$TO_EXIM_KEY_FILE constellation_priv_key=$TO_CONSTELLATION_PRIV_KEY exim_pw=$TO_EXIM_PW constellation_pw=$TO_CONSTELLATION_PW
fi

# Write the From data to the To location
# Role indexing should stay the same to keep the genesis block constant
vault write $TO_PATH_ADDRESSES address=$FROM_ADDRESS constellation_pub_key=$FROM_CONSTELLATION_PUB_KEY hostname=$FROM_HOSTNAME
vault write $TO_PATH_KEYS exim_key=$FROM_EXIM_KEY exim_key_file=$FROM_EXIM_KEY_FILE constellation_priv_key=$FROM_CONSTELLATION_PRIV_KEY
vault write $TO_PATH_PASSWORDS exim_pw=$FROM_EXIM_PW constellation_pw=$FROM_CONSTELLATION_PW

# Clean up from address if requested
if [[ "$CLEANUP" == "YES" && "$GRAVEYARD_RESURRECT" == "NO" ]]
then
  vault delete $FROM_PATH_KEYS
  vault delete $FROM_PATH_PASSWORDS
  # Don't delete the address path because wait_for_all_nodes depends on it
  vault write $FROM_PATH_ADDRESSES address=DELETED
fi
